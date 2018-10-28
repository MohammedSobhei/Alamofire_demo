//
//  ViewController.swift
//  WebServiceDemo
//
//  Created by Mohammed Sobhei Abdualal on 10/27/18.
//  Copyright © 2018 Mohammed Sobhei Abdualal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        guard let email = txtEmail.text?.trimmed, !email.isEmpty else { return }
        guard let password = txtPassword.text, !password.isEmpty else { return }
        
        API.User.login(email: email, password: password) { (success:Bool, error:Error?) in
            
            if success {
                print("Success")
            }else{
                print("Failure")
            }
        }
        
    }
}

