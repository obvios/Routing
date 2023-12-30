import SwiftUI

class Router<Destination: Route>: ObservableObject {
    // Used to programatically control a navigation stack
    @Published var path: NavigationPath = NavigationPath()
    // Used to present a view using a sheet
    @Published var presentingSheet: Destination?
    // Used to present a view using a full screen cover
    @Published var presentingFullScreenCover: Destination?
    // Used for presented Router instances to dissmiss
    // themselves
    @Published var isPresented: Binding<Destination?>
    
    init(isPresented: Binding<Destination?>) {
        self.isPresented = isPresented
    }
    
    // Builds the views
    @ViewBuilder func view(for route: Destination) -> some View {
        route.viewToDisplay(router: router(navigationType: route.navigationType))
    }
    
    func routeTo(_ route: Destination) {
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
    // on `NavigationType`
    private func router(navigationType: NavigationType) -> Router {
        switch navigationType {
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
