//
//  UI.swift
//  InitDemo
//
//  Created by dev on 2019/5/22.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import FlexLayout

// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

// 由于个别地方需要换算成比例
// 所以我需要个基本的大小
let baseWidth: CGFloat = 375
let baseHeight: CGFloat = 667
fileprivate let adaptiveScale: CGFloat = screenWidth / baseWidth

// 根据vw进行缩放
func a(_ point: CGFloat) -> CGFloat {
    return point * adaptiveScale
}

enum FontWeight: String {
    case Light = "Light"
    case Medium = "Medium"
    case Regular = "Regular"
    case Semibold = "Semibold"
    case Thin = "Thin"
    case Ultralight = "Ultralight"
}

// Deprecated
func fontSizeWeight(_ size: CGFloat, weight: FontWeight) -> UIFont? {
    var fontSize = size
    if screenWidth > baseWidth {
        fontSize = size + 2
    } else if screenWidth < baseWidth {
        fontSize = size - 2
    }
    return UIFont(name: "PingFangSC-\(weight)", size: fontSize)
}


// 根据机型和基础字号进行适配
// Deprecated
func fontSize(_ size: CGFloat) -> UIFont? {
    return fontSizeWeight(size, weight: .Regular)
}

extension UIFont {
    static func size(_ size: CGFloat) -> UIFont? {
        return self.sizeWeight(size, weight: .Regular)
    }
    
    static func sizeWeight(_ size: CGFloat, weight: FontWeight) -> UIFont? {
        var fontSize = size
        if screenWidth > baseWidth {
            fontSize = size + 2
        } else if screenWidth < baseWidth {
            fontSize = size - 2
        }
        return UIFont(name: "PingFangSC-\(weight)", size: fontSize)
    }
    
}

extension UIColor {
    // 直接使用rgb255
    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}

extension UILabel {
    // 创建简单文本
    static func new(string: String, size: CGFloat, color: UIColor, sizeWeight: FontWeight = .Regular) -> UILabel {
        let text = UILabel()
        text.text = string
        text.font = UIFont.size(size)
        text.textColor = color
        text.sizeToFit()
        // 尝试设置lineHeight=1，去掉ascender
        // text.flex.height(size)
        return text
    }
    
    var paddingTop: CGFloat {
        get {
            return font.ascender - font.capHeight
        }
    }
    var paddingBottom: CGFloat {
        get {
            return -font.descender
        }
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}


struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
}

//触摸反馈

public enum FeedbackType: Int {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case none
}


func impactFeedback(style: FeedbackType) {
    
    if #available(iOS 10.0, *) {
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        default:
            break
        }
        
    }
    
}

// 拓展UIButton 增加扩大选取的函数
var btnHitAreaMarginKey = 101

extension UIButton {
    var hitAreaMargin: CGFloat {
        set(margin) {
            objc_setAssociatedObject(self, &btnHitAreaMarginKey, margin, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            // print("set \(objc_getAssociatedObject(self, &btnHitAreaMarginKey))")
        }
        get {
            // print(objc_getAssociatedObject(self, &btnHitAreaMarginKey))
            if let margin = objc_getAssociatedObject(self, &btnHitAreaMarginKey) as? CGFloat {
                return margin
            }
            return 0
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if hitAreaMargin == 0 {
            return super.point(inside: point, with: event)
        }
        let area = self.bounds.insetBy(dx: -hitAreaMargin, dy: -hitAreaMargin)
        return area.contains(point)
    }
}


