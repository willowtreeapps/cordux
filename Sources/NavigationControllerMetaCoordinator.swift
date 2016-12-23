//
//  NavigationControllerMetaCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 11/18/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

/// A coordinator to manage a navigation controller where each child view controller is managed by a single coordinator.
///
/// This has some limitations:
///   - One controller per coordinator
///   - Routes for each child coordinator are fixed
///   - This coordinator does not rearrange children; only pushes and pops
///   - All child coordinators that are disappearing have `prepareForRoute(nil)` called simultaneously.
///
/// Implementing classes should define the `ViewControllerLifecycleDelegate` method 
/// `didMove(toParentViewController:viewController:` to pop off coordinators when necessary. This logic should suffice:
/**
```
func didMove(toParentViewController parent: UIViewController?, viewController: UIViewController) {
    if parent == nil {
        coordinators.removeLast()
    }
}
```
*/
///
public protocol NavigationControllerMetaCoordinator: Coordinator, ViewControllerLifecycleDelegate {
    var navigationController: UINavigationController { get }

    var coordinators: [AnyCoordinator] { get set }

    func coordinators(for route: Route) -> [AnyCoordinator]
}

public extension NavigationControllerMetaCoordinator  {
    public var rootViewController: UIViewController { return navigationController }

    public var route: Route {
        var route: Route = []
        coordinators.forEach { coordinator in
            #if swift(>=3)
                route.append(contentsOf: coordinator.route)
            #else
                route.appendContentsOf(coordinator.route)
            #endif
        }
        return route
    }

    public func prepareForRoute(_ route: Route?, completionHandler: @escaping () -> Void) {
        let number = numberOfLastExistingCoordinator(for: route)
        for i in number..<coordinators.count {
            coordinators[i].prepareForRoute(nil) {}
        }
        completionHandler()
    }

    public func setRoute(_ route: Route?, completionHandler: @escaping () -> Void) {
        guard let route = route, route != self.route else {
            completionHandler()
            return
        }

        let number = numberOfLastExistingCoordinator(for: route)
        let numberToRemove = coordinators.count - number
        coordinators.removeLast(numberToRemove)
        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast(numberToRemove)

        var newRouteTail = route
        for i in 0..<number {
            newRouteTail = Route(newRouteTail.suffix(from: coordinators[i].route.components.count))
        }

        let newCoordinators = coordinators(for: newRouteTail)
        newCoordinators.forEach { $0.start(route: []) }
        coordinators.append(contentsOf: newCoordinators)

        let newViewControllers = newCoordinators.map { $0.rootViewController }
        newViewControllers.forEach { $0.addLifecycleDelegate(self) }
        viewControllers.append(contentsOf: newViewControllers)
        navigationController.setViewControllers(viewControllers, animated: true, completion: completionHandler)
    }

    // 1-based index of last coordinator that shares in the route; 0 for none
    func numberOfLastExistingCoordinator(for route: Route?) -> Int {
        guard var route = route else {
            return 0
        }

        var index = -1
        for (i, coordinator) in coordinators.enumerated() {
            if route.isPrefixed(with: coordinator.route) {
                index = i
                route = Route(route.suffix(from: coordinator.route.components.count))
            } else {
                return index + 1
            }
        }
        return index + 1
    }

    public func popRoute(_ viewController: UIViewController) {
        guard let routeSegment = viewController.corduxContext?.routeSegment else {
            return
        }

        store.setRoute(.pop(routeSegment.route()))
    }
}

