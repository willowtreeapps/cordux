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
    associatedtype ScenePrefix: RawRepresentable
    var scenePrefix: ScenePrefix { get }
    var currentScene: Coordinator? { get }
    func changeScene(route: Route)
    func sceneRoute(route: Route) -> Route
}

protocol NavigationControllerCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
    func updateRoute(route: Route)
}

extension SceneCoordinator where ScenePrefix.RawValue == String {
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

extension NavigationControllerCoordinator  {
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
}
