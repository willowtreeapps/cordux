//
//  AppCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

final class AppCoordinator: SceneCoordinator, SubscriberType {
    let store: Store
    let window: UIWindow

    var currentScene: Coordinator?

    init(store: Store, window: UIWindow) {
        self.store = store
        self.window = window
    }

    func start() {
        store.subscribe(self, RouteSubscription.init)
    }

    func newState(state: RouteSubscription) {
        self.route = state.route
    }

    func changeScene(route: Route) {
        guard let first = route.first else {
            return
        }

        switch first {
        case "auth":
            let coordinator = AuthenticationCoordinator(store: store)
            window.rootViewController = coordinator.rootViewController
            coordinator.start()
            coordinator.route = coordinatorRoute(route)
            currentScene = coordinator
        default:
            break
        }
    }

    func routeScene(route: Route) {
        currentScene?.route = coordinatorRoute(route)
    }

    func coordinatorRoute(route: Route) -> Route {
        return Array(route.dropFirst())
    }
}
