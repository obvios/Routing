//
//  File.swift
//  Routing
//
//  Created by Eric Palma on 2/5/25.
//

import SwiftUI

struct DeepLinkModifier<Destination: Routable>: ViewModifier {
    let router: Router<Destination>
    let handleDeepLink: (URL) -> Destination?

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                if let destination = handleDeepLink(url) {
                    // Dismiss active modals before routing
                    if router.isPresenting {
                        router.dismissChild()
                    }

                    // Navigate to the deep link destination
                    router.routeTo(destination, via: .sheet)
                }
            }
    }
}
