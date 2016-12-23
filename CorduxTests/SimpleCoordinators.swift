//
//  SimpleCoordinators.swift
//  Cordux
//
//  Created by Ian Terrell on 12/23/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import Cordux

final class BasicCoordinator: SimpleCoordinator {
    let store = Store<SimpleAppState>(initialState: SimpleAppState(), reducer: SimpleAppReducer())
    let rootViewController = UIViewController()
    let route: Route

    init(route: RouteConvertible) {
        self.route = route.route()
    }

    func start(route: Route?) {}
}
