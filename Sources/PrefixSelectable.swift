//
//  PrefixSelectable.swift
//  Cordux
//
//  Created by Ian Terrell on 11/2/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public protocol PrefixSelectable: class, RouteConvertible {
    var prefix: String { get }
    var coordinator: AnyCoordinator { get }
}

public extension PrefixSelectable {
    public func route() -> Route {
        return Route(prefix) + coordinator.route
    }
}

public class Scene: PrefixSelectable {
    public let prefix: String
    public let coordinator: AnyCoordinator

    public init(prefix: String, coordinator: AnyCoordinator) {
        self.prefix = prefix
        self.coordinator = coordinator
    }
}

public class LazyScene: PrefixSelectable {
    public let prefix: String
    let factory: ()->(AnyCoordinator)

    public lazy var coordinator: AnyCoordinator = { return self.factory() }()

    public init(prefix: String, factory: @escaping ()->(AnyCoordinator)) {
        self.prefix = prefix
        self.factory = factory
    }
}
