//
//  FirstViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol FirstHandler: class {
    func performAction()
}

class FirstViewController: UIViewController {
    weak var handler: FirstHandler?

    static func make() -> FirstViewController {
        let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "First") as! FirstViewController
    }

    func inject(handler: FirstHandler) {
        self.handler = handler
    }

    @IBAction func performAction(_ sender: AnyObject) {
        handler?.performAction()
    }
}

