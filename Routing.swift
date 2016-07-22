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

extension RawRepresentable where RawValue == String {
    func route() -> Route {
        return [self.rawValue]
    }
}

typealias Route = [String]
typealias RouteSegment = [String]

enum RouteAction<T: RouteConvertible>: Action {
    case goto(T)
    case push(T)
    case pop(T)
}
