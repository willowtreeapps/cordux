//
//  SecondViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol SecondHandler {
    func performAction()
    func signOut()
}

class SecondViewController: UIViewController {
    var handler: SecondHandler!

    func inject(handler handler: SecondHandler) {
        self.handler = handler
    }

    @IBAction func performAction(sender: AnyObject) {
        handler.performAction()
    }

    @IBAction func signOut(sender: AnyObject) {
        handler.signOut()
    }
}

