//
//  SecondViewController.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

protocol SecondHandler: class {
    func performAction()
    func signOut()
}

class SecondViewController: UIViewController {
    weak var handler: SecondHandler?

    static func make() -> SecondViewController {
        let storyboard = UIStoryboard(name: "Catalog", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "Second") as! SecondViewController
    }


    func inject(handler: SecondHandler) {
        self.handler = handler
    }

    @IBAction func performAction(_ sender: AnyObject) {
        handler?.performAction()
    }

    @IBAction func signOut(_ sender: AnyObject) {
        handler?.signOut()
    }
}

