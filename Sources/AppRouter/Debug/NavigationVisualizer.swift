import SwiftUI

/// Ferramenta para visualizar a hierarquia de navegação dos routers
struct NavigationVisualizer: View {
    @Environment(AppRouter.self) private var appRouter
    @State private var selectedRouter: String? = nil
    @State private var expandedNodes: Set<String> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Navigation Hierarchy")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Reconstruir a visualização
                    selectedRouter = nil
                    expandedNodes.removeAll()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.indigo)
            
            // Visualização da hierarquia
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    // Obter a hierarquia de navegação
                    ForEach(rootRouters, id: \.self) { routerKey in
                        routerNode(key: routerKey, level: 0)
                    }
                }
                .padding()
            }
        }
        .background(Color.black.opacity(0.9))
        .cornerRadius(12)
        .frame(height: 400)
    }
    
    /// Lista de routers que parecem ser routers raiz (não são apresentados por outros)
    private var rootRouters: [String] {
        // Lógica simples: routers que contêm "root" ou "main" no nome,
        // ou o router de debug padrão, são considerados raízes
        return appRouter.routers.keys.filter { key in
            key.contains("root") || 
            key.contains("main") || 
            key == "routerDebug" ||
            !isPresented(routerKey: key)
        }.sorted()
    }
    
    /// Verifica se um router é apresentado por algum outro router
    private func isPresented(routerKey: String) -> Bool {
        // Esta é uma implementação simples. Numa implementação real,
        // precisaríamos rastrear as relações pai-filho entre routers.
        return false
    }
    
    /// Obtém os routers filhos de um determinado router (apresentados por ele)
    private func childRouters(of parentKey: String) -> [String] {
        // Implementação simplificada
        return appRouter.routers.keys.filter { key in
            key.contains(parentKey) && key != parentKey
        }.sorted()
    }
    
    /// Constrói um nó visual para um router na hierarquia
    private func routerNode(key: String, level: Int) -> some View {
        let isExpanded = expandedNodes.contains(key)
        let children = childRouters(of: key)
        let hasChildren = !children.isEmpty
        
        return VStack(alignment: .leading, spacing: 2) {
            Button(action: {
                if hasChildren {
                    if isExpanded {
                        expandedNodes.remove(key)
                    } else {
                        expandedNodes.insert(key)
                    }
                }
                selectedRouter = key
            }) {
                HStack(spacing: 4) {
                    // Indent based on level
                    ForEach(0..<level, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1)
                            .padding(.horizontal, 6)
                    }
                    
                    // Expand/collapse icon
                    if hasChildren {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(width: 16, height: 16)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 16, height: 16)
                    }
                    
                    // Router icon and name
                    Circle()
                        .fill(selectedRouter == key ? Color.blue : Color.gray.opacity(0.6))
                        .frame(width: 10, height: 10)
                    
                    Text(key)
                        .font(.system(size: 14, weight: selectedRouter == key ? .bold : .regular))
                        .foregroundColor(selectedRouter == key ? .white : .gray)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(selectedRouter == key ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
            
            // If expanded, show children
            if isExpanded {
                ForEach(children, id: \.self) { childKey in
                    routerNode(key: childKey, level: level + 1)
                }
            }
        }
    }
}

/// Visualizador de histórico de navegação para um router específico
struct RouterHistoryView: View {
    let routerKey: String
    @Environment(AppRouter.self) private var appRouter
    @State private var debugger = RouterDebugger.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Router History: \(routerKey)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Limpar histórico específico para este router
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.purple)
            
            // Timeline de eventos
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(filteredLogs) { entry in
                        timelineEntry(entry)
                    }
                }
                .padding()
            }
        }
        .background(Color.black.opacity(0.9))
        .cornerRadius(12)
        .frame(height: 300)
    }
    
    private var filteredLogs: [NavigationLogEntry] {
        debugger.navigationLogs.filter { $0.routerId == routerKey }
    }
    
    private func timelineEntry(_ entry: NavigationLogEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline connector
            VStack(spacing: 0) {
                Rectangle()
                    .fill(entry.type.color)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                
                Circle()
                    .fill(entry.type.color)
                    .frame(width: 10, height: 10)
                
                Rectangle()
                    .fill(entry.type.color)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 20)
            
            // Event details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: entry.type.icon)
                        .foregroundColor(entry.type.color)
                    
                    Text(entry.type.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(entry.type.color)
                    
                    Spacer()
                    
                    Text(entry.formattedTimestamp)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Text(entry.message)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Analisador de desempenho e problemas do sistema de navegação
struct RouterAnalyzerView: View {
    @Environment(AppRouter.self) private var appRouter
    @State private var issues: [RouterIssue] = []
    @State private var isAnalyzing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Router Analyzer")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    analyzeRouters()
                }) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        Text(isAnalyzing ? "Analyzing..." : "Analyze")
                    }
                    .foregroundColor(.white)
                }
                .disabled(isAnalyzing)
            }
            .padding()
            .background(Color.orange)
            
            // Lista de problemas encontrados
            if issues.isEmpty {
                VStack {
                    Spacer()
                    Text("No issues found. Run analysis to check for problems.")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(height: 200)
            } else {
                List {
                    ForEach(issues) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: issue.severity.icon)
                                    .foregroundColor(issue.severity.color)
                                
                                Text(issue.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Text(issue.description)
                                .font(.body)
                                .foregroundColor(.gray)
                            
                            if !issue.recommendation.isEmpty {
                                Text("Recommendation: \(issue.recommendation)")
                                    .font(.callout)
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: 300)
            }
        }
        .background(Color.black.opacity(0.9))
        .cornerRadius(12)
    }
    
    private func analyzeRouters() {
        isAnalyzing = true
        issues.removeAll()
        
        // Simular análise (em um app real, faríamos verificações reais aqui)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Exemplo de análises:
            
            // 1. Verificar routers órfãos (sem referência)
            for key in appRouter.routers.keys {
                if key.contains("routerFeature") && !key.contains("Debug") {
                    issues.append(RouterIssue(
                        severity: .warning,
                        title: "Potential orphaned router: \(key)",
                        description: "This router might be orphaned and consuming memory unnecessarily.",
                        recommendation: "Consider removing this router if it's no longer needed."
                    ))
                }
            }
            
            // 2. Verificar routers aninhados excessivamente
            if appRouter.routers.keys.count > 10 {
                issues.append(RouterIssue(
                    severity: .warning,
                    title: "High number of active routers: \(appRouter.routers.keys.count)",
                    description: "Having too many active routers can impact performance.",
                    recommendation: "Consider cleaning up unused routers."
                ))
            }
            
            // Se não encontrou problemas, adicionar uma mensagem positiva
            if issues.isEmpty {
                issues.append(RouterIssue(
                    severity: .info,
                    title: "No issues found",
                    description: "Your navigation system appears to be in good health.",
                    recommendation: ""
                ))
            }
            
            isAnalyzing = false
        }
    }
}

/// Representa um problema detectado no sistema de navegação
struct RouterIssue: Identifiable {
    let id = UUID()
    let severity: IssueSeverity
    let title: String
    let description: String
    let recommendation: String
}

/// Nível de severidade de um problema
enum IssueSeverity {
    case error, warning, info
    
    var color: Color {
        switch self {
        case .error:
            return .red
        case .warning:
            return .yellow
        case .info:
            return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .error:
            return "exclamationmark.triangle.fill"
        case .warning:
            return "exclamationmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
}
