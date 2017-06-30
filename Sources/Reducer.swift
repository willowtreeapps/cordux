//
//  Reducer.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

/// Action is a marker type that describes types that can modify state.
public protocol Action {}

public protocol AnyReducer {
    func _handleAction(_ action: Action, state: StateType) -> Command
}

public protocol Reducer: AnyReducer {
    associatedtype State
    func handleAction(_ action: Action, state: State) -> Command
}

public extension Reducer {
    func _handleAction(_ action: Action, state: StateType) -> Command {
        return withSpecificTypes(action, state: state, function: handleAction)
    }
}
