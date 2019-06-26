//
//  SceneCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

/// A SceneCoordinator can manage the transition between disparate coordinators.
/// For instance, if the coordinator has three child scenes, A, B, and C, then 
/// the scene coordinator can manage switching between them, showing only one at a time,
/// as well as routing the subroute to the current scene (either A, B, or C).
/// 
/// To do this, it wants a route prefix to indicate which scene should be shown, and
/// a currentScene property to know which scene to route to.
public protocol SceneCoordinator: Coordinator {
    /// The route prefix that indicates the current scene.
    var scenePrefix: String? { get }

    /// The current scene being shown by the coordinator.
    var currentScene: AnyCoordinator? { get }

    /// Conforming types must implement this method in order to perform the view level
    /// work to transition from one scene to another. It is expected that the new scene
    /// will be initialized to show the current route passed.
    func changeScene(_ route: Route)
}

public extension SceneCoordinator {
    var route: Route {
        get {
            let route: Route = scenePrefix?.route() ?? []
            return route + (currentScene?.route ?? [])
        }
        set {
            let r = route
            if r.first != newValue.first {
                changeScene(newValue)
            } else {
                routeScene(newValue)
            }
        }
    }

    func routeScene(_ route: Route) {
        currentScene?.route = sceneRoute(route)
    }

    func sceneRoute(_ route: Route) -> Route {
        return Route(route.dropFirst())
    }
}
