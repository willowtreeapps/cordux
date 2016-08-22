//
//  Logging.swift
//  Cordux
//
//  Created by Ian Terrell on 8/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public typealias RouteLogger = (RouteEvent)->()

/// A routing event that can be logged
public enum RouteEvent {
    /// Route was updated directly by app code
    case set(Route)

    /// Route was updated by a routing action handled by the store
    case store(Route)

    /// Route was updated by the app's reducer
    case reducer(Route)
}

public func ConsoleRouteLogger(event: RouteEvent) {
    switch event {
    case .set(let route):
        log(route: route, annotation: "(set)    ")
    case .store(let route):
        log(route: route, annotation: "(store)  ")
    case .reducer(let route):
        log(route: route, annotation: "(reducer)")
    }
}

#if swift(>=3)
    private func log(route: Route, annotation: String) {
        print("ROUTE \(annotation): \(route.components.joined(separator: "/"))")
    }
#else
    private func log(route route: Route, annotation: String) {
        print("ROUTE \(annotation): \(route.components.joinWithSeparator("/"))")
    }
#endif
