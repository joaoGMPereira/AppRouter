import SwiftUI

public protocol RoutableObject: AnyObject {
    /// The type of the destination views in the navigation stack. Must conform to `Routable`.
    associatedtype Destination: Routable
    
    var appRouter: AppRouter? { get set }

    /// An array representing the current navigation stack of destinations.
    /// Modifying this stack updates the navigation state of the application.
    var stack: [Destination] { get set }
    
    /// A destination being presented as a sheet.
    var presentingSheet: Destination? { get set }
    
    /// A destination being presented as a full screen cover.
    var presentingFullScreen: Destination? { get set }

    /// Navigate back in the navigation stack by a specified number of destinations.
    ///
    /// - Parameter count: The number of destinations to navigate back by.
    /// If the count exceeds the number of destinations in the stack, the stack is emptied.
    func navigateBack(_ count: Int)

    /// Navigate back to a specific destination in the stack, removing all destinations that come after it.
    ///
    /// - Parameter destination: The destination to navigate back to.
    /// If the destination does not exist in the stack, no action is taken.
    func navigateBack(to destination: Destination)

    /// Resets the navigation stack to its initial state, effectively navigating to the root destination.
    func navigateToRoot()

    /// Appends a new destination to the navigation stack, moving forward in the navigation flow.
    ///
    /// - Parameter destination: The destination to navigate to.
    func navigate(to destination: Destination)

    /// Appends multiple new destinations to the navigation stack.
    ///
    /// - Parameter destinations: An array of destinations to append to the navigation stack.
    func navigate(to destinations: [Destination])

    /// Replaces the current navigation stack with a new set of destinations.
    ///
    /// - Parameter destinations: An array of new destinations to set as the navigation stack.
    func replace(with destinations: [Destination])
    
    /// Present a destination as a sheet.
    ///
    /// - Parameter destination: The destination to present as a sheet.
    func present(sheet destination: Destination)
    
    /// Present a destination as a full screen cover.
    ///
    /// - Parameter destination: The destination to present as a full screen cover.
    func present(fullScreen destination: Destination)
    
    /// Dismiss any presented destinations (sheet or fullscreen).
    func dismissPresented()
}

extension RoutableObject {
    public func navigateBack(_ count: Int = 1) {
        guard count > 0 else { return }
        guard count <= stack.count else {
            stack = .init()
            return
        }
        stack.removeLast(count)
    }

    public func navigateBack(to destination: Destination) {
        // Check if the destination exists in the stack
        if let index = stack.lastIndex(where: { $0 == destination }) {
            // Remove destinations above the specified destination
            stack.truncate(to: index)
        }
    }

    public func navigateToRoot() {
        stack = []
    }

    public func navigate(to destination: Destination) {
        stack.append(destination)
    }

    public func navigate(to destinations: [Destination]) {
        stack += destinations
    }

    public func replace(with destinations: [Destination]) {
        stack = destinations
    }
    
    @MainActor
    public func present(sheet destination: Destination) {
        presentingSheet = destination
        appRouter?.presentedRouters.append(self)
    }
    
    @MainActor
    public func present(fullScreen destination: Destination) {
        presentingFullScreen = destination
        appRouter?.presentedRouters.append(self)
    }
    
    public func dismissPresented() {
        if presentingSheet != nil {
            presentingSheet = nil
        } else if presentingFullScreen != nil {
            presentingFullScreen = nil
        }
    }
}
