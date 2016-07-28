//
//  TabBarControllerCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

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