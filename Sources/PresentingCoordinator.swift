//
//  PresentingCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 11/2/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public protocol PresentingCoordinator: Coordinator {
    var rootCoordinator: AnyCoordinator { get }
    var presented: PrefixSelectable? { get set }

    var presentables: [PrefixSelectable] { get }
    func parsePresentableRoute(_ route: Route) -> (rootRoute: Route, presentedRoute: Route?, presentable: PrefixSelectable?)

    func present(presentable: PrefixSelectable, route: Route)
    func dismiss()
}

public extension PresentingCoordinator  {
    public var rootViewController: UIViewController {
        return rootCoordinator.rootViewController
    }

    public var route: Route {
        get {
            var route: Route = []
            #if swift(>=3)
                route.append(contentsOf: rootCoordinator.route)
            #else
                route.appendContentsOf(rootCoordinator.route)
            #endif
            if let presented = presented {
                #if swift(>=3)
                    route.append(contentsOf: presented.route())
                #else
                    route.appendContentsOf(presented.route())
                #endif
            }
            return route
        }
        set {
            if newValue != route {
                let (rootRoute, presentedRoute, presentable) = parsePresentableRoute(newValue)
                rootCoordinator.route = rootRoute

                if let presentable = presentable, let presentedRoute = presentedRoute {
                    present(presentable: presentable, route: presentedRoute)
                } else {
                    dismiss()
                }
            }
        }
    }

    func start(route: Route?) {
        rootCoordinator.start(route: route)
    }

    func parsePresentableRoute(_ route: Route) -> (rootRoute: Route, presentedRoute: Route?, presentable: PrefixSelectable?) {
        for presentable in presentables {
            let parts = route.components.split(separator: presentable.prefix,
                                               maxSplits: 2,
                                               omittingEmptySubsequences: false)
            if parts.count == 2 {
                return (Route(parts[0]), Route(parts[1]), presentable)
            }
        }
        return (route, nil, nil)
    }

    /// Presents the presentable coordinator.
    /// If it is already presented, this method merely adjusts the route.
    /// If a different presentable is currently presented, this method dismisses it first.
    func present(presentable: PrefixSelectable, route: Route) {
        if let presented = presented {
            if presentable.prefix != presented.prefix {
                dismiss()
            } else {
                presented.coordinator.route = route
                return
            }
        }

        presentable.coordinator.start(route: route)
        rootViewController.present(presentable.coordinator.rootViewController, animated: true, completion: nil)
        presented = presentable
    }

    /// Dismisses the currently presented coordinator if present. Noop if there isn't one.
    func dismiss() {
        presented?.coordinator.rootViewController.dismiss(animated: true, completion: nil)
        presented = nil
    }
}
