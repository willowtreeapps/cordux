//
//  ForgotPasswordViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol ForgotPasswordHandler {
    func emailPassword()
}

class ForgotPasswordViewController: UIViewController {

    var handler: ForgotPasswordHandler!

    func inject(_ handler: ForgotPasswordHandler) {
        self.handler = handler
    }

    @IBAction func emailPassword(_ sender: AnyObject) {
        handler.emailPassword()
    }
}
