<p align="center">
  <img src="https://github.com/obvios/Routing/blob/main/Assets/RoutingIcon.png" style="width: 80%; height: auto;">
</p>

## Description
`Routing` is a SwiftUI library that decouples navigation logic from views, promoting separation of concerns, improved maintainability, and flexible programmatic navigation.

- Enforces separation of concerns by de-coupling navigation logic from SwiftUI views.
- Supports flexible programmatic navigation.
- Type-safe
- Ideal for structured, hierarchical navigation

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Deep Linking Support](#deep-linking-support)
- [Additional Resources](#additional-resources)
- [Usage With TabView](#usage-with-tabview)
- [Contributions](#contributions)


## Requirements
- Requires iOS 16 or later.

## Installation

You can install `Routing` using the Swift Package Manager.

1. In Xcode, select "File" > "Add Packages...".
2. Copy & paste the following into the "Search or Enter Package URL" search bar.
```
https://github.com/obvios/Routing.git
```
4. Xcode will fetch the repository & the "Routing" library will be added to your project.

## Getting Started
1. Create a `Routable` conforming `Enum` to represent the different views you wish to route to.
```swift
import SwiftUI
import Routing

enum ExampleRoute: Routable {
    case root
    case viewA
    case viewB(String)
    case viewC
    
    @ViewBuilder
    func viewToDisplay(router: Router<ExampleRoute>) -> some View {
        switch self {
        case .root:
            RootView(router: router)
        case .viewA:
            ViewA(router: router)
        case .viewB(let description):
            ViewB(router: router, description: description)
        case .viewC:
            ViewC(router: router)
        }
    }
}
```

2. Add the `RoutingView` to your view hierarchy and inject a `Router` instance.
```swift
import SwiftUI
import Routing

struct ContentView: View {
    @StateObject var router: Router<ExampleRoute> = .init(isPresented: .constant(.none))
    
    var body: some View {
        RoutingView(router) { _ in
            router.start(.root)
        }
    }
}
```

3. Use the `Router` functions from any of your views. Here is `ViewA`.
```swift
struct ViewA: View {
    @ObservedObject var router: Router<ExampleRoute>
    
    var body: some View {
        Text("View A")
        Button("View A: Push") {
            router.routeTo(.viewA, via: .push)
        }
        Button("View B: Full screen cover") {
            router.routeTo(.viewB("Got here from View A"), via: .fullScreenCover)
        }
        Button("ViewC: Sheet") {
            router.routeTo(.viewC, via: .sheet)
        }
        Button("Dismiss self") {
            router.dismissSelf()
        }
        Button("Pop back") {
            router.pop()
        }
    }
}
```
<p align="center">
  <img src = "https://github.com/obvios/Routing/blob/main/Assets/RoutingDemo.gif">
</p>

## Deep Linking Support

`Routing` provides support for deep linking using the `.onDeepLink(using:_:)` modifier.
This allows clients to handle incoming URLs and navigate to the appropriate `Routable` destination.
NOTE: The library will dismiss any sheets/fullScreenCovers automatically if needed before displaying the deep linked view.
WARNING: I recommend only adding one `.onDeepLink(using:_:)` modifier at the root of your view hierarchy.

### Usage

Attach `.onDeepLink(using:_:)` to `RoutingView` to handle deep links:

```swift
import SwiftUI
import Routing

struct ContentView: View {
    @StateObject var router: Router<ExampleRoute> = .init(isPresented: .constant(.none))
    
    var body: some View {
        RoutingView(router) { _ in
            router.start(.root)
        }
        .onDeepLink(using: router) { url in
            // Add your logic to handle deep link here
            print(url)
            // Return the destination to navigate to for the deep link
            return .viewC
        }
    }
}
```

## Additional Resources
The below articles are from my blog series explaining the `Router` pattern and documents the progress of this library.
- [Learn about the Router pattern for SwiftUI navigation](https://www.curiousalgorithm.com/post/router-pattern-for-swiftui-navigation)
- [See how presentation was added](https://www.curiousalgorithm.com/post/router-pattern-for-swiftui-navigation-sheets-and-full-screen-covers)
- [Blog post explaining this Routing library](https://www.curiousalgorithm.com/post/routing-library-for-swiftui-navigation)

## Usage with TabView

- Each tab should embed its own RoutingView instance to ensure navigation is managed independently within that tab. This allows each tab to maintain its own navigation stack while using a shared router for programmatic navigation.

To ensure proper navigation behavior in a multi-tab environment, structure your application like this:

```swift
import SwiftUI
import Routing

struct MainTabView: View {
    @StateObject var routerA = Router<ExampleRouteA>(isPresented: .constant(nil))
    @StateObject var routerB = Router<ExampleRouteB>(isPresented: .constant(nil))

    var body: some View {
        TabView {
            RoutingView(routerA) { _ in
                routerA.start(.rootA) // Sets the starting view for Tab 1
            }
            .tabItem {
                Label("Tab 1", systemImage: "house")
            }

            RoutingView(routerB) { _ in
                routerB.start(.rootB) // Sets the starting view for Tab 2
            }
            .tabItem {
                Label("Tab 2", systemImage: "gear")
            }
        }
    }
}


```

NOTE: Currently the Router cannot be used to route to views in a different tab. This limitation is due to the original single flow design of the library. I am working to address this in future versions.

## Contributions

Pull requests and issues are always welcome! Please open any issues and PRs for bugs, features, documentation, or enhancements.
