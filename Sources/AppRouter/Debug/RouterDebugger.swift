import SwiftUI
import Observation

/// Classe singleton que fornece acesso centralizado à ferramenta de debug do router
/// a partir de qualquer parte do aplicativo.
@Observable
final class RouterDebugger {
    /// Instância compartilhada do RouterDebugger
    @MainActor static let shared = RouterDebugger()
    
    /// Flag que controla a apresentação da view de debug
    var showingDebugView = false
    
    /// Flag que indica se o botão flutuante deve ser mostrado
    var showFloatingButton = false
    
    /// Lista de logs de navegação para análise
    var navigationLogs: [NavigationLogEntry] = []
    
    /// Construtor privado para garantir o padrão singleton
    private init() {}
    
    /// Ativa o modo de debug do router
    func enableDebug() {
        showFloatingButton = true
    }
    
    /// Desativa o modo de debug do router
    func disableDebug() {
        showFloatingButton = false
        showingDebugView = false
    }
    
    /// Adiciona uma entrada ao log de navegação
    func addNavigationLog(type: NavigationLogType, message: String, routerId: String) {
        let entry = NavigationLogEntry(
            timestamp: Date(),
            type: type,
            message: message,
            routerId: routerId
        )
        navigationLogs.insert(entry, at: 0)
        
        // Limitar o número de logs para evitar uso excessivo de memória
        if navigationLogs.count > 1000 {
            navigationLogs = Array(navigationLogs.prefix(1000))
        }
    }
    
    /// Limpa todos os logs de navegação
    func clearNavigationLogs() {
        navigationLogs.removeAll()
    }
}

/// Representa um tipo de evento de log de navegação
enum NavigationLogType: String {
    case navigation = "Navigation"
    case presentation = "Presentation"
    case dismissal = "Dismissal"
    case registration = "Registration"
    case error = "Error"
    case warning = "Warning"
    case info = "Info"
    
    var color: Color {
        switch self {
        case .navigation:
            return .blue
        case .presentation:
            return .green
        case .dismissal:
            return .orange
        case .registration:
            return .purple
        case .error:
            return .red
        case .warning:
            return .yellow
        case .info:
            return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .navigation:
            return "arrow.right"
        case .presentation:
            return "rectangle.stack"
        case .dismissal:
            return "xmark"
        case .registration:
            return "plus.circle"
        case .error:
            return "exclamationmark.triangle"
        case .warning:
            return "exclamationmark.circle"
        case .info:
            return "info.circle"
        }
    }
}

/// Representa uma entrada no log de navegação
struct NavigationLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let type: NavigationLogType
    let message: String
    let routerId: String
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}

/// View modificador que adiciona o botão flutuante de debug à view
struct RouterDebugModifier: ViewModifier {
    @State private var debugger = RouterDebugger.shared
    @Environment(AppRouter.self) private var appRouter
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if debugger.showFloatingButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Registra o router de debug se necessário
                            registerRouterDebugIfNeeded()
                            debugger.showingDebugView = true
                        }) {
                            Image(systemName: "hammer")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "#B6FB2D"))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 40)
                        .opacity(0.9)
                    }
                }
                .sheet(isPresented: $debugger.showingDebugView) {
                    NavigationView {
                        RouterDebugDashboard()
                    }
                }
            }
        }
    }
    
    private func registerRouterDebugIfNeeded() {
        // Verificação correta com tipo explícito
        if let _: Router<RouterDebugRoute> = appRouter.router(forKey: "routerDebug") {
            // Router já está registrado, não precisamos fazer nada
            print("📡 Debug router already registered")
        } else {
            // Router não está registrado, vamos criar um novo
            let routerDebug = Router<RouterDebugRoute>("routerDebug")
            appRouter.register(routerDebug)
            print("📡 Debug router automatically registered")
        }
    }
}

/// Extensão para facilitar a aplicação do modificador de debug
public extension View {
    /// Adiciona o botão flutuante de debug à view
    func withRouterDebug() -> some View {
        self.modifier(RouterDebugModifier())
    }
}

/// Comando para ativar o botão flutuante de debug a partir do console
@MainActor public func enableRouterDebug() {
    RouterDebugger.shared.enableDebug()
    print("📡 Router Debug enabled! A floating button will appear in the interface.")
    print("   To disable, run: disableRouterDebug()")
}

/// Comando para desativar o botão flutuante de debug a partir do console
@MainActor public func disableRouterDebug() {
    RouterDebugger.shared.disableDebug()
    print("📡 Router Debug disabled!")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: Double
        switch hex.count {
        case 6:
            (a, r, g, b) = (1, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        case 8:
            (a, r, g, b) = (Double((int >> 24) & 0xFF) / 255, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        default:
            (a, r, g, b) = (1, 0, 0, 0)
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
