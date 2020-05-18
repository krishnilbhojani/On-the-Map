//
//  LoginViewController.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 15/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }

        OnTheMapAPI.postSession(username: email, password: password) { (success, error) in
            if success{
                self.performSegue(withIdentifier: "goToTabBarController", sender: self)
            }else{
                guard let errorMessage = error?.localizedDescription else { return }
                self.showLoginError(message: errorMessage)
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        UIApplication.shared.open(OnTheMapAPI.Endpoints.session.url, options: [:], completionHandler: nil)
    }
    
    func showLoginError(message: String){
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

