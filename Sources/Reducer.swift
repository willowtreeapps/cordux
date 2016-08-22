//
//  Reducer.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public protocol AnyReducer {
    func _handleAction(_ action: Action, state: StateType) -> StateType
}

public protocol Reducer: AnyReducer {
    associatedtype State
    func handleAction(_ action: Action, state: State) -> State
}

public extension Reducer {
    func _handleAction(_ action: Action, state: StateType) -> StateType {
        return withSpecificTypes(action, state: state, function: handleAction)
    }
}
