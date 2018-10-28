//
//  RegisterVC.swift
//  WebServiceDemo
//
//  Created by Mohammed Sobhei Abdualal on 10/27/18.
//  Copyright © 2018 Mohammed Sobhei Abdualal. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPasswordAgain: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func RegisterTapped(_ sender: UIButton) {
        guard let name = txtName.text?.trimmed, !name.isEmpty else { return }
        guard let email = txtEmail.text?.trimmed, !email.isEmpty else { return }
        guard let passowrd = txtPassword.text, !passowrd.isEmpty else { return }
        guard let passowrd_confirm = txtPasswordAgain.text, !passowrd_confirm.isEmpty else { return }
        
        
        guard passowrd == passowrd_confirm else {return}
        
        API.User.register(name: name, email: email, password: passowrd) { (success:Bool, error:Error?) in
            if success{
                print("Register Successfully")
            }
        }
    }

}
