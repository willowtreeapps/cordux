//
//  NavigationControllerMetaCoordinatorTests.swift
//  Cordux
//
//  Created by Ian Terrell on 12/23/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
@testable import Cordux

class NavigationControllerMetaCoordinatorTests: XCTestCase {
    static let store = Store<SimpleAppState>(initialState: SimpleAppState(), reducer: SimpleAppReducer())

    final class TestCoordinator: NavigationControllerMetaCoordinator {
        var store = NavigationControllerMetaCoordinatorTests.store
        var navigationController = UINavigationController()
        var coordinators: [AnyCoordinator] = []
        func start(route: Route?) {}
        func coordinators(for route: Route) -> [AnyCoordinator] {
            return []
        }

        func setCoordinators(for routes: [RouteConvertible]) {
            coordinators = routes.map(BasicCoordinator.init)
        }
    }

    var coordinator: TestCoordinator!

    override func setUp() {
        coordinator = TestCoordinator()
        coordinator.setCoordinators(for: ["hello", "world", "who", "there?"])
    }

    func testNumberWithAllSharedCoordinators() {
        let number = coordinator.numberOfLastExistingCoordinator(for: Route(components: ["hello", "world", "who", "there?"]))
        XCTAssertEqual(4, number)
    }

    func testNumberWithNoSharedCoordinators() {
        let number = coordinator.numberOfLastExistingCoordinator(for: Route(components: ["x", "hello", "world", "who", "there?"]))
        XCTAssertEqual(0, number)
    }

    func testNumberWithNoSharedCoordinatorsSubset() {
        let number = coordinator.numberOfLastExistingCoordinator(for: Route(components: ["world", "who", "there?"]))
        XCTAssertEqual(0, number)
    }

    func testNumberWith1SharedCoordinators() {
        let number = coordinator.numberOfLastExistingCoordinator(for: Route(components: ["hello", "x", "world", "who", "there?"]))
        XCTAssertEqual(1, number)
    }

    func testNumberWith2SharedCoordinators() {
        let number = coordinator.numberOfLastExistingCoordinator(for: Route(components: ["hello", "world", "x", "who", "there?"]))
        XCTAssertEqual(2, number)
    }

    func testNumberWith3SharedCoordinators() {
        let number = coordinator.numberOfLastExistingCoordinator(for: Route(components: ["hello", "world", "who", "x", "there?"]))
        XCTAssertEqual(3, number)
    }

    func testNumberWithSomeSharedCoordinators() {
        let number = coordinator.numberOfLastExistingCoordinator(for: Route(components: ["hello", "world", "dogs", "cats"]))
        XCTAssertEqual(2, number)
    }
}
