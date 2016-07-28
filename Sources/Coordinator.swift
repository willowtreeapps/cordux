//
//  Coordinators.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public protocol AnyCoordinator: class {
    var route: Route { get set }
    func start()
    var rootViewController: UIViewController { get }
}

public protocol Coordinator: AnyCoordinator {
    associatedtype State: StateType
    var store: Store<State> { get }
}
