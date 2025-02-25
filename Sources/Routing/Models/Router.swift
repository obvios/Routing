import SwiftUI

public class Router<Destination: Routable>: ObservableObject {
    /// Used to programatically control a navigation stack
    @Published public var path: NavigationPath = NavigationPath()
    /// Used to present a view using a sheet
    @Published public var presentingSheet: Destination?
    /// Used to present a view using a full screen cover
    @Published public var presentingFullScreenCover: Destination?
    /// Used by presented Router instances to dismiss themselves
    @Published public var isPresented: Binding<Destination?>
    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreenCover != nil
    }
    
    public init(isPresented: Binding<Destination?>) {
        self.isPresented = isPresented
    }
    
    /// Call this to start a `RoutingView` with the root view of your routing hierarchy.
    @ViewBuilder public func start(_ route: Destination) -> Destination.ViewType {
        route.viewToDisplay(router: self)
    }
    
    /// Returns the view associated with the specified `Routable`.
    /// Used when a child Router is being provided.
    @ViewBuilder func view(for route: Destination, using router: Router<Destination>) -> Destination.ViewType {
        route.viewToDisplay(router: router)
    }
    
    /// Routes to the specified `Routable`.
    public func routeTo(_ route: Destination) {
        switch route.navigationType {
        case .push:
            push(route)
        case .sheet:
            presentSheet(route)
        case .fullScreenCover:
            presentFullScreen(route)
        }
    }
    
    /// Pop to the root screen. Removes all views from navigation stack
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    /// Replaces entire navigation stack `path` with new stack path.
    public func replaceNavigationStack(with newStack: [Destination]) {
        path = .init(newStack)
    }
    
    /// Dismisses pushed/presented view or self
    public func dismiss() {
        if presentingSheet != nil {
            presentingSheet = nil
        } else if presentingFullScreenCover != nil {
            presentingFullScreenCover = nil
        } else if isPresented.wrappedValue != nil {
            isPresented.wrappedValue = nil
        } else if !path.isEmpty {
            path.removeLast()
        }
    }
    
    private func push(_ appRoute: Destination) {
        path.append(appRoute)
    }
    
    private func presentSheet(_ route: Destination) {
        self.presentingSheet = route
    }
    
    private func presentFullScreen(_ route: Destination) {
        self.presentingFullScreenCover = route
    }
    
    /// Returns the appropriate Router instance based
    /// on `NavigationType`
    func routerFor(routeType: NavigationType) -> Router {
        switch routeType {
        case .push:
            return self
        case .sheet:
            return Router(
                isPresented: Binding(
                    get: { self.presentingSheet },
                    set: { self.presentingSheet = $0 }
                )
            )
        case .fullScreenCover:
            return Router(
                isPresented: Binding(
                    get: { self.presentingFullScreenCover },
                    set: { self.presentingFullScreenCover = $0 }
                )
            )
        }
    }
}
