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

enum RouteAction: Action {
    case goto(route: Route)
    case push(segment: RouteSegment)
    case pop(segment: RouteSegment)
}

