//
//  NavigationControllerCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public protocol NavigationControllerCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
    func updateRoute(_ route: Route, completionHandler: @escaping () -> Void)
}

public extension NavigationControllerCoordinator  {
    public var rootViewController: UIViewController { return navigationController }

    public var route: Route {
        var route: Route = []
        navigationController.viewControllers.forEach { vc in
            #if swift(>=3)
                route.append(contentsOf: vc.corduxContext?.routeSegment?.route() ?? [])
            #else
                route.appendContentsOf(vc.corduxContext?.routeSegment?.route() ?? [])
            #endif
        }
        return route
    }

    public func needsToPrepareForRoute(_ route: Route?) -> Bool {
        return false
    }

    public func prepareForRoute(_ route: Route?, completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    public func setRoute(_ newRoute: Route?, completionHandler: @escaping () -> Void) {
        guard let newRoute = newRoute, newRoute != route else {
            completionHandler()
            return
        }

        updateRoute(newRoute, completionHandler: completionHandler)
    }

    public func popRoute(_ viewController: UIViewController) {
        guard let routeSegment = viewController.corduxContext?.routeSegment else {
            return
        }

        store.setRoute(.pop(routeSegment.route()))
    }
}

extension UINavigationController {
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)
        animateWithCompletion(animated: animated, completion: completion)
    }

    public func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)
        animateWithCompletion(animated: animated, completion: completion)
    }

    public func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        popToViewController(viewController, animated: animated)
        animateWithCompletion(animated: animated, completion: completion)
    }

    @discardableResult
    public func popToRootViewController(animated: Bool, completion: @escaping () -> Void) -> [UIViewController]? {
        let controllers = popToRootViewController(animated: animated)
        animateWithCompletion(animated: animated, completion: completion)
        return controllers
    }

    public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: @escaping () -> Void) {
        setViewControllers(viewControllers, animated: animated)
        animateWithCompletion(animated: animated, completion: completion)
    }

    func animateWithCompletion(animated: Bool, completion: @escaping () -> Void) {
        guard animated, let coordinator = transitionCoordinator else {
            completion()
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
