//
//  File.swift
//  Routing
//
//  Created by Eric Palma on 2/5/25.
//

import SwiftUI

public extension View {
    func onDeepLink<Destination: Routable>(
        using router: Router<Destination>,
        _ handleDeepLink: @escaping (URL) -> Destination?) -> some View {
            self.modifier(DeepLinkModifier(
                router: router,
                handleDeepLink: handleDeepLink))
    }
}
