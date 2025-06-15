import SwiftUI

/// Rotas específicas para as funcionalidades de debug do router
public enum RouterDebugRoute: @preconcurrency Routable {
    public static let key = String(describing: Self.self)
    public var id: String {
        switch self {
        case .featureA(let id, let previousId, let level):
            return id
        case .featureB(let id, let previousId, let level):
            return id
        }
    }
    /// Rota para simular Feature A com níveis aninhados
    case featureA(id: String, previousId: String, level: Int)
    
    /// Rota para simular Feature B com níveis aninhados
    case featureB(id: String, previousId: String, level: Int)
}

extension RouterDebugRoute {
    public var body: some View {
        switch self {
        case .featureA(let id, let previousId, let level):
            
            InlineFeatureView(type: .featureA, id: id, previousId: previousId, level: level)
            
        case .featureB(let id, let previousId, let level):
            InlineFeatureView(type: .featureB, id: id, previousId: previousId, level: level)
        }
    }
}

/// Tipo de Feature para visualização em testes de navegação (versão simplificada inline)
enum InlineFeatureType: String {
    case featureA = "Feature A"
    case featureB = "Feature B"
    
    var gradientColors: [Color] {
        switch self {
        case .featureA:
            return [Color.blue.opacity(0.8), Color.indigo.opacity(0.8)]
        case .featureB:
            return [Color.purple.opacity(0.8), Color.pink.opacity(0.8)]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .featureA:
            return .blue
        case .featureB:
            return .purple
        }
    }
}

/// View genérica para representar features em testes de navegação (versão simplificada inline)
struct InlineFeatureView: View {
    // Propriedades
    let type: InlineFeatureType
    let id: String
    let previousId: String
    let level: Int
    
    // Environment
    @Environment(AppRouter.self) private var appRouter
    @Environment(\.dismiss) private var dismiss
    @State private var showRoutersList = false
    
    var body: some View {
        if let routerDebug: Router<RouterDebugRoute> = appRouter.router(forKey: id) {
            RoutingView(router: routerDebug) {
                ZStack {
                    // Background gradient específico para o tipo de feature
                    LinearGradient(
                        gradient: Gradient(colors: type.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header com informações da feature
                            Text(type.rawValue)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 30)
                            
                            Text("ID: \(id) • Level: \(level)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(20)
                            
                            // Ações de Navegação
                            VStack(spacing: 14) {
                                // Navegação para o próximo nível dentro da mesma feature
                                Button("Push to Next Level") {
                                    switch type {
                                    case .featureA:
                                        routerDebug.navigate(
                                            to: .featureA(
                                                id: id,
                                                previousId: previousId,
                                                level: level + 1
                                            )
                                        )
                                    case .featureB:
                                        routerDebug.navigate(
                                            to: .featureB(
                                                id: id,
                                                previousId: previousId,
                                                level: level + 1
                                            )
                                        )
                                    }
                                }
                                .buttonStyle(FeatureButtonStyle(type: type, isPrimary: true))
                                .disabled(level >= 5) // Limitamos a 5 níveis de profundidade
                                
                                if level > 1 {
                                    // Navegação para voltar ao nível anterior
                                    Button("Pop to Previous Level") {
                                        routerDebug.navigateBack()
                                    }
                                    .buttonStyle(FeatureButtonStyle(type: type, isPrimary: false))
                                }
                                
                                // Navegar para a raiz da stack atual
                                Button("Pop to Root") {
                                    if let previousRouter: Router<RouterDebugRoute> = appRouter.router(forKey: previousId) {
                                        previousRouter.dismissPresented()
                                    }
                                }
                                .buttonStyle(FeatureButtonStyle(type: type, isPrimary: false))
                                .disabled(level <= 1)
                                
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                    .padding(.vertical, 8)
                                
                                // Apresentar a outra feature como sheet
                                Button("Present \(type == .featureA ? "Feature B" : "Feature A") as Sheet") {
                                    let featureId = "routerFeature\(type == .featureA ? "B" : "A")-\(UUID().uuidString.prefix(4).description)"
                                    let routerNewFeature = Router<RouterDebugRoute>(featureId)
                                    
                                    appRouter.register(routerNewFeature)
                                    switch type {
                                    case .featureA:
                                        routerDebug.present(
                                            sheet: .featureB(
                                                id: featureId,
                                                previousId: id,
                                                level: 1
                                            )
                                        )
                                    case .featureB:
                                        routerDebug.present(
                                            sheet: .featureA(
                                                id: featureId,
                                                previousId: id,
                                                level: 1
                                            )
                                        )
                                    }
                                }
                                .buttonStyle(FeatureButtonStyle(type: type == .featureA ? .featureB : .featureA, isPrimary: true))
                                
                                // Dismiss sheet atual
                                Button("Dismiss Current Sheet") {
                                    if let previousRouter: Router<RouterDebugRoute> = appRouter.router(forKey: previousId) {
                                        previousRouter.dismissPresented()
                                    }
                                }
                                .buttonStyle(FeatureButtonStyle(type: type, isPrimary: false, isDestructive: true))
                                
                                // Botão para mostrar/esconder lista de routers
                                Button("Show Registered Routers") {
                                    showRoutersList.toggle()
                                }
                                .buttonStyle(FeatureButtonStyle(type: type, isPrimary: true))
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                            
                            // List of registered routers (only shown when showRoutersList is true)
                            if showRoutersList {
                                RegisteredRoutersListView(
                                    id: id,
                                    backgroundColor: Color.black.opacity(0.2),
                                    titleColor: .white,
                                    maxHeight: 150
                                )
                                .padding(.horizontal, 20)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.easeInOut, value: showRoutersList)
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        if level > 1 {
                            Button(action: {
                                routerDebug.navigateBack()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

/// Estilo de botão para a FeatureView (versão simplificada inline)
struct FeatureButtonStyle: ButtonStyle {
    let type: InlineFeatureType
    let isPrimary: Bool
    var isDestructive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .background(
                isDestructive ?
                Color.red.opacity(0.7) :
                    (isPrimary ? type.accentColor.opacity(0.8) : Color.black.opacity(0.3))
            )
            .foregroundColor(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// Estilo de botão para os níveis de fluxo
struct FlowButtonStyle: ButtonStyle {
    let level: Int
    let isPrimary: Bool
    var isDestructive: Bool = false
    var isFeatureA: Bool = false
    var isFeatureB: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundColor(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        if isDestructive {
            return Color.red.opacity(isPressed ? 0.7 : 1)
        }
        
        if isFeatureA {
            return Color.blue.opacity(isPressed ? 0.7 : 0.9)
        }
        
        if isFeatureB {
            return Color.purple.opacity(isPressed ? 0.7 : 0.9)
        }
        
        if isPrimary {
            switch level % 5 {
            case 0: return .blue.opacity(isPressed ? 0.6 : 0.8)
            case 1: return .purple.opacity(isPressed ? 0.6 : 0.8)
            case 2: return .orange.opacity(isPressed ? 0.6 : 0.8)
            case 3: return .green.opacity(isPressed ? 0.6 : 0.8)
            case 4: return .indigo.opacity(isPressed ? 0.6 : 0.8)
            default: return .gray.opacity(isPressed ? 0.6 : 0.8)
            }
        } else {
            return Color.black.opacity(isPressed ? 0.2 : 0.3)
        }
    }
}
