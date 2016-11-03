//
//  TabBarControllerCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public protocol TabBarControllerCoordinator: SceneCoordinator {
    associatedtype Scene: PrefixSelectable
    var tabBarController: UITabBarController { get }
    var scenes: [Scene] { get }
}

public extension TabBarControllerCoordinator {
    public var rootViewController: UIViewController { return tabBarController }
    public var scenePrefix: String? { return scenes[tabBarController.selectedIndex].prefix }
    public var currentScene: AnyCoordinator? { return scenes[tabBarController.selectedIndex].coordinator }

    public func changeScene(_ route: Route) {
        #if swift(>=3)
            for (index, scene) in scenes.enumerated() {
                if route.first == scene.prefix {
                    tabBarController.selectedIndex = index
                    break
                }
            }
        #else
            for (index, scene) in scenes.enumerate() {
                if route.first == scene.prefix {
                    tabBarController.selectedIndex = index
                    break
                }
            }
        #endif
    }

    public func setRouteForViewController(_ viewController: UIViewController) -> Bool {
        for scene in scenes {
            if scene.coordinator.rootViewController == viewController {
                store.setRoute(.replace(route, scene + scene.coordinator.route))
                return true
            }
        }
        return false
    }
}
