//
//  DispatchHelpers.swift
//  Cordux
//
//  Created by Ian Terrell on 6/30/17.
//  Copyright © 2017 WillowTree. All rights reserved.
//

import Foundation

public protocol Dispatcher {
    associatedtype DispatchAction: Action
    associatedtype State: StateType

    var store: Store<State> { get }
}

extension Dispatcher {
    func dispatch(_ action: DispatchAction) {
        store.dispatch(action)
    }
}
