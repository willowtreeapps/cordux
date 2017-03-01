//
//  Routing.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public struct Route  {
    public internal(set) var components: [String]

    public func reduce<T>(_ action: RouteAction<T>) -> Route {
        switch action {
        case .goto(let route):
            return route.route()
        case .push(let segment):
            return route() + segment.route()
        case .pop(let segment):
            let segmentRoute = segment.route()
            let n = route().count
            let m = segmentRoute.count
            guard n >= m else {
                return self
            }
            let tail = Route(Array(route()[n-m..<n]))
            guard tail == segmentRoute else {
                return self
            }
            return Route(route().dropLast(m))
        case .replace(let old, let new):
            let head = self.reduce(.pop(old))
            return head.reduce(.push(new))
        }
    }
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

#if swift(>=3)
    extension Route:
        RandomAccessCollection,
        Sequence,
        RangeReplaceableCollection,
        ExpressibleByArrayLiteral
    {}
#else
    extension Route:
        CollectionType,
        SequenceType,
        RangeReplaceableCollectionType,
        ArrayLiteralConvertible
    {}
#endif

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

extension Route {
    public init(arrayLiteral elements: String...) {
        components = elements
    }
}

extension Route {
    func isPrefixed(with route: Route) -> Bool {
        return Array(components.prefix(route.components.count)) == route.components
    }
}


extension Route {
    #if swift(>=3)
    public typealias Iterator = AnyIterator<String>
    public func makeIterator() -> Iterator {
        return AnyIterator(makeGenerator())
    }
    #else
    public typealias Generator = AnyGenerator<String>
    public func generate() -> Generator {
        return AnyGenerator(body: makeGenerator())
    }
    #endif

    func makeGenerator() -> () -> (String?) {
        var index = 0
        return {
            if index < self.components.count {
                let c = self.components[index]
                index += 1
                return c

            }
            return nil
        }
    }
}

extension Route {
    public typealias Index = Int

    #if swift(>=3)
        public typealias Indices = CountableRange<Index>
    #endif

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return components.count
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public func index(before i: Int) -> Int {
        return i - 1
    }

    public subscript(i: Int) -> String {
        return components[i]
    }
}

extension Route {
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        components.reserveCapacity(minimumCapacity)
    }

    #if swift(>=3)
        public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Iterator.Element {
            components.replaceSubrange(subRange, with: newElements)
        }
    #else
        public mutating func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(_ subRange: Range<Int>, with newElements: C) {
            components.replaceRange(subRange, with: newElements)
        }
    #endif
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
