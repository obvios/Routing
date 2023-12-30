# Routing

## Description
`Routing` is a library for separating navigation logic from SwiftUI views.

- De-couples navigation logic from SwiftUI views.
- Leads to better separation of concerns

## Getting Started
1. Create a `Routable` conforming `Enum` to represent the different views you wish to route to.
```swift
import SwiftUI
import Routing

enum ExampleRoute: Routable {
    case viewA
    case viewB(String)
    case viewC
    
    @ViewBuilder
    func viewToDisplay(router: Router<ExampleRoute>) -> some View {
        switch self {
        case .viewA:
            ViewA(router: router)
        case .viewB(let description):
            ViewB(router: router, description: description)
        case .viewC:
            ViewC(router: router)
        }
    }
    
    var navigationType: NavigationType {
        switch self {
        case .viewA:
            return .push
        case .viewB(_):
            return .sheet
        case .viewC:
            return .fullScreenCover
        }
    }
}
```
