//
//  Coordinators.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var store: CorduxStoreType { get }
    var route: Route { get set }
    func start()
    var rootViewController: UIViewController { get }
}

// MARK: - Scene Coordinator

protocol SceneCoordinator: Coordinator {
    var scenePrefix: String { get }
    var currentScene: Coordinator? { get }
    func changeScene(route: Route)
    func sceneRoute(route: Route) -> Route
}

extension SceneCoordinator {
    var route: Route {
        get {
            let route: Route = scenePrefix.route()
            return route + (currentScene?.route ?? [])
        }
        set {
            let r = route
            if r.first != newValue.first {
                changeScene(newValue)
            }
            routeScene(newValue)
        }
    }

    func routeScene(route: Route) {
        currentScene?.route = sceneRoute(route)
    }

    func sceneRoute(route: Route) -> Route {
        return Route(route.dropFirst())
    }
}

// MARK - UITabBarController Scene Coordinator

protocol TabScene: RouteConvertible {
    var prefix: String { get }
    var coordinator: Coordinator { get }
}

protocol TabBarControllerCoordinator: SceneCoordinator, UITabBarControllerDelegate {
    associatedtype Scene: TabScene
    var tabBarController: UITabBarController { get }
    var scenes: [Scene] { get }
}

extension TabScene {
    func route() -> Route {
        return Route(prefix)
    }
}

struct Scene: TabScene {
    let prefix: String
    let coordinator: Coordinator
}

extension TabBarControllerCoordinator {
    var rootViewController: UIViewController { return tabBarController }
    var scenePrefix: String { return scenes[tabBarController.selectedIndex].prefix }
    var currentScene: Coordinator? { return scenes[tabBarController.selectedIndex].coordinator }

    func changeScene(route: Route) {
        for (index, scene) in scenes.enumerate() {
            if route.first == scene.prefix {
                tabBarController.selectedIndex = index
                break
            }
        }
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        for scene in scenes {
            if scene.coordinator.rootViewController == viewController {
                store.setRoute(.replace(route, scene + scene.coordinator.route))
            }
        }
        return true
    }
}

// MARK: - NavigationController Coordinator

protocol NavigationControllerCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
    func updateRoute(route: Route)
}

extension NavigationControllerCoordinator  {
    var rootViewController: UIViewController { return navigationController }
    
    var route: Route {
        get {
            var route: Route = []
            navigationController.viewControllers.forEach { vc in
                if let cordux = vc as? CorduxViewController {
                    route.appendContentsOf(cordux.corduxContext?.routeSegment.route() ?? [])
                }
            }
            return route
        }
        set {
            if newValue != route {
                updateRoute(newValue)
            }
        }
    }

    func popRoute(viewController: UIViewController) {
        guard let viewController = viewController as? CorduxViewController,
              let context = viewController.corduxContext
        else {
            return
        }

        store.setRoute(.pop(context.routeSegment.route()))
    }
}
