import SwiftUI

public struct RoutingView<Content: View, Destination: Routable>: View where Destination.ViewType == Content {
    @StateObject var router: Router<Destination> = .init(isPresented: .constant(.none))
    private let rootContent: (Router<Destination>) -> Content
    
    public init(_ routeType: Destination.Type,
                @ViewBuilder content: @escaping (Router<Destination>) -> Content,
                handleDeepLink: ((URL) -> Destination?)? = nil) {
        self.rootContent = content
    }
    
    /// Use when presented, gets binding with parent router
    private init(_ router: Router<Destination>,
                presentationType: NavigationType,
                @ViewBuilder content: @escaping (Router<Destination>) -> Content,
                handleDeepLink: ((URL) -> Destination?)? = nil) {
        _router = .init(wrappedValue: router.router(routeType: presentationType))
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
            RoutingView(router, presentationType: .sheet) { childRouter in
                router.view(for: route, using: childRouter)
            }
        }
        .fullScreenCover(item: $router.presentingFullScreenCover) { route in
            RoutingView(router, presentationType: .fullScreenCover) { childRouter in
                router.view(for: route, using: childRouter)
            }
        }
    }
}
