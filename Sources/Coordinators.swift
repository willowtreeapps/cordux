//
//  Coordinators.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public protocol AnyCoordinator: class {
    var _store: StoreType { get }
    var route: Route { get set }
    func start()
    var rootViewController: UIViewController { get }
}

public protocol Coordinator: AnyCoordinator {
    associatedtype State: StateType
    var store: Store<State> { get }
}

public extension Coordinator {
    var _store: StoreType {
        return store as StoreType
    }
}

// MARK: - Scene Coordinator

public protocol SceneCoordinator: Coordinator {
    var scenePrefix: String { get }
    var currentScene: AnyCoordinator? { get }
    func changeScene(route: Route)
    func sceneRoute(route: Route) -> Route
}

public extension SceneCoordinator {
    public var route: Route {
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

    public func routeScene(route: Route) {
        currentScene?.route = sceneRoute(route)
    }

    public func sceneRoute(route: Route) -> Route {
        return Route(route.dropFirst())
    }
}

// MARK - UITabBarController Scene Coordinator

public protocol TabScene: RouteConvertible {
    var prefix: String { get }
    var coordinator: AnyCoordinator { get }
}

public protocol TabBarControllerCoordinator: SceneCoordinator, UITabBarControllerDelegate {
    associatedtype Scene: TabScene
    var tabBarController: UITabBarController { get }
    var scenes: [Scene] { get }
}

public extension TabScene {
    public func route() -> Route {
        return Route(prefix)
    }
}

public struct Scene: TabScene {
    public let prefix: String
    public let coordinator: AnyCoordinator

    public init(prefix: String, coordinator: AnyCoordinator) {
        self.prefix = prefix
        self.coordinator = coordinator
    }
}

public extension TabBarControllerCoordinator {
    public var rootViewController: UIViewController { return tabBarController }
    public var scenePrefix: String { return scenes[tabBarController.selectedIndex].prefix }
    public var currentScene: AnyCoordinator? { return scenes[tabBarController.selectedIndex].coordinator }

    public func changeScene(route: Route) {
        for (index, scene) in scenes.enumerate() {
            if route.first == scene.prefix {
                tabBarController.selectedIndex = index
                break
            }
        }
    }

    public func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        for scene in scenes {
            if scene.coordinator.rootViewController == viewController {
                store.setRoute(.replace(route, scene + scene.coordinator.route))
            }
        }
        return true
    }
}

// MARK: - NavigationController Coordinator

public protocol NavigationControllerCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
    func updateRoute(route: Route)
}

public extension NavigationControllerCoordinator  {
    public var rootViewController: UIViewController { return navigationController }
    
    public var route: Route {
        get {
            var route: Route = []
            navigationController.viewControllers.forEach { vc in
                if let vc = vc as? ViewController {
                    route.appendContentsOf(vc.context?.routeSegment.route() ?? [])
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

    public func popRoute(viewController: UIViewController) {
        guard let viewController = viewController as? ViewController,
              let context = viewController.context
        else {
            return
        }

        store.setRoute(.pop(context.routeSegment.route()))
    }
}
