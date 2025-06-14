import SwiftUI

/// Painel principal que reúne todas as ferramentas de debug do router
struct RouterDebugDashboard: View {
    @Environment(AppRouter.self) private var appRouter
    @State private var debugger = RouterDebugger.shared
    @State private var selectedTab = 0
    @State private var selectedRouter: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header com logo e controles
            HStack {
                Image(systemName: "network")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Router Debug Dashboard")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    debugger.showingDebugView = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(Color.black)
            
            // Tabs para diferentes ferramentas
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: 16))
                            
                            Text(tabs[index].title)
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == index ? Color.white : Color.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTab == index ? Color.blue.opacity(0.3) : Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.black.opacity(0.8))
            
            // Conteúdo da tab selecionada
            TabView(selection: $selectedTab) {
                // Visualizador de Navegação
                // Ferramentas de Teste
                ValidatingRouterView()
                    .tag(0)
                VStack {
                    NavigationVisualizer()
                    
                    if let selectedRouter = selectedRouter {
                        RouterHistoryView(routerKey: selectedRouter)
                    }
                }
                .tag(1)
                
                // Analisador de Router
                RouterAnalyzerView()
                    .tag(2)
                
                // Log de Navegação
                navigationLogView
                    .tag(3)
                

            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(Color.black.opacity(0.95))
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Views
    
    /// View para o log de navegação
    private var navigationLogView: some View {
        VStack(spacing: 0) {
            // Header com controles
            HStack {
                Text("Navigation Log")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Menu {
                    Button(action: {
                        // Filtrar por tipo
                    }) {
                        Label("Filter by Type", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button(action: {
                        // Filtrar por router
                    }) {
                        Label("Filter by Router", systemImage: "rectangle.on.rectangle")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        debugger.clearNavigationLogs()
                    }) {
                        Label("Clear Logs", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    // Exportar logs
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            
            // Lista de logs
            if debugger.navigationLogs.isEmpty {
                VStack {
                    Spacer()
                    Text("No navigation logs yet")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(debugger.navigationLogs) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: log.type.icon)
                                    .foregroundColor(log.type.color)
                                
                                Text(log.type.rawValue)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(log.type.color)
                                
                                Spacer()
                                
                                Text(log.routerId)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                
                                Text(log.formattedTimestamp)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Text(log.message)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // MARK: - Data
    
    /// Tabs disponíveis no dashboard
    private var tabs: [(title: String, icon: String)] {
        [
            ("Test Tools", "hammer")
        ]
    }
}
