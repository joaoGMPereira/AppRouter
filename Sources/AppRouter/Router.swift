import SwiftUI

/// Define os tipos de apresentação suportados pelo Router
public enum PresentationType {
    case destination
    case sheet
    case fullScreenCover
}

@Observable
public final class Router<Routes: Routable>: RoutableObject {
    public typealias Destination = Routes

    // Navegação em pilha
    public var stack: [Routes] = []
    
    // Apresentações modais
    public var presentingSheet: Routes?
    public var presentingFullScreen: Routes?
    
    public let id: String
    
    public var dismiss: ((_ routerId: String) -> Void)?

    public init(_ id: String) {
        self.id = id
    }
}

public protocol Routable: View & Hashable & Identifiable {
    var id: String { get }
}
