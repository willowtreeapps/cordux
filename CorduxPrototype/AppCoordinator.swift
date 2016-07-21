//
//  AppCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

final class AppCoordinator: SubscriberType {
    let store: Store
    let window: UIWindow

    var currentRoute: Route = []
    var currentCoordinator: Coordinator?

    init(store: Store, window: UIWindow) {
        self.store = store
        self.window = window
    }

    func start() {
        store.subscribe(self, RouteSubscription.init)
    }

    func newState(state: RouteSubscription) {
        let route = state.route
        guard currentRoute != route else {
            return
        }
        if currentRoute.first != route.first {
            changeScenes(route)
        } else {
            routeScene(route)
        }

        currentRoute = route
    }

    func changeScenes(route: Route) {
        guard let first = route.first else {
            return
        }

        switch first {
        case "auth":
            let coordinator = AuthenticationCoordinator(store: store)
            window.rootViewController = coordinator.rootViewController
            coordinator.start(coordinatorRoute(route))
            currentCoordinator = coordinator
        default:
            break
        }
    }

    func routeScene(route: Route) {
        currentCoordinator?.route(coordinatorRoute(route))
    }

    func coordinatorRoute(route: Route) -> Route {
        return Array(route.dropFirst())
    }
}
