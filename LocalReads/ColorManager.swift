//
//  ColorManager.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/19/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class ColorManager {
    
    static let shared = ColorManager()
    private init() {}
    
    private let _50: UIColor = UIColor(hexString: "#E0F2F1")
    private let _100: UIColor = UIColor(hexString: "#B2DFDB")
    private let _200: UIColor = UIColor(hexString: "#80CBC4")
    private let _300: UIColor = UIColor(hexString: "#4DB6AC")
    private let _400: UIColor = UIColor(hexString: "#26A69A")
    private let _500: UIColor = UIColor(hexString: "#009688")
    private let _600: UIColor = UIColor(hexString: "#00897B")
    private let _700: UIColor = UIColor(hexString: "#00796B")
    private let _800: UIColor = UIColor(hexString: "#00695C")
    private let _900: UIColor = UIColor(hexString: "#004D40")
    private let a200: UIColor = UIColor(hexString: "#FFC400")
    
    var colorArray: [UIColor] {
        return [_300, _400, _500, _600, _700, _800, _900, _800, _700, _600, _500, _400, _300, _200]
    }
    var primary: UIColor {
        return _500
    }
    var primaryDark: UIColor {
        return _700
    }
    var primaryLight: UIColor {
        return _100
    }
    var accent: UIColor {
        return a200
    }
}
