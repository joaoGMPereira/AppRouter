import SwiftUI
import Observation

/// Classe singleton que fornece acesso centralizado à ferramenta de debug do router
/// a partir de qualquer parte do aplicativo.
@Observable
public final class RouterDebugger {
    /// Instância compartilhada do RouterDebugger
    @MainActor public static let shared = RouterDebugger()
    
    /// Lista de logs de navegação para análise
    var navigationLogs: [NavigationLogEntry] = []
    
    /// Construtor privado para garantir o padrão singleton
    private init() {}

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
