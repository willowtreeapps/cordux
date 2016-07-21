//
//  RouteObserver.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

final class RouteObserver: SubscriberType {
    let store: Store
    var route: Route = []

    init(store: Store) {
        self.store = store
    }

    func start() {
        store.subscribe(self, RouteSubscription.init)
    }

    func newState(state: RouteSubscription) {
        if route != state.route {
            print("Route: \(state.route.joinWithSeparator("/"))")
        }
        route = state.route
    }
}
