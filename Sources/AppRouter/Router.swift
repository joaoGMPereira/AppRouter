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

    @MainActor
    public init(_ customId: String? = nil) {
        self.id = customId ?? Routes.key
    }
}

public protocol Routable: View & Hashable & Identifiable {
    static var key: String { get }
    var id: String { get }
}
