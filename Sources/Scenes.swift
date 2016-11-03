//
//  TaggedCoordinator.swift
//  Cordux
//
//  Created by Ian Terrell on 11/2/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public class Scene: RouteConvertible {
    /// The label used to identify the coordinator and to be used as a route segment.
    public let tag: String

    /// The coordinator to attach with the label.
    public let coordinator: AnyCoordinator

    /// Initializes a Scene.
    ///
    /// - Parameters:
    ///   - tag: The label used to identify the coordinator and to be used as a route segment.
    ///   - coordinator: The coordinator to attach with the label.
    public init(tag: String, coordinator: AnyCoordinator) {
        self.tag = tag
        self.coordinator = coordinator
    }

    public func route() -> Route {
        return Route(tag) + coordinator.route
    }
}

public class GeneratingScene {
    /// The label used to identify the coordinator and to be used as a route segment.
    public let tag: String

    let factory: ()->(AnyCoordinator)

    /// Initializes a GeneratingScene.
    ///
    /// - Parameters:
    ///   - tag: The label used to identify the coordinator and to be used as a route segment.
    ///   - factory: A closure to create the coordinator for the scene.
    ///
    /// - Important: The factory closure is stored indefinitely. If you are storing this type for later use, be sure
    ///              to mind what you capture over. Most often this will mean you should be using [unowned self].
    public init(tag: String, factory: @escaping ()->(AnyCoordinator)) {
        self.tag = tag
        self.factory = factory
    }

    /// Builds a new coordinator from the factory provided at initialization.
    public func buildCoordinator() -> AnyCoordinator {
        return self.factory()
    }
}
