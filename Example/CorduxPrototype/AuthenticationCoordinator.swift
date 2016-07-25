//
//  AuthenticationCoordinator.swift
//  CorduxPrototype
//
//  Created by Ian Terrell on 7/21/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import Cordux

final class AuthenticationCoordinator: NavigationControllerCoordinator {
    enum RouteSegment: String, RouteConvertible {
        case auth
        case signIn
        case fp
    }

    static let routePrefix = RouteSegment.auth

    let _store: Store
    var store: StoreType { return _store }

    let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
    let navigationController: UINavigationController

    let signInViewController: SignInViewController

    init(store: Store) {
        _store = store

        signInViewController = storyboard.instantiateInitialViewController() as! SignInViewController
        navigationController = UINavigationController(rootViewController: signInViewController)
    }

    func start() {
        signInViewController.inject(handler: self)
        signInViewController.context = Context(RouteSegment.signIn, lifecycleDelegate: self)
        store.setRoute(.push(RouteSegment.signIn))
    }

    func updateRoute(route: Route) {
        if route.last == RouteSegment.fp.rawValue {
            let forgotPasswordViewController = storyboard.instantiateViewControllerWithIdentifier("ForgotPassword") as! ForgotPasswordViewController
            forgotPasswordViewController.inject(self)
            forgotPasswordViewController.context = Context(RouteSegment.fp, lifecycleDelegate: self)
            navigationController.pushViewController(forgotPasswordViewController, animated: true)
        }
    }
}

extension AuthenticationCoordinator: ViewControllerLifecycleDelegate {
    @objc func viewDidLoad(viewController viewController: UIViewController) {
        if viewController === signInViewController {
            _store.subscribe(signInViewController, SignInViewModel.init)
        }
    }

    @objc func didMoveToParentViewController(parentViewController: UIViewController?, viewController: UIViewController) {
        guard parentViewController == nil else {
            return
        }

        popRoute(viewController)
    }
}

extension AuthenticationCoordinator: SignInHandler {
    func signIn() {
        _store.dispatch(AuthenticationAction.signIn)
    }

    func forgotPassword() {
        store.route(.push(RouteSegment.fp))
    }
}

extension SignInViewController: Renderer, Cordux.ViewController {}
extension ForgotPasswordViewController: Cordux.ViewController {}

extension SignInViewModel {
    init(_ state: AppState) {
        name = state.name
    }
}

extension AuthenticationCoordinator: ForgotPasswordHandler {
    func emailPassword() {

    }
}

