import SwiftUI

public struct RoutingView<Root: View, Routes: Routable>: View {
    // Bindings para o estado de navegação
    var router: Router<Routes>
    @Binding private var routes: [Routes]
    @Binding private var presentingSheet: Routes?
    @Binding private var presentingFullScreen: Routes?
    
    private let root: () -> Root
    /// Initializes a new instance of `RoutingView` with a router and root view.
    ///
    /// - Parameters:
    ///   - router: The router that manages the navigation state.
    ///   - root: A closure that returns the root view of the navigation stack.
    public init(
        router: Router<Routes>,
        @ViewBuilder root: @escaping () -> Root
    ) where Routes: Routable {
        self.router = router
        self._routes = Binding(
            get: { router.stack },
            set: { router.stack = $0 }
        )
        self._presentingSheet = Binding(
            get: { router.presentingSheet },
            set: { router.presentingSheet = $0 }
        )
        self._presentingFullScreen = Binding(
            get: { router.presentingFullScreen },
            set: { router.presentingFullScreen = $0 }
        )
      //  self.id = router.id
        self.root = root
    }

    /// The body of the `RoutingView`. This view contains the navigation logic and view mapping based on the current state of the `routes` array.
    ///
    /// It uses a `NavigationStack` to present the root view and navigates to other views based on the `Routes` enum.
    public var body: some View {
        NavigationStack(path: $routes) {
            root()
                .navigationDestination(for: Routes.self) { view in
                    view
                    .toolbar(.hidden, for: .tabBar)
                }
        }
        .sheet(item: $presentingSheet) { view in
            view
        }
        .fullScreenCover(item: $presentingFullScreen) { view in
            view
        }
        .onChange(of: presentingSheet) { oldValue, newValue in
            if newValue == nil {
                if let routable = oldValue {
                    router.dismissCallback?(routable.id)
                }
            }
        }
        .onChange(of: presentingFullScreen) { oldValue, newValue in
            if newValue == nil {
                if let routable = oldValue {
                    router.dismissCallback?(routable.id)
                }
            }
        }
    }
}
