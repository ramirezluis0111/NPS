//
//  initialViewController.swift
//  NPS 2.0
//
//  Created by Memes on 17/2/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import Foundation
import UIKit

class initialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = colorWithHexStringg(hexString: "#27CBCC")
        
        self.performSegue(withIdentifier: "toMenuScreen", sender: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}
