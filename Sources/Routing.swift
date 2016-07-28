//
//  Routing.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public struct Route  {
    var components: [String]
}

public protocol RouteConvertible {
    func route() -> Route
}

public enum RouteAction<T: RouteConvertible>: Action {
    case goto(T)
    case push(T)
    case pop(T)
    case replace(T, T)
}

extension Store {
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

extension Route {
    public init() {
        self.components = []
    }

    public init(_ components: [String]) {
        self.components = components
    }

    public init(_ component: String) {
        self.init([component])
    }

    public init(_ slice: Slice<Route>) {
        self.init(Array(slice))
    }
}

extension Route: Equatable {}

public func ==(lhs: Route, rhs: Route) -> Bool {
    return lhs.components == rhs.components
}

extension Route: RouteConvertible {
    public func route() -> Route {
        return self
    }
}

extension Route: ArrayLiteralConvertible {
    public init(arrayLiteral elements: String...) {
        components = elements
    }
}

extension Route: SequenceType {
    public typealias Generator = AnyGenerator<String>

    public func generate() -> Generator {
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
    public typealias Index = Int

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return components.count
    }

    public subscript(i: Int) -> String {
        return components[i]
    }
}

extension Route: RangeReplaceableCollectionType {
    public mutating func reserveCapacity(minimumCapacity: Int) {
        components.reserveCapacity(minimumCapacity)
    }

    public mutating func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Int>, with newElements: C) {
        components.replaceRange(subRange, with: newElements)
    }
}

public func +(lhs: Route, rhs: Route) -> Route {
    return Route(lhs.components + rhs.components)
}

public func +(lhs: RouteConvertible, rhs: Route) -> Route {
    return Route(lhs.route().components + rhs.components)
}

public func +(lhs: Route, rhs: RouteConvertible) -> Route {
    return Route(lhs.components + rhs.route().components)
}

extension String: RouteConvertible {
    public func route() -> Route {
        return Route(self)
    }
}

public extension RawRepresentable where RawValue == String {
    public func route() -> Route {
        return self.rawValue.route()
    }
}
