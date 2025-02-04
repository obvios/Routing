import SwiftUI

public struct RoutingView<Content: View, Destination: Routable>: View {
    @StateObject var router: Router<Destination> = .init(isPresented: .constant(.none))
    private let rootContent: (Router<Destination>) -> Content
    private let handleDeepLink: ((URL) -> Destination?)?
    
    public init(_ routeType: Destination.Type,
                @ViewBuilder content: @escaping (Router<Destination>) -> Content,
                handleDeepLink: ((URL) -> Destination?)? = nil) {
        self.rootContent = content
        self.handleDeepLink = handleDeepLink
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            rootContent(router)
                .navigationDestination(for: Destination.self) { route in
                    router.view(for: route)
                }
        }
        .sheet(item: $router.presentingSheet) { route in
                router.view(for: route)
        }
        .fullScreenCover(item: $router.presentingFullScreenCover) { route in
                router.view(for: route)
        }
        .onOpenURL { url in
            if let destination = handleDeepLink?(url) {
                // Dismiss any modals before routing
                if router.presentingSheet != nil {
                    router.dismiss()
                }
                if router.presentingFullScreenCover != nil {
                    router.dismiss()
                }
                
                router.routeTo(destination)
            }
        }
    }
}
