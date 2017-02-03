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
    /// The current scene being shown by the coordinator.
    var currentScene: Scene? { get set }

    func coordinatorForTag(_ tag: String) -> (coordinator: AnyCoordinator, started: Bool)?
    func presentCoordinator(_ coordinator: AnyCoordinator?, completionHandler: @escaping () -> Void)
}

public extension SceneCoordinator {
    public var route: Route {
        return currentScene?.route() ?? []
    }

    public func prepareForRoute(_ route: Route?, completionHandler: @escaping () -> Void) {
        guard let currentScene = currentScene else {
            completionHandler()
            return
        }

        guard let route = route else {
            currentScene.coordinator.prepareForRoute(nil, completionHandler: completionHandler)
            return
        }

        currentScene.coordinator.prepareForRoute(sceneRoute(route), completionHandler: completionHandler)
    }

    public func setRoute(_ route: Route?, completionHandler: @escaping () -> Void) {
        guard let route = route, let tag = route.first else {
            completionHandler()
            return
        }
        
        if tag != currentScene?.tag {
            if let (coordinator, started) = coordinatorForTag(tag) {
                let wrappedCompletionHandler = wrapPresentingCompletionHandler(coordinator: coordinator,
                                                                               completionHandler: completionHandler)
                currentScene = Scene(tag: tag, coordinator: coordinator)
                if !started {
                    coordinator.start(route: sceneRoute(route))
                }
                presentCoordinator(coordinator, completionHandler: {
                    if started {
                        coordinator.setRoute(self.sceneRoute(route), completionHandler: wrappedCompletionHandler)
                    } else {
                        wrappedCompletionHandler()
                    }
                })
            } else {
                presentCoordinator(nil, completionHandler: completionHandler)
            }
        } else {
            currentScene?.coordinator.setRoute(sceneRoute(route), completionHandler: completionHandler)
        }
    }

    func sceneRoute(_ route: Route) -> Route {
        return Route(route.dropFirst())
    }
}
