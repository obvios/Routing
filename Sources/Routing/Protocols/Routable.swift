import SwiftUI

public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    func viewToDisplay(router: Router<Self>) -> ViewType
}

extension Routable {
    public var id: Self { self }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
