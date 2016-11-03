//
//  CatalogCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

final class CatalogContainerCoordinator: PresentingCoordinator {
    var presented: Scene?
    
    lazy var presentables: [GeneratingScene] = {
        return [GeneratingScene(tag: "modal") { return ModalCoordinator(store: self.store) }]
    }()

    var store: Store
    var rootCoordinator: AnyCoordinator

    init(store: Store, rootCoordinator: AnyCoordinator) {
        self.store = store
        self.rootCoordinator = rootCoordinator
    }
}

final class CatalogCoordinator: NSObject, TabBarControllerCoordinator {
    var store: Store

    let scenes: [Scene]
    let tabBarController: UITabBarController

    init(store: Store) {
        self.store = store
        scenes = [
            Scene(tag: "first", coordinator: FirstCoordinator(store: store)),
            Scene(tag: "second", coordinator: SecondCoordinator(store: store)),
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

    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let first: FirstViewController

    init(store: Store) {
        self.store = store

        first = FirstViewController.make()
        navigationController = UINavigationController(rootViewController: first)
    }

    func start(route: Route?) {
        first.inject(handler: self)
    }

    func updateRoute(_ route: Route, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension FirstCoordinator: FirstHandler {
    func performAction() {
        store.dispatch(ModalAction.present)
    }
}

final class SecondCoordinator: NavigationControllerCoordinator {
    var store: Store

    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let second: SecondViewController

    init(store: Store) {
        self.store = store

        second = SecondViewController.make()
        navigationController = UINavigationController(rootViewController: second)
    }

    func start(route: Route?) {
        second.inject(handler: self)
    }

    func updateRoute(_ route: Route, completionHandler: @escaping () -> Void) {
        completionHandler()
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

final class ModalCoordinator: Coordinator {
    var store: Store

    var route: Route = []

    var first: FirstViewController
    var rootViewController: UIViewController { return first }

    init(store: Store) {
        self.store = store

        first = FirstViewController.make()
    }

    func start(route: Route?) {
        first.inject(handler: self)
    }

    func prepareForRoute(_: Route?, completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func setRoute(_: Route?, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension ModalCoordinator: FirstHandler {
    func performAction() {
        store.dispatch(ModalAction.dismiss)
    }
}
