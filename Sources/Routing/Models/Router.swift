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
    
    init(isPresented: Binding<Destination?>) {
        self.isPresented = isPresented
    }
    
    /// Returns the view associated with the specified `Routable`
    @ViewBuilder public func view(for route: Destination) -> some View {
        route.viewToDisplay(router: router(routeType: route.navigationType))
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
    
    // Pop to the root screen in our hierarchy
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    // Dismisses presented screen or self
    public func dismiss() {
        if !path.isEmpty {
            path.removeLast()
        } else if presentingSheet != nil {
            presentingSheet = nil
        } else if presentingFullScreenCover != nil {
            presentingFullScreenCover = nil
        } else {
            isPresented.wrappedValue = nil
        }
    }
    
    // Used by views to navigate to another view
    private func push(_ appRoute: Destination) {
        path.append(appRoute)
    }
    
    // Used to present a screen using a sheet
    private func presentSheet(_ route: Destination) {
        self.presentingSheet = route
    }
    
    // Used to present a screen using a full screen cover
    private func presentFullScreen(_ route: Destination) {
        self.presentingFullScreenCover = route
    }
    
    // Return the appropriate Router instance based
    // on `NavigationType`
    private func router(routeType: NavigationType) -> Router {
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
