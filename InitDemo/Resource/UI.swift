//
//  UI.swift
//  InitDemo
//
//  Created by dev on 2019/5/22.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import FlexLayout

public var safeArea: UIEdgeInsets = UIEdgeInsets()

// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

// NavBar height
public var navBarHeight: CGFloat {
    return CGFloat(44)
}
// StatusBar height
public var statusBarHeight: CGFloat {
    return UIDevice.current.userInterfaceIdiom == .pad ? 0 : UIApplication.shared.statusBarFrame.height
}
// bottom no tabbar
public var bottomNoTabBarHeihgt: CGFloat {
    return statusBarHeight == 44 ? 34 : 0
}

// 获取安全区域高 根据是否有tabbar navbar
public func getSafeHeightBy(hasTabBar: Bool, hasNavBar: Bool) -> CGFloat {
    return screenHeight - statusBarHeight - (hasNavBar ? navBarHeight : 0) - bottomNoTabBarHeihgt - (hasTabBar ? 49 : 0)
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
    static func size(_ size: CGFloat, weight: FontWeight = .Regular) -> UIFont? {
        return self.sizeWeight(size, weight: weight)
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
        text.font = UIFont.size(size, weight: sizeWeight)
        text.textColor = color
        text.sizeToFit()
        // 尝试设置lineHeight=1，去掉ascender
        // text.flex.height(size)
        return text
    }
    
    static func new(string: String, size: CGFloat, color: UIColor, fontName: String, alignment: NSTextAlignment = .left) -> UILabel {
        let text = UILabel()
        text.text = string
        text.font = UIFont(name: fontName, size: size)
        text.textColor = color
        text.textAlignment = alignment
        if string.contains("\n") {
            text.numberOfLines = 0
        }
        text.sizeToFit()
        
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
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
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
fileprivate var rectNameKey: (Character?, Character?, Character?, Character?)

extension UIButton {
    
    func setEnlargeEdgeWith(top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) {
        objc_setAssociatedObject(self, &rectNameKey.0, top, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &rectNameKey.1, right, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &rectNameKey.2, bottom, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &rectNameKey.3, left, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let topEdge = objc_getAssociatedObject(self, &rectNameKey.0) as? CGFloat,
            let rightEdge = objc_getAssociatedObject(self, &rectNameKey.1) as? CGFloat,
            let bottomEdge = objc_getAssociatedObject(self, &rectNameKey.2) as? CGFloat,
            let leftEdge = objc_getAssociatedObject(self, &rectNameKey.3) as? CGFloat {
            return CGRect(x: bounds.origin.x - leftEdge, y: bounds.origin.y - topEdge, width: bounds.width + leftEdge + rightEdge, height: bounds.height + topEdge + bottomEdge).contains(point) ? self : nil
        }
        return super.hitTest(point, with: event)
    }
    
    // 扩展
    func setTitle(_ title: String, _ size: CGFloat, _ color: UIColor) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.size(size)
        self.setTitleColor(color, for: .normal)
    }
    
}


extension UIView {
    
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    // 新增layer的圆角 可以和阴影一起
    func layerCorner(byRoundingCorners corners: UIRectCorner, radii: CGFloat, color: UIColor) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        
        let layer = CALayer()
        layer.backgroundColor = color.cgColor
        layer.frame = self.bounds
        layer.mask = maskLayer
        // 添加到最前方
        self.layer.insertSublayer(layer, at: 0)
        
    }
    
    func addShadow(color: CGColor, x: CGFloat, y: CGFloat, opacity: Float, radius: CGFloat) {
        self.layer.shadowColor = color;
        self.layer.shadowOffset = CGSize(width: x, height: y);
        self.layer.shadowOpacity = opacity;
        self.layer.shadowRadius = radius;
        self.layer.masksToBounds = false;
    }
    
}

extension UIImage {
    
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else {
            return nil
        }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}


extension Data {
    var hexString: String {
        return map {
            String(format: "%02.2hhx", $0)
            }.joined()
    }
}






