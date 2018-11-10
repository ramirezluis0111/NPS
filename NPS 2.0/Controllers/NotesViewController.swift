//
//  NotesViewController.swift
//  NPS 2.0
//
//  Created by Memes on 13/1/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import UIKit
import Firebase

class NotesViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var noteView: UITextView!
    var myNote = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = colorWithHexStringg(hexString: "#27CBCC")
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 22)!]
        
        if myNote != "" {
            noteView!.text = myNote
        }
    }
    @IBAction func addNote(_ sender: Any) {
        let user = Auth.auth().currentUser
        let userUid = user?.uid
        let refUser = Database.database().reference()
        refUser.child("users").child(userUid!).child("values").child("dNote").setValue(noteView.text)

        myNote = noteView.text
        NotificationCenter.default.post(name: .saveDates, object: self)
    
        dismiss(animated: true)
    }

    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        dismiss(animated: true)
    }
}
