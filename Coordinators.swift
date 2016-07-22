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
    associatedtype RoutePrefix: RawRepresentable
    static var routePrefix: RoutePrefix? { get }
    var currentScene: Coordinator? { get }
    func changeScene(route: Route)
    func sceneRoute(route: Route) -> Route
}

protocol NavigationControllerCoordinator: Coordinator {
    associatedtype RoutePrefix: RawRepresentable
    static var routePrefix: RoutePrefix { get }
    var navigationController: UINavigationController { get }
    func updateRoute(route: Route)
}

extension SceneCoordinator where RoutePrefix.RawValue == String {
    var route: Route {
        get {
            var route: Route = []
            if let prefix = Self.routePrefix?.rawValue {
                route.append(prefix)
            }
            return route + (currentScene?.route ?? [])
        }
        set {
            let r = currentScene?.route ?? []
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
        return Array(route.dropFirst())
    }
}

extension NavigationControllerCoordinator where RoutePrefix.RawValue == String {
    var route: Route {
        get {
            var route: Route = [Self.routePrefix.rawValue]
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
