//
//  CatalogCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

final class CatalogCoordinator: NSObject, SceneCoordinator {
    let store: Store

    enum RouteSegment: String, RouteConvertible {
        case catalog
    }
    
    static let routePrefix: RouteSegment? = .catalog

    let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
    let tabBarController: UITabBarController
    var rootViewController: UIViewController { return tabBarController }

    var currentScene: Coordinator?
    let firstScene: Coordinator
    let secondScene: Coordinator

    init(store: Store) {
        self.store = store

        tabBarController = UIStoryboard(name: "Catalog", bundle: nil)
            .instantiateInitialViewController() as! UITabBarController

        firstScene = FirstCoordinator(store: store)
        secondScene = SecondCoordinator(store: store)
    }

    func start() {
        tabBarController.delegate = self
        firstScene.start()
        secondScene.start()
        tabBarController.viewControllers = [firstScene.rootViewController, secondScene.rootViewController]
        currentScene = firstScene
        store.setRoute(.push(FirstCoordinator.RouteSegment.first))
    }

    func changeScene(route: Route) {
        guard let tab = route.first else {
            return
        }

        switch tab {
        case FirstCoordinator.routePrefix.rawValue:
            tabBarController.selectedIndex = 0
            currentScene = firstScene
            firstScene.route = sceneRoute(route)
        case SecondCoordinator.routePrefix.rawValue:
            tabBarController.selectedIndex = 1
            currentScene = secondScene
            secondScene.route = sceneRoute(route)
        default:
            break
        }
    }
}

extension CatalogCoordinator: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        switch viewController {
        case firstScene.rootViewController:
            store.setRoute(.replace(RouteContainer(currentScene?.route ?? []), RouteContainer(firstScene.route)))
            currentScene = firstScene
        case secondScene.rootViewController:
            store.setRoute(.replace(RouteContainer(currentScene?.route ?? []), RouteContainer(secondScene.route)))
            currentScene = secondScene
        default:
            break
        }

        return true
    }
}

final class FirstCoordinator: NavigationControllerCoordinator {
    let store: Store

    enum RouteSegment: String, RouteConvertible {
        case first
    }

    static let routePrefix = RouteSegment.first

    let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let first: FirstViewController

    init(store: Store) {
        self.store = store

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
        store.dispatch(Noop())
    }
}

final class SecondCoordinator: NavigationControllerCoordinator {
    let store: Store

    enum RouteSegment: String, RouteConvertible {
        case second
    }

    static let routePrefix = RouteSegment.second

    let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
    let navigationController: UINavigationController
    var rootViewController: UIViewController { return navigationController }
    let second: SecondViewController

    init(store: Store) {
        self.store = store

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
        store.dispatch(Noop())
    }

    func signOut() {
        store.dispatch(AuthenticationAction.signOut)
    }
}

