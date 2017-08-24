//
//  Coordinators.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

/// Type erased protocol for coordinators.
public protocol AnyCoordinator: class {

    /// The current route that the coordinator is managing.
    ///
    /// This property should return the current route for the current view controller hierarchy
    /// from the point of view of this coordinator.
    var route: Route { get }

    /// This method is called before `prepareForRoute(_:completionHandler:)` with the same route to determine if that
    /// method needs called.
    ///
    /// A `route` of `nil` is used to indicate that the coordinator's root view controller will be removed from the 
    /// hierarchy. If the coordinator is managing a view controller that could interfere with routing, such as a popover
    /// or a modal, then it should return true to tell the system that it needs to do so.
    ///
    /// - Parameters:
    ///   - _: the `Route` that will be prepared for in `prepareForRoute(_:completionHandler:)` following this call
    func needsToPrepareForRoute(_: Route?) -> Bool

    /// This method is called before `setRoute(_:completionHandler:)` and with the same values, but only when
    /// `needsToPrepareForRoute(_:)` returns true.
    ///
    /// A `route` of `nil` is used to indicate that the coordinator's root view controller will be removed from the
    /// hierarchy. If the coordinator is managing a view controller that could interfere with routing, such as a popover
    /// or a modal, then it should reset the view controller state to one that can be properly routed.
    ///
    /// When the view controller state has been made ready for routing, `completionHandler` must be called.
    ///
    /// - Parameters:
    ///   - _: the `Route` that will be routed to in `setRoute(_:completionHandler:)` following this call
    ///   - completionHandler: this closure must be called when the view controller hierarchy has been prepared for 
    ///     routing
    func prepareForRoute(_: Route?, completionHandler: @escaping () -> Void)

    /// When called, the coordinator should adjust the view controller hierarchy to what is
    /// desired by the `Route`. When the navigation has been completed, `completionHandler` must be called.
    ///
    /// - Parameters:
    ///   - _: the `Route` that should be navigated to
    ///   - completionHandler: this closure must be called when the routing is completed
    func setRoute(_: Route?, completionHandler: @escaping () -> Void)

    /// Start the coordinator at the current route. A route of nil is used to indicate a coordinator for which
    /// its view controller is not intended to be part of the current view hierarchy.
    ///
    /// If the coordinator needs to adjust the route from what's given, it should call store.setRoute(_:)
    /// during this method. This may occur when the route is empty, and the coordinator wishes
    /// to set up initial state according to its own internal logic.
    ///
    /// Otherwise, if the route is complete, it should set up the view controller
    /// hierarchy accordingly.
    ///
    /// In all cases, the rootViewController should be ready to be displayed after this method
    /// is called.
    func start(route: Route?)

    /// The root view controller of the hierarchy managed by this coordinator.
    var rootViewController: UIViewController { get }
}

public protocol Coordinator: AnyCoordinator {
    associatedtype State: StateType
    var store: Store<State> { get }
}

public func wrapPresentingCompletionHandler(coordinator: AnyCoordinator, completionHandler: @escaping () -> Void) -> () -> Void {
    return {
        guard let coordinator = coordinator as? AnyPresentingCoordinator, coordinator.hasStoredPresentable else {
            completionHandler()
            return
        }

        coordinator.presentStoredPresentable(completionHandler: completionHandler)
    }
}
