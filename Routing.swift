//
//  Routing.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

protocol RouteConvertible {
    func route() -> Route
}

struct Route  {
    var components: [String]

    init() {
        self.components = []
    }

    init(_ components: [String]) {
        self.components = components
    }

    init(_ component: String) {
        self.init([component])
    }
    
    init(_ slice: Slice<Route>) {
        self.init(Array(slice))
    }
}

extension Route: Equatable {}

func ==(lhs: Route, rhs: Route) -> Bool {
    return lhs.components == rhs.components
}

extension Route: RouteConvertible {
    func route() -> Route {
        return self
    }
}

extension Route: ArrayLiteralConvertible {
    init(arrayLiteral elements: String...) {
        components = elements
    }
}

extension Route: SequenceType {
    typealias Generator = AnyGenerator<String>

    func generate() -> Generator {
        var index = 0
        return AnyGenerator {
            if index < self.components.count {
                let c = self.components[index]
                index += 1
                return c

            }
            return nil
        }
    }
}

extension Route: CollectionType {
    typealias Index = Int

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return components.count
    }

    subscript(i: Int) -> String {
        return components[i]
    }
}

extension Route: RangeReplaceableCollectionType {
    mutating func reserveCapacity(minimumCapacity: Int) {
        components.reserveCapacity(minimumCapacity)
    }

    mutating func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Int>, with newElements: C) {
        components.replaceRange(subRange, with: newElements)
    }
}

func +(lhs: Route, rhs: Route) -> Route {
    return Route(lhs.components + rhs.components)
}

func +(lhs: RouteConvertible, rhs: Route) -> Route {
    return Route(lhs.route().components + rhs.components)
}

func +(lhs: Route, rhs: RouteConvertible) -> Route {
    return Route(lhs.components + rhs.route().components)
}

enum RouteAction<T: RouteConvertible>: Action {
    case goto(T)
    case push(T)
    case pop(T)
    case replace(T, T)
}

extension String: RouteConvertible {
    func route() -> Route {
        return Route(self)
    }
}

extension RawRepresentable where RawValue == String {
    func route() -> Route {
        return self.rawValue.route()
    }
}

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
            let tail = Route(Array(route[n-m..<n]))
            guard tail == segmentRoute else {
                return route
            }
            return Route(route.dropLast(m))
        case .replace(let old, let new):
            let head = reduce(.pop(old), route: route)
            return reduce(.push(new), route: head)
        }
    }
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
