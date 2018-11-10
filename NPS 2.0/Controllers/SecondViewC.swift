//
//  SecondViewController.swift
//  CircleAnimation
//
//  Created by Panditas on 26/10/2018.
//  Copyright © 2018 Luis Alberto Ramirez. All rights reserved.
//

import UIKit

class SecondViewC: UIViewController {
    
    let shapeLayer = CAShapeLayer()
    @IBOutlet weak var popupView: UIView!

    var tapGestureRecognizer = UITapGestureRecognizer()
    
    var seconds = 8
    var startAnimation = false
    var timer = Timer()
    var isTimerRunnig = false
    var vuelta = false
    var orientationDict = [0, -CGFloat.pi / 2, CGFloat.pi, -(3/2)*CGFloat.pi]
    var colorDict = [colorWithHexStringg(hexString: "#0DFFC8"), colorWithHexStringg(hexString: "#0CDDE8"), colorWithHexStringg(hexString: "#00AFFF"), colorWithHexStringg(hexString: "#27CBCC")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.cornerRadius = 25
        popupView.layer.masksToBounds = true

        myActionMethod()
        NotificationCenter.default.addObserver(self, selector: #selector(StopTimerNotication(_:)), name:NSNotification.Name(rawValue: "StopTimerNotification"), object: nil)
    }
    
    @objc func StopTimerNotication(_ notification: NSNotification) {
            timer.invalidate()
            startAnimation = false
            vuelta = true
            dismiss(animated: true)
    }
    
    @objc func myActionMethod() {
        if startAnimation == false {
            runtimer()
            startAnimation = true
            vuelta = false
        } else {
            timer.invalidate()
            startAnimation = false
            vuelta = true
            dismiss(animated: true)
        }
    }
    
    @objc func  runtimer() {
        seconds = 4
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(udateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func udateTimer() {
        if vuelta == false {
            if seconds >= 1 {
                seconds -= 1
                initPorcent(colorSelect: colorDict[seconds], orientation: orientationDict[seconds])
                initAnimation()
                if seconds == 0 {
                    vuelta = true
                }
            }
        } else if vuelta == true {
            let secondsAux = 3
            if seconds <= 3 {
                initPorcent(colorSelect: colorDict[secondsAux - seconds], orientation: orientationDict[secondsAux - seconds])
                initAnimation()
                seconds += 1
                if seconds == 4 {
                    vuelta = false
                }
            }
        }
        print(seconds)
    }
    
    func initPorcent(colorSelect: UIColor, orientation: CGFloat) {
        view.layer.addSublayer(shapeLayer)
        let trackLayer = CAShapeLayer()
        let positionImage = view.center
        
        // TrackLayer
        createCircle(nameShape: trackLayer, colorStroke: .clear, colorFill: .clear, position: positionImage)
        view.layer.addSublayer(trackLayer)
        
        // Create Circle
        createCircle(nameShape: shapeLayer, colorStroke: colorSelect, colorFill: .clear, position: positionImage)
        
        shapeLayer.transform = CATransform3DMakeRotation(orientation, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    @objc fileprivate func initAnimation() {
        let initAnimate = CABasicAnimation(keyPath: "strokeEnd")
        initAnimate.toValue = 1
        initAnimate.duration = 0.98
        initAnimate.fillMode = CAMediaTimingFillMode.forwards
        initAnimate.isRemovedOnCompletion = true
        shapeLayer.add(initAnimate, forKey: "urSoBasic")
    }

}
