//
//  AppState.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import Cordux

typealias Store = Cordux.Store<AppState>

struct AppState: StateType {
    var route: Route = []
    var name: String = "Hello"
    var authenticationState: AuthenticationState = .unauthenticated
}

enum AuthenticationState {
    case unauthenticated
    case authenticated
}

enum AuthenticationAction: Action {
    case signIn
    case signOut
}

enum ModalAction: Action {
    case present
    case dismiss
}

struct Noop: Action {}

final class AppReducer: Reducer {
    func handleAction(_ action: Action, state: AppState) -> AppState {
        var state = state
        state = reduceAuthentication(action, state: state)
        state = reduceModal(action, state: state)
        return state
    }

    func reduceAuthentication(_ action: Action, state: AppState) -> AppState {
        guard let action = action as? AuthenticationAction else {
            return state
        }

        var state = state

        switch action {
        case .signIn:
            state.route = ["catalog"]
            state.authenticationState = .authenticated
        case .signOut:
            state.route = ["auth"]
            state.authenticationState = .unauthenticated
        }

        return state
    }

    func reduceModal(_ action: Action, state: AppState) -> AppState {
        guard let action = action as? ModalAction else {
            return state
        }

        var state = state

        switch action {
        case .present:
            state.route = state.route.reduce(.push("modal"))
        case .dismiss:
            state.route = state.route.reduce(.pop("modal"))
        }

        return state
    }
}

final class ActionLogger: Middleware {
    func before(action: Action, state: AppState) {
        print("Before: \(action): \(state)")
    }
    func after(action: Action, state: AppState) {
        print("After: \(action): \(state)")
    }
}
