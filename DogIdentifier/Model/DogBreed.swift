//
//  DogBreed.swift
//  DogIdentifier
//
//  Created by Shiguo Feng on 2023-04-13.
//

import Foundation
import UIKit

struct DogBreed {
    let name: String
    let probability: Float
    
    var probabilityString: String {
        return String(format: "%.2f", probability * 100)
    }
    
    var subtitleColor : UIColor {
        switch probability {
        case 0.85...1:
            return UIColor.green
        case 0.65 ... 0.84:
            return UIColor.blue
        case 0.3 ... 0.64:
            return UIColor.gray
        default:
            return UIColor.red
        }
    }
}
