//
//  TabBarControllerCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

/// A scene coordinator that keeps its scenes in an array (always in memory), and is rendered by a UITabBarController.
/// Conforming types' start method should invoke the start method for each scene. 
public protocol TabBarControllerCoordinator: SceneCoordinator {
    var tabBarController: UITabBarController { get }
    var scenes: [Scene] { get }
}

public extension TabBarControllerCoordinator {
    public var rootViewController: UIViewController { return tabBarController }
    public var currentScene: Scene? {
        get {
            return scenes[tabBarController.selectedIndex]
        }
        set {
            // noop
            // The coordinator is retained by scenes array and identified by tabBarController.selectedIndex.
        }
    }

    func coordinatorForTag(_ tag: String) -> (coordinator: AnyCoordinator, started: Bool)? {
        return scenes.first(where: { $0.tag == tag }).map { ($0.coordinator, true) }
    }

    func presentCoordinator(_ coordinator: AnyCoordinator?, completionHandler: @escaping () -> Void) {
        guard let coordinator = coordinator else {
            completionHandler()
            return
        }

        tabBarController.selectedIndex = scenes.index(where: { $0.coordinator === coordinator }) ?? 0
        completionHandler()
    }

    public func setRouteForViewController(_ viewController: UIViewController) -> Bool {
        for scene in scenes {
            if scene.coordinator.rootViewController === viewController {
                store.setRoute(.replace(route, scene.route()))
                return true
            }
        }
        return false
    }
}

class CorduxTabBarController: UITabBarController {
    init(setRoute: @escaping (UIViewController) -> (Bool)) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = SimpleCorduxTabControllerDelegate(setRoute: setRoute)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SimpleCorduxTabControllerDelegate: NSObject, UITabBarControllerDelegate {
    var setRoute: (UIViewController) -> (Bool)

    init(setRoute: @escaping (UIViewController) -> (Bool)) {
        self.setRoute = setRoute
    }
    public func tabBarController(_ tabBarController: UITabBarController,
                                 shouldSelect viewController: UIViewController) -> Bool {
        return setRoute(viewController)
    }

    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let items = tabBarController.viewControllers else {
            return
        }
        for (index, searchItem) in items.enumerated() {
            if searchItem == viewController {
                tabBarController.selectedIndex = index
            }
        }
    }
}
