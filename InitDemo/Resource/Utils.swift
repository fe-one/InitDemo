//
//  Utils.swift
//  InitDemo
//
//  Created by dev on 2019/8/12.
//  Copyright © 2019 dev. All rights reserved.
//

// 画三角的位置
enum DrawLocation: Int {
    case top, right, bottom, left
}

// 画带有三角的圆角layer 参数 layer尺寸 位置 圆角 三角的宽高
func drawLayerWithCircleAndTriangle(layerFrame: CGRect, location: DrawLocation = .left, radius: CGFloat = 0, triangleWidth: CGFloat = 0, triangleHeight: CGFloat = 0, offset: CGFloat = 0) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = layerFrame
    
    let path = UIBezierPath()
    
    let width = layer.bounds.size.width
    let height = layer.bounds.size.height
    let x = layer.bounds.origin.x
    let y = layer.bounds.origin.y
    
    let offset: CGFloat = offset
    
    var topLeft = CGPoint.init(x: x, y: y)
    var topRight = CGPoint.init(x: x + width, y: y)
    var bottomRight = CGPoint.init(x: x + width, y: y + height)
    var bottomLeft = CGPoint.init(x: x, y: y + height)
    
    switch location {
    case .top:
        topLeft.y += triangleHeight
        topRight.y += triangleHeight
    case .right:
        topRight.x -= triangleHeight
        bottomRight.x -= triangleHeight
    case .bottom:
        bottomLeft.y -= triangleHeight
        bottomRight.y -= triangleHeight
    case .left:
        bottomLeft.x += triangleHeight
        topLeft.x += triangleHeight
    default: break
    }
    
    path.move(to: CGPoint.init(x: topLeft.x - offset, y: topLeft.y + radius))
    //
    path.addArc(withCenter: CGPoint.init(x: topLeft.x + radius, y: topLeft.y + radius), radius: radius + offset, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2 * 3, clockwise: true)
    // 画上三角
    if location == .top {
        path.addLine(to: CGPoint.init(x: (width - triangleWidth) / 2, y: topLeft.y - offset))
        path.addLine(to: CGPoint.init(x: topRight.x / 2, y: topLeft.y - triangleHeight))
        path.addLine(to: CGPoint.init(x: (width + triangleWidth) / 2, y: topLeft.y - offset))
    }
    path.addLine(to: CGPoint.init(x: topRight.x - radius, y: topRight.y - offset))
    //
    
    path.addArc(withCenter: CGPoint.init(x: topRight.x - radius, y: topRight.y + radius), radius: radius + offset, startAngle: CGFloat.pi / 2 * 3, endAngle: CGFloat.pi * 2, clockwise: true)
    // 画右三角
    if location == .right {
        path.addLine(to: CGPoint.init(x: topRight.x + offset, y: (height - triangleWidth) / 2))
        path.addLine(to: CGPoint.init(x: topRight.x + triangleHeight, y: height / 2))
        path.addLine(to: CGPoint.init(x: topRight.x + offset, y: (height + triangleWidth) / 2))
    }
    path.addLine(to: CGPoint.init(x: bottomRight.x + offset, y: bottomRight.y - radius))
    
    //
    path.addArc(withCenter: CGPoint.init(x: bottomRight.x - radius, y: bottomRight.y - radius), radius: radius + offset, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
    // 画下三角
    if location == .bottom {
        path.addLine(to: CGPoint.init(x: (width + triangleWidth) / 2, y: bottomRight.y + offset))
        path.addLine(to: CGPoint.init(x: bottomRight.x / 2, y: bottomRight.y + triangleHeight))
        path.addLine(to: CGPoint.init(x: (width - triangleWidth) / 2, y: bottomRight.y + offset))
    }
    path.addLine(to: CGPoint.init(x: bottomLeft.x + radius, y: bottomLeft.y + offset))
    
    //
    path.addArc(withCenter: CGPoint.init(x: bottomLeft.x + radius, y: bottomLeft.y - radius), radius: radius + offset, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
    // 画左三角
    if location == .left {
        path.addLine(to: CGPoint.init(x: bottomLeft.x - offset, y: (height + triangleWidth) / 2))
        path.addLine(to: CGPoint.init(x: bottomLeft.x - triangleHeight, y: height / 2))
        path.addLine(to: CGPoint.init(x: bottomLeft.x - offset, y: (height - triangleWidth) / 2))
    }
    path.addLine(to: CGPoint.init(x: topLeft.x - offset, y: topLeft.y + radius))
    
    layer.path = path.cgPath
    layer.lineWidth = a(1)
    layer.lineCap = .round
    
    return layer
}

// 计算富文本的尺寸
func getTextSize(text: String, size: CGSize, font: UIFont, lineSpace: CGFloat) -> CGSize {
    let labelStyle = NSMutableParagraphStyle()
    labelStyle.lineSpacing = lineSpace - font.ascender + font.descender
    let realSize = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: labelStyle], context: nil).size
    return realSize
}
