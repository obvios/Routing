import SwiftUI

public struct RoutingView<Content: View, Destination: Routable>: View where Destination.ViewType == Content {
    @ObservedObject var router: Router<Destination>
    private let rootContent: (Router<Destination>) -> Content
    
    public init(_ router: Router<Destination>,
                @ViewBuilder content: @escaping (Router<Destination>) -> Content) {
        self.router = router
        self.rootContent = content
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            rootContent(router)
                .navigationDestination(for: Destination.self) { route in
                    router.start(route)
                }
        }
        .sheet(item: $router.presentingSheet) { route in
            RoutingView(router.routerFor(routeType: .sheet)) { childRouter in
                childRouter.start(route)
            }
        }
        .fullScreenCover(item: $router.presentingFullScreenCover) { route in
            RoutingView(router.routerFor(routeType: .fullScreenCover)) { childRouter in
                childRouter.start(route)
            }
        }
    }
}
