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
    var store: Store

    let scenes: [Scene]
    let tabBarController: UITabBarController

    init(store: Store) {
        self.store = store
        scenes = [
            Scene(prefix: "first", coordinator: FirstCoordinator(store: store)),
            Scene(prefix: "second", coordinator: SecondCoordinator(store: store)),
        ]

        tabBarController = UIStoryboard(name: "Catalog", bundle: nil)
            .instantiateInitialViewController() as! UITabBarController

        tabBarController.viewControllers = scenes.map { $0.coordinator.rootViewController }
    }

    func start(route: Route?) {
        tabBarController.delegate = self
        scenes.forEach { $0.coordinator.start(route: []) }
        store.setRoute(.push(scenes[tabBarController.selectedIndex]))
    }
}

extension CatalogCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return setRouteForViewController(viewController)
    }
}

final class FirstCoordinator: NavigationControllerCoordinator {
    var store: Store

    let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let first: FirstViewController

    init(store: Store) {
        self.store = store

        first = storyboard.instantiateViewController(withIdentifier: "First") as! FirstViewController
        navigationController = UINavigationController(rootViewController: first)
    }

    func start(route: Route?) {
        first.inject(handler: self)
    }

    func updateRoute(_ route: Route) {

    }
}

extension FirstCoordinator: FirstHandler {
    func performAction() {
        store.dispatch(Noop())
    }
}

final class SecondCoordinator: NavigationControllerCoordinator {
    var store: Store

    let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let second: SecondViewController

    init(store: Store) {
        self.store = store

        second = storyboard.instantiateViewController(withIdentifier: "Second") as! SecondViewController
        navigationController = UINavigationController(rootViewController: second)
    }

    func start(route: Route?) {
        second.inject(handler: self)
    }

    func updateRoute(_ route: Route) {
        
    }
}

extension SecondCoordinator: SecondHandler {
    func performAction() {
        store.dispatch(Noop())
    }

    func signOut() {
        store.dispatch(AuthenticationAction.signOut)
    }
}

