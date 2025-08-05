import SwiftUI

/// Protocolo que define a funcionalidade básica de um router para ser gerenciado pelo AppRouter
@MainActor
public protocol ManagedRouter: AnyObject {
    static var key: String { get }
    
    var id: String { get }
    
    /// Verifica se o router está apresentando algum conteúdo.
    var isPresenting: Bool { get }
    
    var dismissCallback: ((_ routerId: String) -> Void)? { get set }
    
    /// Limpa todas as rotas e retorna ao estado inicial.
    func reset()
    func dismiss()
}

/// Extensão para permitir que Router<T> seja gerenciado pelo AppRouter
extension Router: ManagedRouter {
    public func reset() {
        navigateToRoot()
        dismissPresented()
    }
    
    public func dismiss() {
        navigateToRoot()
        dismissCallback?(id)
    }
    
    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreen != nil || !stack.isEmpty
    }
}

/// Extensão para permitir que TabRouter<T> seja gerenciado pelo AppRouter
extension TabRouter: ManagedRouter {
    public func dismiss() {
        // not implemented
    }
    
    public func reset() {
        // not implemented
    }
    
    public var isPresenting: Bool {
        // TabRouter sempre está apresentando algo (a tab selecionada)
        return true
    }
}
