import SwiftUI

public enum NavigationType {
    /// A push transition style, commonly used in navigation controllers.
    case push
    /// A presentation style, often used for modal or overlay views.
    case fullScreenCover
    /// A sheet presentation style
    case sheet
}

public enum NavigationTarget {
    /// Use this router instance
    case current
    /// Use furthest child in hierarchy
    case deepest
    /// Use top-most parent
    case root
    /// Use parent router
    case parent
    /// Use child router
    case child
}
