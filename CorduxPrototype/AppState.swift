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

final class AppReducer: Reducer {
    func handleAction(action: Action, state: AppState) -> AppState {
        let state = state ?? AppState()
        return AppState(
            route: state.route,
            name: state.name,
            authenticationState: reduce(action, state: state.authenticationState)
        )
    }

    func reduce(action: Action, state: AuthenticationState) -> AuthenticationState {
        guard let action = action as? AuthenticationAction else {
            return state
        }

        switch action {
        case .signIn:
            return .authenticated
        case .signOut:
            return .unauthenticated
        }
    }
}
