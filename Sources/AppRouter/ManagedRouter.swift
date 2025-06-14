import SwiftUI

/// Protocolo que define a funcionalidade básica de um router para ser gerenciado pelo AppRouter
public protocol ManagedRouter: AnyObject {
    /// Limpa todas as rotas e retorna ao estado inicial.
    func reset()
    
    var id: String { get }
    
    /// Verifica se o router está apresentando algum conteúdo.
    var isPresenting: Bool { get }
    
    var dismiss: ((_ routerId: String) -> Void)? { get set }
}

/// Extensão para permitir que Router<T> seja gerenciado pelo AppRouter
extension Router: ManagedRouter {
    public func reset() {
        navigateToRoot()
        dismissPresented()
    }
    
    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreen != nil || !stack.isEmpty
    }
}

/// Extensão para permitir que TabRouter<T> seja gerenciado pelo AppRouter
extension TabRouter: ManagedRouter {
    public func reset() {
        // Para TabRouter, apenas definir a tab inicial (assumimos que é a primeira)
        if let allCases = Routes.self as? any CaseIterable.Type,
           let firstCase = allCases.allCases.first as? Routes {
            selectedTab = firstCase
        }
    }
    
    public var isPresenting: Bool {
        // TabRouter sempre está apresentando algo (a tab selecionada)
        return true
    }
}
