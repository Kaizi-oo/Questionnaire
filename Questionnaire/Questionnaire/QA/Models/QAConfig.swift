//
//  QAConfig.swift
//  Q&A
//
//  Created by kyang on 2017/7/28.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation
import UIKit

struct Q_A {
    struct Color {
        static let yellow = UIColor(red: 251/255.0, green: 235/255.0, blue: 98/255.0, alpha: 1)
        static let gray = UIColor(red: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1)
        static let blue = UIColor(red: 86/255.0, green: 113/255.0, blue: 118/255.0, alpha: 1)
        static let red = UIColor(red: 201/255.0, green: 76/255.0, blue: 47/255.0, alpha: 1)
        static let white = UIColor.white
        static let text = UIColor(red: 68/255.0, green: 68/255.0, blue: 68/255.0, alpha: 1)
        static let drakText = UIColor(red: 15/255.0, green: 57/255.0, blue: 18/255.0, alpha: 1)
    }
    struct Font {
        static func senty(size: CGFloat) -> UIFont {
            return UIFont(name: "SentyMARUKO-Elementary", size: size)!
        }
    }
    
    struct Padding {
        static var top: CGFloat {
            return 94 * UIScreen.main.bounds.height / 667
        }
        static let left: CGFloat = 20
    }
    
    struct NotifyName {
        static let answerChanged = Notification.Name("answerChanged")
    }
}
