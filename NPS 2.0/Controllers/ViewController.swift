//
//  ViewController.swift
//  NPS 2.0
//
//  Created by Memes on 13/1/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import UIKit
//import FirebaseAuth
import Firebase

class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    weak var observer: NSObjectProtocol?
    
    @IBOutlet weak var noteTextFirstViewController: UITextView!
    let colorselected = colorWithHexStringg(hexString: "#ffffff")
    
    @IBOutlet weak var statusPorcentPresent: UILabel!
    
    @IBOutlet weak var spectAdecuado: UILabel!
    @IBOutlet weak var spectDestacado: UILabel!
    @IBOutlet weak var spectPromotor: UILabel!
    
    @IBOutlet weak var promTextField: UITextField!
    @IBOutlet weak var neutroTextField: UITextField!
    @IBOutlet weak var detracTextField: UITextField!
    
    @IBOutlet weak var buttonImageBarProfile: UIBarButtonItem!
    var saveImage: UIImage?
    
    /*  Create Button */
    var imageButtonUser: UIImage?
    /* - - - - - - - - - - - - - - - - - - - - - - - */

    var starAnimation: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = colorWithHexStringg(hexString: "#2CD8D9")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if starAnimation == true {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "secondView") as! SecondViewC;
            self.present(vc, animated: true, completion: nil)
            starAnimation = false
        }
        
        initUI()
        
        initNote()
        NotificationCenter.default.addObserver(self, selector: #selector(cancelTimer(_:)), name: Notification.Name("cancelTimer"), object: nil)
        
    }
    
    @objc func cancelTimer(_ notification:Notification) {
        NotificationCenter.default.post(name: NSNotification.Name("StopTimerNotification"), object: nil)
    }

    
    @IBAction func handleLogout(_ sender:Any) {
        try! Auth.auth().signOut()
        starAnimation = false
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func buttonCalculate(_ sender: UIButton) {
        let proms = Float(promTextField.text!)
        let neutros = Float(neutroTextField.text!)
        let dets = Float(detracTextField.text!)

        if ((proms == nil) || (neutros == nil) || dets == nil) {
            statusPorcentPresent.text = "0.0%"
            spectAdecuado.text = "0"
            spectDestacado.text = "0"
            spectPromotor.text = "0"
        } else {
            let statusNPS = calcNPS(p: proms!, n: neutros!, d: dets!) * 100
            let resultNPS_Stimed =  calcNPS_Spect(p: proms!, n: neutros!, d: dets!, score_act: statusNPS)
            
            statusPorcentPresent.text = "\(String(format: "%.1f", statusNPS))%"

            spectAdecuado.text = String(resultNPS_Stimed[0])
            spectDestacado.text = String(resultNPS_Stimed[1])
            spectPromotor.text = String(resultNPS_Stimed[2])
            
            saveStatus()
        }
    }
    
    func saveStatus() {
        let setModified = true
        let user = Auth.auth().currentUser
        let userUid = user?.uid
        let refUser = Database.database().reference()
        refUser.child("users").child(userUid!).child("modified").setValue(setModified)
        refUser.child("users").child(userUid!).child("values").child("aPromotor").setValue(Int(promTextField.text!))
        refUser.child("users").child(userUid!).child("values").child("bNeutro").setValue(Int(neutroTextField.text!))
        refUser.child("users").child(userUid!).child("values").child("cDetractor").setValue(Int(detracTextField.text!))
    }
    
    func initUI() {
        var imagen: UIImage? = nil
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser?.uid
            let refUpload = Storage.storage().reference()
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let photoURL = value!["profileImageUrl"] as? String
                let imageRef = refUpload.storage.reference(forURL: photoURL!)
                ImageView.selectedImage(imageRef: imageRef, urlString: photoURL!) { image in
                    imagen = image!

                    let imageResize = imagen?.resizeImage(38, opaque: false)
                    let profileButton = UIButton(type: .custom)
                    profileButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
                    profileButton.setImage(imageResize, for: .normal)
                    profileButton.layer.cornerRadius = profileButton.frame.height / 2
                    profileButton.layer.masksToBounds = true
                    
                    self.buttonImageBarProfile.customView = profileButton
                
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchHappen(_:)))
                    self.buttonImageBarProfile.customView?.addGestureRecognizer(tap)
                    self.buttonImageBarProfile.customView?.isUserInteractionEnabled = true
                }
                //Notification
                NotificationCenter.default.post(name: .saveDates, object: self)
                
                self.saveImage = imagen?.copy() as? UIImage
                var userSave = valueUser()
                userSave.promotor = (value!["values"] as? NSDictionary)!["aPromotor"] as! Int
                userSave.neutro = (value!["values"] as? NSDictionary)!["bNeutro"] as! Int
                userSave.detractor = (value!["values"] as? NSDictionary)!["cDetractor"] as! Int
                userSave.note = (value!["values"] as? NSDictionary)!["dNote"] as! String
                if userSave.promotor != 0 || userSave.neutro != 0 || userSave.detractor != 0 {
                    let statusNPS = calcNPS(p: Float(userSave.promotor), n: Float(userSave.neutro), d: Float(userSave.detractor)) * 100
                    
                    self.statusPorcentPresent.text = "\(String(format: "%.1f", statusNPS))%"
                }
                if self.promTextField.text == "" && self.neutroTextField.text == "" &&
                    self.detracTextField.text == "" {
                    self.promTextField.text = String(userSave.promotor)
                    self.neutroTextField.text = String(userSave.neutro)
                    self.detracTextField.text = String(userSave.detractor)
                }
                if userSave.note != "" {
                    self.noteTextFirstViewController.text = String(userSave.note)
                }
            })
        }
    }
    
    func initNote() {
        
        noteTextFirstViewController.layer.borderWidth = 0.5
        noteTextFirstViewController.layer.cornerRadius = 5
        noteTextFirstViewController.layer.borderColor! = colorselected.cgColor
        
        observer = NotificationCenter.default.addObserver(forName: .saveDates,
                                                          object: nil,
                                                          queue: OperationQueue.main) { (notification) in
                                                            weak var dateVc = notification.object as? NotesViewController
                                                            
                                                            self.noteTextFirstViewController.text = dateVc?.noteView.text
        }
    }

    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "ProfileUser")
        self.present(newViewController, animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let noteSend = noteTextFirstViewController.text
        weak var destViewToNote = segue.destination.children[0] as? NotesViewController
        
        destViewToNote?.myNote = noteSend!
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

