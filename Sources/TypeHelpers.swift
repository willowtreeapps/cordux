//
//  TypeHelpers.swift
//  Cordux
//
//  Created by Ian Terrell on 8/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

#if swift(>=3)
    func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType,
                           function: (_ action: Action, _ state: SpecificStateType) -> SpecificStateType) -> StateType {
        guard let specificStateType = genericStateType as? SpecificStateType else {
            return genericStateType
        }

        return function(action, specificStateType) as! StateType
    }

    func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType,
                           function: (_ action: Action, _ state: SpecificStateType) -> ()) {
        guard let specificStateType = genericStateType as? SpecificStateType else {
            return
        }

        function(action, specificStateType)
    }

#else

    func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType, @noescape function: (action: Action, state: SpecificStateType) -> SpecificStateType) -> StateType {
        guard let specificStateType = genericStateType as? SpecificStateType else {
            return genericStateType
        }

        return function(action: action, state: specificStateType) as! StateType
    }

    func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType, @noescape function: (action: Action, state: SpecificStateType) -> ()) {
        guard let specificStateType = genericStateType as? SpecificStateType else {
            return
        }

        function(action: action, state: specificStateType)
    }
#endif
