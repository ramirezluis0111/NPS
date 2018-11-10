//
//  extensionVC.swift
//  NPS 2.0
//
//  Created by Panditas on 05/11/2018.
//  Copyright © 2018 Memes. All rights reserved.
//

import Foundation
import UIKit

func colorWithHexStringg (hexString:String) -> UIColor {
    
    var rgb: UInt32 = 0
    let s: Scanner = Scanner(string: hexString as String)
    
    s.scanLocation = 1
    s.scanHexInt32(&rgb)
    
    return UIColor(
        red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgb & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

