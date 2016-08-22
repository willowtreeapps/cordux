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
    ///
    /// When set, the coordinator should adjust the view controller hierarchy to what is desired
    /// by the route.
    var route: Route { get set }

    /// Start the coordinator at the current route. Pass nil to start a coordiantor which is not
    /// currently shown in the view hierarchy.
    ///
    /// If the coordinator needs to adjust the route from what's given, it should call setRoute
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
