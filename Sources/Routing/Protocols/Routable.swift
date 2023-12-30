import SwiftUI

public enum NavigationType {
    case push
    case sheet
    case fullScreenCover
}

public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    var id: UUID { get }
    var navigationType: NavigationType { get }
    func viewToDisplay(router: Router<Self>) -> ViewType
}

extension Routable {
    public var id: UUID { .init() }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
