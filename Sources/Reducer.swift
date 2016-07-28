//
//  Reducer.swift
//  Cordux
//
//  Created by Ian Terrell on 7/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public protocol ReducerType {
    associatedtype State
    func handleAction(action: Action, state: State) -> State
}

public protocol AnyReducer {
    func _handleAction(action: Action, state: StateType) -> StateType
}

public protocol Reducer: AnyReducer {
    associatedtype ReducerStateType
    func handleAction(action: Action, state: ReducerStateType) -> ReducerStateType
}

extension Reducer {
    public func _handleAction(action: Action, state: StateType) -> StateType {
        return withSpecificTypes(action, state: state, function: handleAction)
    }
}

func withSpecificTypes<SpecificStateType, Action>(action: Action, state genericStateType: StateType, @noescape function: (action: Action, state: SpecificStateType) -> SpecificStateType) -> StateType {
    guard let specificStateType = genericStateType as? SpecificStateType else {
        return genericStateType
    }

    return function(action: action, state: specificStateType) as! StateType
}
