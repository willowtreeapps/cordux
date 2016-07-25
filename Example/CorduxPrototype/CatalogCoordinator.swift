//
//  CatalogCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

final class CatalogCoordinator: NSObject, TabBarControllerCoordinator {
    let _store: Store
    var store: StoreType { return _store }

    let scenes: [Scene]
    let tabBarController: UITabBarController

    init(store: Store) {
        _store = store
        scenes = [
            Scene(prefix: "first", coordinator: FirstCoordinator(store: store)),
            Scene(prefix: "second", coordinator: SecondCoordinator(store: store)),
        ]

        tabBarController = UIStoryboard(name: "Catalog", bundle: nil)
            .instantiateInitialViewController() as! UITabBarController

        tabBarController.viewControllers = scenes.map { $0.coordinator.rootViewController }
    }

    func start() {
        tabBarController.delegate = self
        scenes.forEach { $0.coordinator.start() }
        store.setRoute(.push(scenes[tabBarController.selectedIndex]))
    }
}

final class FirstCoordinator: NavigationControllerCoordinator {
    let _store: Store
    var store: StoreType { return _store }

    let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let first: FirstViewController

    init(store: Store) {
        _store = store

        first = storyboard.instantiateViewControllerWithIdentifier("First") as! FirstViewController
        navigationController = UINavigationController(rootViewController: first)
    }

    func start() {
        first.inject(handler: self)
    }

    func updateRoute(route: Route) {

    }
}

extension FirstCoordinator: FirstHandler {
    func performAction() {
        _store.dispatch(Noop())
    }
}

final class SecondCoordinator: NavigationControllerCoordinator {
    let _store: Store
    var store: StoreType { return _store }

    let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let second: SecondViewController

    init(store: Store) {
        _store = store

        second = storyboard.instantiateViewControllerWithIdentifier("Second") as! SecondViewController
        navigationController = UINavigationController(rootViewController: second)
    }

    func start() {
        second.inject(handler: self)
    }

    func updateRoute(route: Route) {
        
    }
}

extension SecondCoordinator: SecondHandler {
    func performAction() {
        _store.dispatch(Noop())
    }

    func signOut() {
        _store.dispatch(AuthenticationAction.signOut)
    }
}

