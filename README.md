<p align="center">
  <img src="https://github.com/obvios/Routing/blob/main/Assets/RoutingIcon.png" style="width: 80%; height: auto;">
</p>

## Description
`Routing` is a library for separating navigation logic from SwiftUI views.

- De-couples navigation logic from SwiftUI views.
- Leads to better separation of concerns.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
  - [Defining a Routable Enum](#defining-a-routable-enum)
  - [Using RoutingView](#using-routingview)
  - [Navigating Between Views](#navigating-between-views)
- [Deep Linking Support](#deep-linking-support)
  - [Usage](#usage)
  - [Testing](#testing)
- [Additional Resources](#additional-resources)
- [Current Limitations](#current-limitations)


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

## Deep Linking Support

`Routing` provides support for deep linking using the `.onDeepLink(using:_:)` modifier. This allows clients to handle incoming URLs and navigate to the appropriate `Routable` destination.

### Usage

Attach `.onDeepLink(using:_:)` to any view inside `RoutingView` to handle deep links:

```swift
struct ContentView: View {
    var body: some View {
        RoutingView(ExampleRoute.self) { router in
            ViewA(router: router)
                .onDeepLink(using: router) { url in
                    // Add your logic to handle deeplink here
                    print(url)
                    // Return the Routable destination to navigate to
                    return ExampleRoute.viewC
                }
        }
    }
}

## Additional Resources
The below articles are from my blog series explaining the `Router` pattern and documents the progress of this library.
- [Learn about the Router pattern for SwiftUI navigation](https://www.curiousalgorithm.com/post/router-pattern-for-swiftui-navigation)
- [See how presentation was added](https://www.curiousalgorithm.com/post/router-pattern-for-swiftui-navigation-sheets-and-full-screen-covers)
- [Blog post explaining this Routing library](https://www.curiousalgorithm.com/post/routing-library-for-swiftui-navigation)

## Current Limitations

- Using the Router in Different Tabs: Each tab should embed its own `RoutingView` instance to manage navigation independently within that tab.

To ensure proper navigation behavior in a multi-tab environment, structure your application like this:

```swift
import SwiftUI
import Routing

struct MainTabView: View {
    var body: some View {
        TabView {
            RoutingView(ExampleRouteA.self) { router in
                RootViewA(router: router)
            }
            .tabItem {
                Label("Tab 1", systemImage: "house")
            }

            RoutingView(ExampleRouteB.self) { router in
                RootViewB(router: router)
            }
            .tabItem {
                Label("Tab 2", systemImage: "gear")
            }
        }
    }
}

```
