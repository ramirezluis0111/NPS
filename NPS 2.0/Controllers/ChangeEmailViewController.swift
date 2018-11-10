//
//  ChangeEmailViewController.swift
//  NPS 2.0
//
//  Created by Luis Alberto Ramirez on 20/8/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import UIKit
import Firebase

class ChangeEmailViewController: UIViewController {

    @IBOutlet weak var emailRecup: UITextField!
    @IBOutlet weak var passwordVerification: UITextField!
    @IBOutlet weak var errorAuth: UILabel!
    var emailSend: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = colorWithHexStringg(hexString: "#27CBCC")
    }
    
    @IBAction func changeSucces(_ sender: Any) {
        
        let mail = emailRecup.text
        let password = passwordVerification.text
        let user = Auth.auth().currentUser
        let email = user?.email
        
        if password != "" {
            let ref = Database.database().reference()
            let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email!, password: password!)
            user?.reauthenticateAndRetrieveData(with: credential)
            Auth.auth().currentUser?.updateEmail(to: mail!) { (error) in
                if error != nil {
                    print("Error Change: \(String(describing: error?.localizedDescription))")
                    self.passwordVerification.text = ""
                    self.passwordVerification.placeholder = "Contraseña Invalida"
                    self.errorAuth.text = "Contraseña Invalida"
                } else {
                    self.emailSend = mail!
                    let uid = user?.uid
                    ref.child("users").child(uid!).child("email").setValue(mail)
                    NotificationCenter.default.post(name: .saveDates, object: self)
                    self.dismiss(animated: true)
                }
            }
        } else {
            errorAuth.text = "Contraseña Vacia"
        }
    }

    @IBAction func buttonBack(_ sender: Any) {
        dismiss(animated: true)
    }
}
