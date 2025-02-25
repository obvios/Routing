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
                    router.view(for: route)
                }
        }
        .sheet(item: $router.presentingSheet) { route in
            RoutingView(router.router(routeType: .sheet)) { childRouter in
                router.view(for: route, using: childRouter)
            }
        }
        .fullScreenCover(item: $router.presentingFullScreenCover) { route in
            RoutingView(router.router(routeType: .fullScreenCover)) { childRouter in
                router.view(for: route, using: childRouter)
            }
        }
    }
}
