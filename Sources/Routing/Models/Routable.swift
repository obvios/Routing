import SwiftUI

public enum RouteType {
    case push
    case sheet
    case fullScreenCover
}

public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    var id: UUID { get }
    var routeType: RouteType { get }
    func viewToDisplay(router: Router<Self>) -> ViewType
}

extension Routable {
    public var id: UUID { .init() }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
