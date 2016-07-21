//
//  SignInViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol SignInViewModel {
    
}

protocol SignInHandler {
    func signIn()
    func forgotPassword()
}

final class SignInViewController: UIViewController {

    var handler: SignInHandler!

    func inject(handler: SignInHandler) {
        self.handler = handler
    }

    func render(viewModel: SignInViewModel) {

    }

    @IBAction func signIn(sender: AnyObject) {
        handler.signIn()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        handler.forgotPassword()
    }
}
