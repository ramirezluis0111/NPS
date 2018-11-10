//
//  RecupPasswordViewController.swift
//  NPS 2.0
//
//  Created by Luis Alberto Ramirez on 18/8/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import UIKit
import Firebase

class RecupPasswordViewController: UIViewController {

    @IBOutlet weak var emailRecup: UITextField!
    @IBOutlet weak var titleRecup: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func SendEmailPass(_ sender: Any) {
        let email = emailRecup.text
        Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
            if error != nil {
                print("Error: \(String(describing: error?.localizedDescription))")
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    

}
