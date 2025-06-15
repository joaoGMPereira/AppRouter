import SwiftUI

/// View para demonstrar o uso do RoutingView com fluxos complexos
struct ValidatingRouterView: View {
    @Environment(AppRouter.self) private var appRouter
    @State private var logMessages: [String] = []
    @State private var showRoutersList: Bool = false
    let id = String(describing: RouterDebugRoute.self)
    var body: some View {
        if let routerDebug: Router<RouterDebugRoute> = appRouter.router(forKey: id) {
            // Usamos o RoutingView para gerenciar a navegação
            RoutingView(router: routerDebug) {
                ZStack {
                    // Fundo gradiente
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Teste com RoutingView")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top, 40)
                            
                            Text("Esta view utiliza o RoutingView para gerenciar a navegação, permitindo que a stack seja mantida mesmo com dismiss de sheets.")
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            
                            // Botões de teste
                            VStack(spacing: 16) {
                                Button("Execute Complex Flow with Multiple Routers") {
                                    executeComplexFlowWithMultipleRouters()
                                }
                                .buttonStyle(DebugFlowButtonStyle())
                                
                                Button("Present Feature A Sheet") {
                                    // Criar um router específico para a feature A
                                    let featureAId = "routerFeatureA-\(UUID().uuidString.prefix(4).description)"
                                    let routerFeatureA = Router<RouterDebugRoute>(featureAId)
                                    appRouter.register(routerFeatureA)
                                    
                                    // Apresentar a feature A usando o router principal
                                    routerDebug.present(
                                        sheet: .featureA(
                                            id: featureAId,
                                            previousId: id,
                                            level: 1
                                        )
                                    )
                                    addLog("Presenting Feature A as Sheet with dedicated router")
                                }
                                .buttonStyle(DebugFlowButtonStyle(type: .featureA))
                                
                                Button("Present Feature B Sheet") {
                                    // Criar um router específico para a feature B
                                    let featureBId = "routerFeatureB-\(UUID().uuidString.prefix(4).description)"
                                    let routerFeatureB = Router<RouterDebugRoute>(featureBId)
                                    appRouter.register(routerFeatureB)
                                    
                                    // Apresentar a feature B usando o router principal
                                    routerDebug.present(
                                        sheet: .featureB(
                                            id: featureBId,
                                            previousId: id,
                                            level: 1
                                        )
                                    )
                                    addLog("Presenting Feature B as Sheet with dedicated router")
                                }
                                .buttonStyle(DebugFlowButtonStyle(type: .featureB))
                                
                                Button("List Registered Routers") {
                                    showRoutersList.toggle()
                                    if showRoutersList {
                                        addLog("Showing list of registered routers")
                                    }
                                }
                                .buttonStyle(DebugFlowButtonStyle())
                                
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                    .padding(.vertical, 8)
                                
                                Button("Reset Navigation") {
                                    resetNavigation()
                                }
                                .buttonStyle(DebugFlowButtonStyle(type: .reset))
                            }
                            .padding(.horizontal, 40)
                            
                            // List of registered routers (only shown when showRoutersList is true)
                            if showRoutersList {
                                RegisteredRoutersListView(
                                    id: id,
                                    backgroundColor: Color.black.opacity(0.2),
                                    titleColor: .white,
                                    maxHeight: 150
                                )
                                .padding(.horizontal, 20)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut, value: showRoutersList)
                            }
                            
                            Spacer()
                            
                            // Log de operações
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Operations Log")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(logMessages.indices.prefix(10), id: \.self) { index in
                                            Text("\(index + 1). \(logMessages[index])")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(height: 100)
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        } else {
            VStack {
                Text("Router Debug não encontrado")
                    .foregroundColor(.red)
                    .padding()
                
                Button("Registrar Router Debug") {
                    let routerDebug = Router<RouterDebugRoute>(id)
                    appRouter.register(routerDebug)
                    
                    // Forçar a recriação da view
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Fluxos
    
    /// Executa um fluxo complexo com múltiplos routers independentes
    private func executeComplexFlowWithMultipleRouters() {
        guard let routerDebug: Router<RouterDebugRoute> = appRouter.router(forKey: id) else {
            addLog("❌ Debug router not found")
            return
        }
        
        // ID de base para facilitar tracking
        let baseId = UUID().uuidString.prefix(4).description
        
        // Passo 1: Criar router para Feature A e registrá-lo
        let featureARouterId = "routerFeatureA-\(baseId)-1"
        let routerFeatureA = Router<RouterDebugRoute>(featureARouterId)
        appRouter.register(routerFeatureA)
        addLog("Flow: Step 1 - Router for Feature A created (\(featureARouterId))")
        
        // Passo 2: Apresentar Feature A como sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            routerDebug.present(
                sheet: .featureA(
                    id: featureARouterId,
                    previousId: id,
                    level: 1
                )
            )
            self.addLog("Flow: Step 2 - Feature A presented as sheet")
            
            // Passo 3: Navegar dentro da Feature A usando seu router específico
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                routerFeatureA.navigate(
                    to: .featureA(
                        id: featureARouterId,
                        previousId: id,
                        level: 2
                    )
                )
                self.addLog("Flow: Step 3 - Navigation within Feature A (Level 2)")
                
                // Passo 4: Continuar navegação dentro da Feature A
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    routerFeatureA.navigate(
                        to: .featureA(
                            id: featureARouterId,
                            previousId: id,
                            level: 3
                        )
                    )
                    self.addLog("Flow: Step 4 - Navigation within Feature A (Level 3)")
                    
                    // Passo 5: Criar um novo router para Feature B
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let featureBRouterId = "routerFeatureB-\(baseId)-1"
                        let routerFeatureB = Router<RouterDebugRoute>(featureBRouterId)
                        self.appRouter.register(routerFeatureB)
                        self.addLog("Flow: Step 5 - Router for Feature B created (\(featureBRouterId))")
                        
                        // Passo 6: Apresentar Feature B como sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            routerFeatureA.present(
                                sheet: .featureB(
                                    id: featureBRouterId,
                                    previousId: featureARouterId,
                                    level: 1
                                )
                            )
                            self.addLog("Flow: Step 6 - Feature B presented as sheet")
                            
                            // Passo 7: Navegar dentro da Feature B usando seu router específico
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                routerFeatureB.navigate(
                                    to: .featureB(
                                        id: featureBRouterId,
                                        previousId: featureARouterId,
                                        level: 2
                                    )
                                )
                                self.addLog("Flow: Step 7 - Navigation within Feature B (Level 2)")
                                
                                // Passo 8: Continuar navegação dentro da Feature B
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    routerFeatureB.navigate(
                                        to: .featureB(
                                            id: featureBRouterId,
                                            previousId: featureARouterId,
                                            level: 3
                                        )
                                    )
                                    self.addLog("Flow: Step 8 - Navigation within Feature B (Level 3)")
                                    
                                    self.addLog("✅ Fluxo complexo com múltiplos routers concluído!")
                                    
                                    // Listar routers registrados ao final do fluxo
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.listRegisteredRouters()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Lista todos os routers registrados no AppRouter
    private func listRegisteredRouters() {
        let routerKeys = appRouter.routers.keys.sorted()
        
        addLog("=== Registered Routers (\(routerKeys.count)) ===")
        for key in routerKeys {
            addLog("- \(key)")
        }
        addLog("===================================")
    }
    
    /// Reseta a navegação e remove routers secundários
    private func resetNavigation() {
        appRouter.resetAllNavigation()
        showRoutersList = false
        // Listar routers após reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.listRegisteredRouters()
        }
    }
    
    /// Adiciona uma mensagem ao log
    private func addLog(_ message: String) {
        logMessages.insert(message, at: 0)
        if logMessages.count > 100 {
            logMessages = Array(logMessages.prefix(100))
        }
    }
}

// Style para botões de debug
struct DebugFlowButtonStyle: ButtonStyle {
    enum ButtonType {
        case standard, featureA, featureB, reset
    }
    
    let type: ButtonType
    
    init(type: ButtonType = .standard) {
        self.type = type
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(backgroundColor(configuration: configuration))
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
    
    private func backgroundColor(configuration: Configuration) -> Color {
        let baseColor: Color
        
        switch type {
        case .standard:
            baseColor = Color.indigo
        case .featureA:
            baseColor = Color.blue
        case .featureB:
            baseColor = Color.purple
        case .reset:
            baseColor = Color.red
        }
        
        return configuration.isPressed ? baseColor.opacity(0.8) : baseColor
    }
}
