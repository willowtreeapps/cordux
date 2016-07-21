//
//  SignInViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

struct SignInViewModel {
    var name: String
}

protocol SignInDelegate: ViewControllerLifecycleDelegate {

}

protocol SignInHandler {
    func signIn()
    func forgotPassword()
}

final class SignInViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!

    var handler: SignInHandler!
    weak var delegate: SignInDelegate?

    override func viewDidLoad() {
        delegate?.viewDidLoad?(self)
    }

    func inject(handler handler: SignInHandler, delegate: SignInDelegate? = nil) {
        self.handler = handler
        self.delegate = delegate
    }

    func render(viewModel: SignInViewModel) {
        nameLabel?.text = viewModel.name
    }

    @IBAction func signIn(sender: AnyObject) {
        handler.signIn()
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        handler.forgotPassword()
    }
}
