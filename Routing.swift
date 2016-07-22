//
//  Routing.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

typealias Route = [String]
typealias RouteSegment = [String]

extension CorduxStore {
    func reduce<T>(action: RouteAction<T>, route: Route) -> Route {
        switch action {
        case .goto(let route):
            return route.route()
        case .push(let segment):
            return route + segment.route()
        case .pop(let segment):
            let segmentRoute = segment.route()
            let n = route.count
            let m = segmentRoute.count
            guard n >= m else {
                return route
            }
            let tail = Array(route[n-m..<n])
            guard tail == segmentRoute else {
                return route
            }
            return Array(route.dropLast(m))
        case .replace(let old, let new):
            let head = reduce(.pop(old), route: route)
            return reduce(.push(new), route: head)
        }
    }
}

protocol RouteConvertible {
    func route() -> Route
}

struct RouteContainer: RouteConvertible {
    let _route: Route
    init(_ route: Route) {
        _route = route
    }
    func route() -> Route {
        return _route
    }
}

extension RawRepresentable where RawValue == String {
    func route() -> Route {
        return [self.rawValue]
    }
}

enum RouteAction<T: RouteConvertible>: Action {
    case goto(T)
    case push(T)
    case pop(T)
    case replace(T, T)
}
