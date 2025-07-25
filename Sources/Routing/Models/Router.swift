import SwiftUI

// MARK: - Router (Core)
public class Router<Destination: Routable>: ObservableObject {
    /// Used to programatically control a navigation stack
    @Published var path: NavigationPath = NavigationPath()
    /// Used to present a view using a sheet
    @Published var presentingSheet: Destination?
    /// Used to present a view using a full screen cover
    @Published var presentingFullScreenCover: Destination?
    /// Reference to parent to be able to dismiss
    private weak var parentRouter: Router<Destination>?
    /// Reference to child Router to be able to reference the last router
    private var childRouter: Router<Destination>?

    /// Indicates whether a modal or full-screen presentation is currently active.
    ///
    /// This computed property returns `true` if either a **sheet** or a **full-screen cover**
    /// is currently being presented, meaning the user is viewing a modal screen.
    ///
    /// - Returns: `true` if a sheet or full-screen cover is currently being displayed, otherwise `false`.
    ///
    /// ### Example Usage:
    /// ```swift
    /// let router = Router<ExampleRoute>()
    ///
    /// if router.isPresenting {
    ///     print("A modal is currently being presented")
    /// } else {
    ///     print("No modals are active")
    /// }
    /// ```
    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreenCover != nil
    }

    /// Indicates whether this router is the root (i.e. has no parent).
    public var isRoot: Bool {
        parentRouter == nil
    }

    /// Indicates whether this router has an active child router.
    public var hasChild: Bool {
        childRouter != nil
    }

    /// Indicates whether the router is at the root with no path and no modal presentation.
    public var isFullyAtRoot: Bool {
        isRoot && path.isEmpty && !isPresenting
    }

    /// Initializes a new router with an optional reference to a parent router.
    public init(parentRouter: Router<Destination>? = nil) {
        self.parentRouter = parentRouter
    }
}

// MARK: - Helper Properties
extension Router {

    /// Resolves the appropriate router based on the given navigation target.
    private func targetRouter(for target: NavigationTarget) -> Router {
        switch target {
        case .current: self
        case .deepest: deepestChildRouter ?? self
        case .root: rootRouter
        case .parent: parentRouter ?? self
        case .child: childRouter ?? self
        }
    }

    /// Returns the deepest (last) child router in the hierarchy, if any.
    private var deepestChildRouter: Router? {
        var current = self
        while let next = current.childRouter {
            current = next
        }
        return current === self ? nil : current
    }

    /// Returns the top-most parent router in the hierarchy (the root).
    private var rootRouter: Router {
        var current = self
        while let parent = current.parentRouter {
            current = parent
        }
        return current
    }
}

// MARK: - View Handling
extension Router {
    /// Returns the initial view for a `RoutingView` based on the provided `Destination`.
    ///
    /// This method is used to set up the **root view** for a `RoutingView` by returning the corresponding
    /// SwiftUI `View` associated with the given `Destination`. It ensures that the view is properly configured
    /// with the router instance, enabling navigation actions within the routing hierarchy.
    ///
    /// - Parameter route: The initial `Destination` that defines the view to be displayed.
    /// - Returns: The SwiftUI `View` associated with the specified `Destination`, wrapped in `@ViewBuilder`.
    ///
    /// ### Example Usage:
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         RoutingView(ExampleRoute.self) { router in
    ///             router.start(.home) // Sets the initial view for RoutingView
    ///         }
    ///     }
    /// }
    /// ```
    @ViewBuilder public func start(_ route: Destination) -> Destination.ViewType {
        route.viewToDisplay(router: self)
    }
    
    /// Returns the view associated with the specified `Routable`.
    /// Used when a child Router is being provided.
    @ViewBuilder func view(for route: Destination, using router: Router<Destination>) -> Destination.ViewType {
        route.viewToDisplay(router: router)
    }
}

extension Router {
    /// Returns the appropriate Router instance based
    /// on `NavigationType`
    func routerFor(routeType: NavigationType) -> Router {
        switch routeType {
        case .push:
            return self
        case .fullScreenCover:
            let child = Router(parentRouter: self)
            childRouter = child
            return child
        case .sheet:
            let child = Router(parentRouter: self)
            childRouter = child
            return child
        }
    }
}

// MARK: - Navigation Functions
extension Router {
    /// Routes to the specified `Destination` using the given `NavigationType` and `NavigationTarget`.
    ///
    /// - Parameters:
    ///   - route: The `Destination` to navigate to.
    ///   - navigationType: The `NavigationType` to use for presenting the destination.
    ///      - `.push` → Pushes the destination onto the navigation stack.
    ///      - `.sheet` → Presents the destination as a modal sheet.
    ///      - `.fullScreenCover` → Presents the destination as a full-screen cover.
    ///   - target: The `NavigationTarget` that determines which router instance should handle the navigation.
    ///      - `.current` → Uses the current router instance.
    ///      - `.parent` → Routes through the parent router, if any.
    ///      - `.child` → Routes through the child router, if any.
    ///      - `.root` → Routes through the root-most router in the hierarchy.
    ///      - `.deepest` → Routes through the deepest active child router in the hierarchy.
    ///
    /// ### Example Usage:
    /// ```swift
    /// struct ContentView: View {
    ///     @StateObject var router = Router<ExampleRoute>()
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Go to Details (Push)") {
    ///                 router.routeTo(.details(id: "123"), via: .push) // Pushes onto the navigation stack
    ///             }
    ///
    ///             Button("Go to Settings (Sheet)") {
    ///                 router.routeTo(.settings, via: .sheet) // Presents as a sheet
    ///             }
    ///
    ///             Button("Go to Profile (Full Screen)") {
    ///                 router.routeTo(.profile, via: .fullScreenCover) // Presents as full-screen
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    public func routeTo(_ route: Destination, via navigationType: NavigationType, target: NavigationTarget = .current) {
        switch navigationType {
        case .push:
            push(route, target: target)
        case .sheet:
            presentSheet(route, target: target)
        case .fullScreenCover:
            presentFullScreen(route, target: target)
        }
    }
    
    /// Removes one or more views from the navigation stack.
    ///
    /// This method removes the most recently pushed views from the `NavigationPath`,
    /// effectively navigating back one or more screens in the navigation hierarchy.
    ///
    /// - If the navigation stack is **not empty**, the specified number of views are removed.
    /// - If the requested number exceeds available views, all remaining views are removed.
    /// - If the stack is already empty, calling this method has no effect.
    /// - If a negative value is provided, the method does nothing.
    ///
    /// - Parameter last: The number of views to pop from the stack. Defaults to 1.
    /// - Note: This method only affects **push-based navigation** and does not dismiss modals.
    ///
    /// ### Example Usage:
    /// ```swift
    /// struct ViewA: View {
    ///     @EnvironmentObject var router: Router<AppRoute>
    ///
    ///     var body: some View {
    ///         VStack {
    ///             // Go back one screen
    ///             Button("Back") { router.pop() }
    ///
    ///             // Go back three screens (or as many as available)
    ///             Button("Back to Main") { router.pop(last: 3) }
    ///         }
    ///     }
    /// }
    /// ```
    public func pop(last: Int = 1) {
        guard !path.isEmpty else { return }
        path.removeLast(min(last, path.count))
    }
    
    /// Pop to the root screen. Removes all views from navigation stack.
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    /// Replaces entire navigation stack `path` with new stack path.
    public func replaceNavigationStack(with newStack: [Destination]) {
        path = .init(newStack)
    }
    
    /// Dismisses the currently presented modal (sheet or full-screen cover).
    ///
    /// This method clears both `presentingSheet` and `presentingFullScreenCover`,
    /// ensuring any active modal presentation is dismissed.
    ///
    /// - Note: SwiftUI only allows one modal presentation at a time, so typically only one of these will be non-nil.
    ///
    /// ### Example Usage:
    /// ```swift
    /// struct ContentView: View {
    ///     @StateObject var router = Router<ExampleRoute>()
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Close") {
    ///                 router.dismissChild() // Dismisses the current presentation
    ///             }
    ///         }
    ///     }
    /// }
    public func dismissChild() {
        presentingSheet = nil
        presentingFullScreenCover = nil
        childRouter = nil
    }
    
    /// Dismisses the router itself if it was presented by a parent.
    ///
    /// Calling this method will result in the entire view hierarchy managed by this instance to be dismissed.
    /// This results in the view hierarchy returning to the previous `Router`'s one.
    ///
    /// - Note: This method does **not** dismiss presented sheets or full-screen covers.
    /// Use `dismissChild()` to dismiss child presentations.
    ///
    /// ### Example Usage:
    /// ```swift
    /// struct ContentView: View {
    ///     @StateObject var router = Router<ExampleRoute>()
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Close Self") {
    ///                 router.dismissSelf() // Requests parent to dismiss this router and its presentations
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    public func dismissSelf() {
        dismissChild() // Dismiss any presented sheet or full-screen modal first
        parentRouter?.dismissChild()
    }

    /// Dismisses entire hierarchy
    public func dismissAllFromRoot() {
        rootRouter.dismissChild()
        rootRouter.popToRoot()
    }

    /// Pushes a route onto the navigation stack of the specified target router.
    private func push(_ appRoute: Destination, target: NavigationTarget) {
        targetRouter(for: target).path.append(appRoute)
    }

    /// Presents a route as a sheet on the specified target router.
    private func presentSheet(_ route: Destination, target: NavigationTarget) {
        targetRouter(for: target).presentingSheet = route
    }

    /// Presents a route as a full screen cover on the specified target router.
    private func presentFullScreen(_ route: Destination, target: NavigationTarget) {
        targetRouter(for: target).presentingFullScreenCover = route
    }
}
