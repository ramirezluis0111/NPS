//
//  ProfileUserViewController.swift
//  NPS 2.0
//
//  Created by Luis Alberto Ramirez on 15/8/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import UIKit
import Firebase

class ProfileUserViewController: UIViewController, URLSessionDataDelegate{
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var TextFieldProfile: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    weak var observer: NSObjectProtocol?
    
    let shapeLayer = CAShapeLayer()
    let pulsatingLayer = CAShapeLayer()
    let colorSelected = colorWithHexStringg(hexString: "#06C5C7")
    
    let profileViewAux: UIImageView! = UIImageView.init()
    
    var nameCache: String = ""
    var emailCache: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = colorWithHexStringg(hexString: "#27CBCC")

        profileView.layer.borderWidth = 3
        profileView.layer.masksToBounds = false
        profileView.layer.borderColor = colorWithHexStringg(hexString: "#ffffff").cgColor
        profileView.layer.cornerRadius = profileView.frame.height / 2
        profileView.clipsToBounds = true
        
        initPorcent()
        // Guarda el valor de name
        nameCache = TextFieldProfile.text!
        emailCache = (emailButton.titleLabel?.text)!
        
        profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileView.isUserInteractionEnabled = true
        
        observer = NotificationCenter.default.addObserver(forName: .saveDates,
                                                          object: nil,
                                                          queue: OperationQueue.main) { (notification) in
                                                            weak var dateVc = notification.object as? ChangeEmailViewController
                                                            weak var profileVc = notification.object as? ViewController
                                                            
                                                            self.emailButton.titleLabel?.text = dateVc?.emailSend
                                                            self.profileView.image = profileVc?.saveImage
        }
        initImageView()
    }

    @IBAction func DonePrincipal(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func guardarChangeProfile(_ sender: Any) {
        let user = Auth.auth().currentUser
        let name = TextFieldProfile.text
        let imagePut = profileView.image
//        let imageRef = profileView.isEqual(profileView)
        let refName = Database.database().reference()
        let refUpload = Storage.storage().reference()
        
        ////// arreglar esto!!! esta bien la guarda pero no corta falta asignar valor a profileViewAux
        print(profileView.image?.isEqual(profileViewAux.image) as Any)
        // -------------------------------------------------------- //
        if name != nameCache  {
            let uid = user?.uid
            refName.child("users").child(uid!).child("name").setValue(name)
            dismiss(animated: true)
        }
        if profileView.image?.isEqual(profileViewAux.image) == false {
            let uid = user?.uid
            let imageUID = NSUUID().uuidString
            let imageUploadRef = refUpload.child("users").child(uid!).child("Image Profile").child("\(imageUID).png")
            
            if let uploadData = imagePut!.pngData() {
                let uploadtask = imageUploadRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                        print("Error en Metadata")
                        return
                    }
                    imageUploadRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("Error: \(String(describing: error?.localizedDescription))")
                            return
                        }
                        if let profileImgURL = url?.absoluteString {
                            refName.child("users").child(uid!).child("profileImageUrl").setValue(profileImgURL)
                        }
                    })
                }
                // Upload reported progress
                uploadtask.observe(.progress) { snapshot in
                    self.initPorcent()
                    self.shapeLayer.strokeEnd = 0
                    
                    let angle = CGFloat(snapshot.progress!.completedUnitCount)
                        / CGFloat(snapshot.progress!.totalUnitCount)
                    self.animatePulsatingLayer(stop: true)

                    DispatchQueue.main.async {
                        self.shapeLayer.strokeEnd = CGFloat(angle)
                    }
                    
                    print("Porcent: \(angle)")
                    print(angle)
                }
                // Upload completed successfully
                uploadtask.observe(.success) { snapshot in
                    self.animatePulsatingLayer(stop: false)
                    print("Upload Complete")
                }
            }
        } else {
            dismiss(animated: true)
            self.animatePulsatingLayer(stop: false)
        }
    }
    
    func initImageView(){
        var imagen: UIImage? = nil
        
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let nameUser = value!["name"] as? String
                let email = user.email
                let photoURL = value!["profileImageUrl"] as? String
                let url = URL(string: photoURL!)
                ImageView.getImage(withURL: url!) { image in
                    imagen = image!
                    
                    self.profileView.image = imagen
                    self.profileView.layer.borderWidth = 3
                    self.profileView.layer.masksToBounds = false
                    self.profileView.layer.borderColor = colorWithHexStringg(hexString: "#ffffff").cgColor
                    self.profileView.layer.cornerRadius = self.profileView.frame.height / 2
                    self.profileView.clipsToBounds = true
                    
                    self.profileViewAux.image = imagen
                }
                self.TextFieldProfile.text = nameUser
                self.nameCache = nameUser!
                self.emailButton.setTitle(email, for: .normal)
            })
        }
    }
    
    func initPorcent() {
        view.layer.addSublayer(shapeLayer)
        let trackLayer = CAShapeLayer()
        let positionImage = profileView.center

        // Pulsation
        createCircle(nameShape: pulsatingLayer, colorStroke: .clear, colorFill: .clear, position: positionImage)
        view.layer.addSublayer(pulsatingLayer)
        pulsatingLayer.opacity = 0.75

        view.bringSubviewToFront(profileView)

        // TrackLayer
        createCircle(nameShape: trackLayer, colorStroke: .lightGray, colorFill: .clear, position: positionImage)
        view.layer.addSublayer(trackLayer)
        
        // ShapeLayer
        createCircle(nameShape: shapeLayer, colorStroke: colorSelected, colorFill: .clear, position: positionImage)
        
        pulsatingLayer.fillColor = colorSelected.cgColor
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    func createCircle(nameShape: CAShapeLayer, colorStroke: UIColor, colorFill: UIColor, position: CGPoint) {
        let circleShadow = UIBezierPath(arcCenter: .zero, radius: 98, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        nameShape.path = circleShadow.cgPath
        nameShape.strokeColor = colorStroke.cgColor
        nameShape.lineWidth = 5
        nameShape.fillColor = colorFill.cgColor
        nameShape.lineCap = CAShapeLayerLineCap.round
        nameShape.position = position

    }
    fileprivate func initAnimation() {
        print("Init Gesture")
        let initAnimate = CABasicAnimation(keyPath: "strokeEnd")
        initAnimate.toValue = 1
        initAnimate.duration = 4
        initAnimate.fillMode = CAMediaTimingFillMode.forwards
        shapeLayer.add(initAnimate, forKey: "urSoBasic")
    }
    
    func animatePulsatingLayer(stop: Bool) {
        let animation = CABasicAnimation(keyPath: "transform.scale")

        if stop != false {
            animation.toValue = 1.3
            animation.duration = 1.05
            animation.autoreverses = true
            
            pulsatingLayer.add(animation, forKey: "pulsing")
        } else {
            animation.isRemovedOnCompletion = false
        }
    }
}
