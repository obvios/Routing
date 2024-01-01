import XCTest
import SwiftUI
@testable import Routing

final class RoutingTests: XCTestCase {
    private var router: Router<TestRoute>!
    
    override func setUp() {
        super.setUp()
        router = Router(isPresented: .constant(.none))
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    func testPush() {
        
    }
}

fileprivate enum TestRoute: Routable {
    case viewA
    case viewB
    case viewC
    
    @ViewBuilder
    func viewToDisplay(router: Router<Self>) -> some View {
        switch self {
        case .viewA:
            Text("ViewA")
        case .viewB:
            Text("ViewB")
        case .viewC:
            Text("ViewC")
        }
    }
    
    var navigationType: Routing.NavigationType {
        switch self {
        case .viewA:
            return .push
        case .viewB:
            return .sheet
        case .viewC:
            return .fullScreenCover
        }
    }
    
    
}
