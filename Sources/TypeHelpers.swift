//
//  TypeHelpers.swift
//  Cordux
//
//  Created by Ian Terrell on 8/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType,
                       function: (_ action: Action, _ state: SpecificStateType) -> Void) {
    guard let specificStateType = genericStateType as? SpecificStateType else {
        return
    }

    function(action, specificStateType)
}

func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType,
                       function: (_ action: Action, _ state: SpecificStateType) -> (SpecificStateType, NavigationCommand?)) -> (StateType, NavigationCommand?) {
    guard let specificStateType = genericStateType as? SpecificStateType else {
        return (genericStateType, nil)
    }

    let (state, navigationCommand) = function(action, specificStateType)
    return (state as! StateType, navigationCommand)
}

func withSpecificTypes<SpecificStateType, Action>(_ action: Action, state genericStateType: StateType,
                       navigationCommand: NavigationCommand?,
                       function: (_ action: Action, _ state: SpecificStateType, _ navigationCommand: NavigationCommand?) -> ()) {
    guard let specificStateType = genericStateType as? SpecificStateType else {
        return
    }

    function(action, specificStateType, navigationCommand)
}
