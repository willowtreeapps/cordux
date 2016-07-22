//
//  AppCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

final class AppCoordinator: SceneCoordinator, SubscriberType {
    enum RouteSegment: String, RouteConvertible {
        case hack
    }
    static var routePrefix: RouteSegment? = nil

    let store: Store
    let window: UIWindow

    var currentScene: Coordinator?

    var rootViewController: UIViewController {
        return currentScene?.rootViewController ?? UIViewController()
    }

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

        let coordinator: Coordinator
        switch first {
        case AuthenticationCoordinator.routePrefix.rawValue:
            coordinator = AuthenticationCoordinator(store: store)
            currentScene = coordinator
        case CatalogCoordinator.routePrefix!.rawValue:
            coordinator = CatalogCoordinator(store: store)
            currentScene = coordinator
        default:
            fatalError()
        }

        coordinator.start()
        UIView.transitionWithView(window, duration: 0.3, options: .TransitionCrossDissolve, animations: {
            self.window.rootViewController = coordinator.rootViewController
        }, completion: nil)
    }
}
