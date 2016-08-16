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
    func handleAction(_ action: Action, state: State) -> State
}

public protocol AnyReducer {
    func _handleAction(_ action: Action, state: StateType) -> StateType
}

public protocol Reducer: AnyReducer {
    associatedtype ReducerStateType
    func handleAction(_ action: Action, state: ReducerStateType) -> ReducerStateType
}

extension Reducer {
    public func _handleAction(_ action: Action, state: StateType) -> StateType {
        return withSpecificTypes(action, state: state, function: handleAction)
    }
}

#if swift(>=3)
    func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType,
                           function: (_ action: Action, _ state: SpecificStateType) -> SpecificStateType) -> StateType {
        guard let specificStateType = genericStateType as? SpecificStateType else {
            return genericStateType
        }

        return function(action, specificStateType) as! StateType
    }
#else
    func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType, @noescape function: (action: Action, state: SpecificStateType) -> SpecificStateType) -> StateType {
        guard let specificStateType = genericStateType as? SpecificStateType else {
            return genericStateType
        }

        return function(action: action, state: specificStateType) as! StateType
    }
#endif
