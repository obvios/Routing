import SwiftUI

public class Router<Destination: Route>: ObservableObject {
    /// Used to programatically control a navigation stack
    @Published var path: NavigationPath = NavigationPath()
    /// Used to present a view using a sheet
    @Published var presentingSheet: Destination?
    /// Used to present a view using a full screen cover
    @Published var presentingFullScreenCover: Destination?
    /// Used by presented Router instances to dismiss themselves
    @Published var isPresented: Binding<Destination?>
    var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreenCover != nil
    }
    
    init(isPresented: Binding<Destination?>) {
        self.isPresented = isPresented
    }
    
    /// Returns the view associated with the specified `Route`
    @ViewBuilder func view(for route: Destination) -> some View {
        route.viewToDisplay(router: router(routeType: route.routeType))
    }
    
    /// Routes to the specified `Route`.
    func routeTo(_ route: Destination) {
        switch route.routeType {
        case .push:
            push(route)
        case .sheet:
            presentSheet(route)
        case .fullScreenCover:
            presentFullScreen(route)
        }
    }
    
    // Pop to the root screen in our hierarchy
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // Dismisses presented screen or self
    func dismiss() {
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
    // on `RouteType`
    private func router(routeType: RouteType) -> Router {
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
