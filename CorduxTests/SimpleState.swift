//
//  SimpleState.swift
//  Cordux
//
//  Created by Ian Terrell on 8/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import Cordux

struct SimpleAppState: StateType {
    var route: Route = []
    var auth: SimpleAuthState = .signedOut
}

enum SimpleAuthState {
    case signedOut
    case signedIn(name: String)
}

class SimpleAppReducer: Reducer {
    func handleAction(_ action: Action, state: SimpleAppState) -> SimpleAppState {
        guard let action = action as? SimpleAction else {
            return state
        }

        var state = state

        switch action {
        case .signIn(let name):
            state.auth = .signedIn(name: name)
        default:
            break
        }

        return state
    }
}

struct SimpleAuthViewModel {
    let name: String
}

extension SimpleAuthViewModel {
    init?(state: SimpleAppState) {
        guard case let .signedIn(name) = state.auth else {
            return nil
        }

        self.name = name
    }
}

enum SimpleAction: Action {
    case noop
    case signIn(name: String)
}
