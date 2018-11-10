//
//  LoginViewController.swift
//  NPS 2.0
//
//  Created by Memes on 16/2/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var imageRegister: UIImageView!
    @IBOutlet weak var ErrorRegisterText: UILabel!
    
    let colorselected = colorWithHexStringg(hexString: "#ffffff")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = colorWithHexStringg(hexString: "#27CBCC")
        
        imageRegister.layer.borderWidth = 3
        imageRegister.layer.masksToBounds = false
        imageRegister.layer.borderColor = colorselected.cgColor
        imageRegister.layer.cornerRadius = imageRegister.frame.height / 2
        imageRegister.clipsToBounds = true
        
        imageRegister.image = UIImage(named: "Profile")
        imageRegister.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageRegister.isUserInteractionEnabled = true

    }

    @IBAction func registerButton(_ sender: UIButton) {
        let nameText = nameTextField.text!
        let email = emailTextField.text!
        let image = imageRegister.image
        let userSave = valueUser()
        
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passTextField.text!, completion: {(user, error) in
            
                if let error = error {
                    print(error)
                    self.ErrorRegisterText.text = "Ups! Email ya registrado"
                    return
                }
            
                guard let uid = user?.user.uid else {
                    return
                }
                let storage = Storage.storage().reference()
                let imageUID = NSUUID().uuidString
                let storageRef = storage.child("users").child(uid).child("Image Profile").child("\(imageUID).png")
                
                if let uploadData = image!.pngData() {
                    storageRef.putData( uploadData, metadata: nil, completion: { (metadata, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                    
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print("Error: \(String(describing: error?.localizedDescription))")
                                return
                            }
                            if let profileImageUrl = url?.absoluteString {
                                let userArray = [
                                    "aPromotor": userSave.promotor,
                                    "bNeutro": userSave.neutro,
                                    "cDetractor": userSave.detractor,
                                    "dNote": userSave.note] as [String : Any]
                                
                                let values = ["name": nameText, "email": email, "profileImageUrl": profileImageUrl, "values": userArray] as [String : Any]
                                self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                            }
                        })
                    })
                }
        })
}

    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print(err)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func handleDismissButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

}
