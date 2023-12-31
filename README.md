<p align="center">
  <img src="https://github.com/obvios/Routing/blob/main/Assets/RoutingIcon.png" style="width: 90%; height: auto;">
</p>

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

2. Wrap your view hierarchy in a `RoutingView` that is initialized with your `Routable` enum. It will inject a `Router` instance into your root view.
```swift
import SwiftUI
import Routing

struct ContentView: View {
    var body: some View {
        RoutingView(ExampleRoute.self) { router in
            RootView(router: router)
        }
    }
}

struct RootView: View {
    @StateObject var router: Router<ExampleRoute>
    
    init(router: Router<ExampleRoute>) {
        _router = StateObject(wrappedValue: router)
    }
    
    var body: some View {
        VStack() {
            Button("View A") {
                router.routeTo(.viewA)
            }
            Button("View B") {
                router.routeTo(.viewB("Got here from RootView"))
            }
            Button("View C") {
                router.routeTo(.viewC)
            }
        }
    }
}
```

3. Use the `Router` functions from any of your views. Here is `ViewA` which is pushed onto the navigation stack by `RootView`.
```swift
struct ViewA: View {
    @StateObject var router: Router<ExampleRoute>
    
    init(router: Router<ExampleRoute>) {
        _router = StateObject(wrappedValue: router)
    }
    
    var body: some View {
        Text("View A")
        Button("ViewC") {
            router.routeTo(.viewC)
        }
        Button("Dismiss") {
            router.dismiss()
        }
    }
}
```
<p align="center">
  <img src = "https://github.com/obvios/Routing/blob/main/Assets/RoutingDemo.gif">
</p>
