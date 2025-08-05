import SwiftUI

/// O AppRouter é responsável por centralizar todos os routers do aplicativo,
/// permitindo um gerenciamento global da navegação e do estado.
@Observable
@MainActor
public final class AppRouter {
    // Armazena todos os routers registrados por tipo
    var routers: [String: ManagedRouter] = [:]
    
    // Propriedades de conveniência para os routers principais usando type erasure
    private(set) var mainTabRouter: ManagedRouter
    private(set) var mainBaseRouters: [ManagedRouter]
    
    public var presentedRouters: [(any RoutableObject)] = []
    
    /// Inicializa uma nova instância do AppRouter.

    public init(
        tabRouter: ManagedRouter,
        baseRouters: [ManagedRouter]
    ) {
        // Inicializamos os routers padrão do aplicativo
        self.mainTabRouter = tabRouter
        self.mainBaseRouters = baseRouters
        register(tabRouter)
        baseRouters.forEach { router in
            register(router)
        }
    }
    
    /// Registra um router para ser gerenciado pelo AppRouter.
    /// - Parameters:
    ///   - router: O router a ser registrado.
    ///   - key: A chave única para identificar este router.
    public func register<T: ManagedRouter>(_ router: T) {
        if let routableObject = router as? (any RoutableObject) {
            routableObject.appRouter = self
        }
        router.dismissCallback = { [weak self] dismissedRouterId in
                self?.unregister(key: dismissedRouterId)
        }
        routers[router.id] = router
    }
    
    /// Registra um router para ser gerenciado pelo AppRouter.
    /// - Parameters:
    ///   - key: A chave única para identificar este router.
    private func unregister(key: String) {
        routers.removeValue(forKey: key)
    }
    
    /// Recupera um router previamente registrado.
    /// - Parameter key: A chave do router.
    /// - Returns: O router, se existir, ou nil caso contrário.
    public func router<T: ManagedRouter>(forKey customKey: String? = nil) -> T? {
        return routers[customKey ?? T.key] as? T
    }
    
    /// Retorna o router de tabs com o tipo específico
    public func tabRouter<Tab: TabRoutable>() -> TabRouter<Tab>! {
        return (mainTabRouter as! TabRouter<Tab>)
    }
    
    /// Retorna um router base específico pelo índice
    public func baseRouter<Route: Routable>(at index: Int) -> Router<Route>? {
        guard index >= 0, index < mainBaseRouters.count else { return nil }
        return mainBaseRouters[index] as? Router<Route>
    }
    
    /// Retorna um router base específico pelo índice
    public func baseRouter<Route: Routable>(forKey customKey: String? = nil) -> Router<Route>? {
        return mainBaseRouters.first(where: { $0.id == customKey ?? Route.key }) as? Router<Route>
    }
    
    /// Retorna todos os routers base com o tipo específico
    public func baseRouters<Route: Routable>() -> [Router<Route>] {
        return mainBaseRouters.compactMap { $0 as? Router<Route> }
    }
    
    /// Limpa todas as rotas de todos os routers registrados.
    public func resetAllNavigation() {
        let localRouters = routers
        localRouters.forEach { key, value in
            if mainBaseRouters.contains(where: { $0.id == key }) == false  {
                routers.removeValue(forKey: key)
            }
        }
    }
    
    /// Limpa as rotas de um router específico.
    /// - Parameter key: A chave do router a ser resetado.
    public func resetNavigation(forKey key: String) {
        if let router = routers[key] {
            router.reset()
        }
    }
    
    /// Verifica se algum router está apresentando conteúdo.
    var isPresenting: Bool {
        var isPresenting = false
        mainBaseRouters.forEach { router in
           let routerIsBeingPresented = router.isPresenting
            if routerIsBeingPresented {
                isPresenting = routerIsBeingPresented
            }
        }
        return isPresenting || routers.values.contains { $0.isPresenting }
    }
    
    /// Verifica se um router específico está apresentando conteúdo.
    /// - Parameter key: A chave do router.
    /// - Returns: `true` se o router está apresentando conteúdo, caso contrário `false`.
    public func isPresenting(forKey key: String) -> Bool {
        if let router = routers[key] {
            return router.isPresenting
        }
        return false
    }
    
    public func dismissTop() {
        presentedRouters.last?.dismissPresented()
        _ = presentedRouters.dropLast()
        print(presentedRouters)
    }
}
