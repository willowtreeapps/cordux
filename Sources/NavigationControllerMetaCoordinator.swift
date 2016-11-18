//
//  NavigationControllerMetaCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 11/18/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

/// A coordinator to manage a navigation controller where each child view controller is managed by a single coordinator.
///
/// This has some limitations:
///   - One controller per coordinator
///   - Routes for each child coordinator are fixed
///   - This coordinator does not rearrange children; only pushes and pops
///   - All child coordinators that are disappearing have `prepareForRoute(nil)` called simultaneously.
public protocol NavigationControllerMetaCoordinator: Coordinator {
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

    public func setRoute(_ newRoute: Route?, completionHandler: @escaping () -> Void) {
        guard let newRoute = newRoute, newRoute != route else {
            completionHandler()
            return
        }

        let number = numberOfLastExistingCoordinator(for: route)

        var newRouteTail = newRoute
        for i in 0..<number {
            newRouteTail = Route(newRouteTail.suffix(from: coordinators[i].route.components.count))
        }

        let newCoordinators = coordinators(for: newRouteTail)
        newCoordinators.forEach { $0.start(route: []) }

        coordinators.removeLast(coordinators.count - number)
        coordinators.append(contentsOf: newCoordinators)

        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast(coordinators.count - number)
        viewControllers.append(contentsOf: newCoordinators.map({ $0.rootViewController }))
        navigationController.setViewControllers(viewControllers, animated: true, completion: completionHandler)
    }

    func numberOfLastExistingCoordinator(for route: Route?) -> Int {
        guard let route = route else {
            return 0
        }

        var index = -1
        for (i, coordinator) in coordinators.enumerated() {
            if route.isPrefixed(with: coordinator.route) {
                index = i
            }
        }
        return index + 1
    }

    public func popRoute(_ viewController: UIViewController) {
        guard let context = viewController.corduxContext else {
            return
        }

        store.setRoute(.pop(context.routeSegment.route()))
    }
}
