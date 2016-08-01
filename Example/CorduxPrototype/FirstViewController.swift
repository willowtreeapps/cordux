//
//  FirstViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol FirstHandler {
    func performAction()
}

class FirstViewController: UIViewController {
    var handler: FirstHandler!

    func inject(handler: FirstHandler) {
        self.handler = handler
    }

    @IBAction func performAction(_ sender: AnyObject) {
        handler.performAction()
    }
}

