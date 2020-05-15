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

        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        
    }

    @IBAction func loginButton(_ sender: Any) {
        
    }
    
}

