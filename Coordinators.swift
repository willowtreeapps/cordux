//
//  Coordinators.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var route: Route { get set }
    func start()
    var rootViewController: UIViewController { get }
}

protocol SceneCoordinator: Coordinator {
    var currentScene: Coordinator? { get }
    func changeScene(route: Route)
}

protocol NavigationControllerCoordinator: Coordinator {
    static var routePrefix: String { get }
    var navigationController: UINavigationController { get }
    func updateRoute(route: Route)
}

extension SceneCoordinator {
    var route: Route {
        get {
            return currentScene?.route ?? []
        }
        set {
            if route.first != newValue.first {
                changeScene(newValue)
            } else {
                routeScene(newValue)
            }
        }
    }

    var rootViewController: UIViewController {
        return currentScene?.rootViewController ?? UIViewController()
    }

    func routeScene(route: Route) {
        currentScene?.route = sceneRoute(route)
    }

    func sceneRoute(route: Route) -> Route {
        return Array(route.dropFirst())
    }
}

extension NavigationControllerCoordinator {
    var route: Route {
        get {
            var route: Route = [Self.routePrefix]
            navigationController.viewControllers.forEach { vc in
                if let cordux = vc as? CorduxViewController {
                    route.appendContentsOf(cordux.corduxContext?.routeSegment ?? [])
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
}
