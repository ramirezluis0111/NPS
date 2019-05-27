//
//  FuntionAndAsserts.swift
//  NPS
//
//  Created by Memes on 21/12/17.
//  Copyright © 2017 Memes. All rights reserved.
//

import Foundation
import UIKit

func calcNPS(p: Float, n: Float, d: Float) -> Float {
    let resultNPS = (p - d)/(p + n + d)
    
    return resultNPS
}
func statusNpsrange(statusNPS: Float) -> String {
    var npsRange = String()
    if statusNPS < 48.5 {
        npsRange = "Inadecuado"
    } else if statusNPS > 48.5 && statusNPS < 65.1 {
        npsRange = "Mejorar"
    } else if 75.1 > statusNPS && statusNPS > 65.1 {
        npsRange = "Adecuado"
    } else if statusNPS < 82.3 && statusNPS > 75.1 {
        npsRange = "Destacado"
    } else if statusNPS > 82.3 {
        npsRange = "Sobresaliente"
    }
    return npsRange
}

func calcNPS_Spect (p: Float, n: Float, d: Float, score_act: Float) -> [Int] {
    var a = [0,0,0]
    var count: Int = Int(p)
    var scoreAux: Float = ((p - d)/(p + n + d)) * 100
    
    while scoreAux < 82.5 {
        if scoreAux < 65.1 {
            scoreAux = ((Float(count) - d)/(Float(count) + n + d)) * 100
            count += 1
            a[0] = count - Int(p)
        } else if (75.1 > scoreAux) && (scoreAux >= 65.1) {
            scoreAux = ((Float(count) - d)/(Float(count) + n + d)) * 100
            count += 1
            a[1] = count - Int(p)
        } else if (82.5 >= scoreAux) && (scoreAux >= 75.1) {
            scoreAux = ((Float(count) - d)/(Float(count) + n + d)) * 100
            count += 1
            a[2] = count - Int(p)
        }
    }
    return a
}

func correctInput (wordSearch: String, wordABC: String) -> Bool {
    var correct: Bool = false
    var inputRec: Int = 0
    let length: Int = wordSearch.count
    var wordSelect: String.Index
    var wordDump: String
    
    while ((correct == false) && inputRec < length)  {
        wordSelect = wordSearch.index(wordSearch.startIndex, offsetBy: inputRec)
        wordDump = String(wordSearch[wordSelect])
        if (wordABC.contains(wordDump)) {
            correct = true
        } else {
            inputRec += 1
        }
    }
    return correct
}

