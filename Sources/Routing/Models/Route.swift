import SwiftUI

enum RouteType {
    case push
    case sheet
    case fullScreenCover
}

protocol Route: Hashable, Identifiable {
    associatedtype ViewType: View
    var id: UUID { get }
    var navigationType: RouteType { get }
    func viewToDisplay(router: Router<Self>) -> ViewType
}

extension Route {
    public var id: UUID { .init() }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
