//
//  SubscriptionsTest.swift
//  Cordux
//
//  Created by Ian Terrell on 8/22/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import Cordux

class SubscriptionTestsSubscriber: SubscriberType {
    var lastModel: SimpleAuthViewModel?
    func newState(_ viewModel: SimpleAuthViewModel?) {
        lastModel = viewModel
    }
}

class SubscriptionsTest: XCTestCase {

    var store: Store<SimpleAppState>!

    override func setUp() {
        super.setUp()

        store = Store<SimpleAppState>(initialState: SimpleAppState(), reducer: SimpleAppReducer())
    }
    
    func testNilOptionalSubscription() {
        let sub = SubscriptionTestsSubscriber()
        store.subscribe(sub, SimpleAuthViewModel.init)
        store.dispatch(SimpleAction.noop)
        XCTAssertNil(sub.lastModel)
    }

    func testNonNilOptionalSubscription() {
        let sub = SubscriptionTestsSubscriber()
        store.subscribe(sub, SimpleAuthViewModel.init)
        store.dispatch(SimpleAction.signIn(name: "bob"))
        XCTAssertNotNil(sub.lastModel)
        XCTAssertEqual("bob", sub.lastModel?.name)
    }


}
