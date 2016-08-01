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
    func updateRoute(_ route: Route)
}

public extension NavigationControllerCoordinator  {
    public var rootViewController: UIViewController { return navigationController }

    public var route: Route {
        get {
            var route: Route = []
            navigationController.viewControllers.forEach { vc in
                #if swift(>=3)
                    route.append(contentsOf: vc.corduxContext?.routeSegment.route() ?? [])
                #else
                    route.appendContentsOf(vc.corduxContext?.routeSegment.route() ?? [])
                #endif
            }
            return route
        }
        set {
            if newValue != route {
                updateRoute(newValue)
            }
        }
    }

    public func popRoute(_ viewController: UIViewController) {
        guard let context = viewController.corduxContext else {
            return
        }

        store.setRoute(.pop(context.routeSegment.route()))
    }
}
