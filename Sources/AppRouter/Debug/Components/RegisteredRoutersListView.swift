import SwiftUI

/// A view component that displays a list of all registered routers in the AppRouter
struct RegisteredRoutersListView: View {
    // Environment
    @Environment(AppRouter.self) private var appRouter
    
    // State
    @State private var registeredRouters: [String] = []
    let id: String
    
    // Custom styling
    var backgroundColor: Color = Color.black.opacity(0.2)
    var titleColor: Color = .white
    var routerTextColor: Color = .white.opacity(0.8)
    var maxHeight: CGFloat? = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with title and refresh button
            HStack {
                Text("Registered Routers (\(registeredRouters.count))")
                    .font(.headline)
                    .foregroundColor(titleColor)
                
                Spacer()
                
                Button(action: {
                    updateRoutersList()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(titleColor)
                }
            }
            
            // Scrollable list of routers
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(registeredRouters, id: \.self) { routerKey in
                        HStack(spacing: 8) {
                            // Visual indicator for selected router
                            Circle()
                                .fill(isCurrentRouter(routerKey) ? Color.green : Color.white.opacity(0.6))
                                .frame(width: 8, height: 8)
                            
                            // Router name/id
                            Text(routerKey)
                                .font(.caption)
                                .foregroundColor(isCurrentRouter(routerKey) ? Color.white : routerTextColor)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                        .cornerRadius(4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: maxHeight)
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
        }
        .onAppear {
            updateRoutersList()
        }
    }
    
    /// Updates the list of registered routers
    private func updateRoutersList() {
        registeredRouters = appRouter.routers.keys.sorted()
    }
    
    /// Checks if the specified router is the currently selected one
    private func isCurrentRouter(_ routerKey: String) -> Bool {
        return routerKey == id
    }
}
