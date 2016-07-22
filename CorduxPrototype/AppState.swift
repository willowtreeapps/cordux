//
//  AppState.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

typealias Store = CorduxStore<AppState>

struct AppState: StateType {
    var route: Route = AuthenticationCoordinator.routePrefix.route()
    var name: String = "Hello"
    var authenticationState: AuthenticationState = .unauthenticated
}

struct RouteSubscription {
    let route: Route

    init(_ state: AppState) {
        route = state.route
    }
}

enum AuthenticationState {
    case unauthenticated
    case authenticated
}

enum AuthenticationAction: Action {
    case signIn
    case signOut
}

struct Noop: Action {}

final class AppReducer: Reducer {
    func handleAction(action: Action, state: AppState) -> AppState {
        var state = state
        state = reduceAuthentication(action, state: state)
        return state
    }

    func reduceAuthentication(action: Action, state: AppState) -> AppState {
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
}
