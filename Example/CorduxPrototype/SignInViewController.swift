//
//  SignInViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

struct SignInViewModel {
    let name: String
}

protocol SignInHandler {
    func signIn()
    func forgotPassword()
}

final class SignInViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!

    var handler: SignInHandler!

    func inject(handler: SignInHandler) {
        self.handler = handler
    }

    func render(_ viewModel: SignInViewModel?) {
        nameLabel?.text = viewModel?.name
    }

    @IBAction func signIn(_ sender: AnyObject) {
        handler.signIn()
    }
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
        handler.forgotPassword()
    }
}
