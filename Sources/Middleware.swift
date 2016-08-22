//
//  Middleware.swift
//  Cordux
//
//  Created by Ian Terrell on 8/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public protocol AnyMiddleware {
    func _before(action: Action, state: StateType)
    func _after(action: Action, state: StateType)
}

public protocol Middleware: AnyMiddleware {
    associatedtype State
    func before(action: Action, state: State)
    func after(action: Action, state: State)
}

public extension Middleware {
    func _before(action: Action, state: StateType) {
        withSpecificTypes(action, state: state, function: before)
    }
    func _after(action: Action, state: StateType) {
        withSpecificTypes(action, state: state, function: after)
    }
}
