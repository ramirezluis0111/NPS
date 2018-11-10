//
//  extension.swift
//  CircleAnimation
//
//  Created by Panditas on 23/10/2018.
//  Copyright © 2018 Luis Alberto Ramirez. All rights reserved.
//

import Foundation
import UIKit

func createCircle(nameShape: CAShapeLayer, colorStroke: UIColor, colorFill: UIColor, position: CGPoint) {
    let circleShadow = UIBezierPath(arcCenter: .zero, radius: 40, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    
    nameShape.path = circleShadow.cgPath
    nameShape.strokeColor = colorStroke.cgColor
    nameShape.lineWidth = 2.5
    nameShape.fillColor = colorFill.cgColor
    nameShape.lineCap = CAShapeLayerLineCap.round
    nameShape.position = position
    
}
