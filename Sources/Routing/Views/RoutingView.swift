import SwiftUI

struct RouterView<Content: View, Destination: Route>: View {
    @StateObject var router: Router<Destination> = .init(isPresented: .constant(.none))
    // Holds our root view content
    private let rootContent: (Router<Destination>) -> Content
    
    init(_ routeType: Destination.Type, @ViewBuilder content: @escaping (Router<Destination>) -> Content) {
        self.rootContent = content
    }
    
    var body: some View {
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
    }
}
