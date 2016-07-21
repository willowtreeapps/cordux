//
//  SignInViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol SignInHandler {
    func signIn()
    func forgotPassword()
}

struct SignInViewModel: SubscriptionType {
    init(state: AppState) {

    }
}

final class SignInViewController: UIViewController {

    var stateStream: Observable<SignInViewModel>!
    var handler: SignInHandler!

    func inject(stateStream: Observable<SignInViewModel>, handler: SignInHandler) {
        self.stateStream = stateStream
        self.handler = handler

        stateStream.onChange(newState)
    }

    func newState(state: SignInViewModel) {

    }

    @IBAction func signIn(sender: AnyObject) {
        handler.signIn()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        handler.forgotPassword()
    }
}
