//
//  ViewTransition.swift
//  InitDemo
//
//  Created by dev on 2019/8/12.
//  Copyright © 2019 dev. All rights reserved.
//

// 转场动画类

class ViewTransitionManager: NSObject {
    
    enum Animate {
        case scale
        case circle
        case top
    }
    
    enum Transition {
        case present // push
        case dismiss // pop
    }
    
    // 设置转场代理
    static private let transition = ViewTransitionManager()
    
    static private var duration = 1.0
    static private var type: Animate = .scale
    static private var tran: Transition = .present
    
    static func modalPresentTransition(fromVC: UIViewController,
                                       toVC: UIViewController,
                                       duration: Double = 1.0,
                                       animate: Animate = .scale, completion: (() -> ())?) {
        ViewTransitionManager.duration = duration
        ViewTransitionManager.type = animate
        
        toVC.transitioningDelegate = ViewTransitionManager.transition
        fromVC.present(toVC, animated: true) {
            completion?()
        }
    }
    
    static func navigationTransition(fromVC: UIViewController, toVC: UIViewController, duration: Double = 1.0, animate: Animate = .scale, completion: (() -> ())?) {
        ViewTransitionManager.duration = duration
        ViewTransitionManager.type = animate
        
        fromVC.navigationController?.delegate = ViewTransitionManager.transition
        fromVC.navigationController?.pushViewController(toVC, animated: true)
    }
    
    static func navigationTransition(fromVC: UIViewController, duration: Double = 1.0, animate: Animate = .scale, completion: (()->())?) {
        ViewTransitionManager.duration = duration
        ViewTransitionManager.type = animate
        
        fromVC.navigationController?.delegate = ViewTransitionManager.transition
        fromVC.navigationController?.popViewController(animated: true)
    }
}

extension ViewTransitionManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return ViewTransitionManager.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        switch ViewTransitionManager.tran {
        case .present:
            presentTransition(transitionContext: transitionContext)
        case .dismiss:
            dismissTransition(transitionContext: transitionContext)
        }
    }
}

extension ViewTransitionManager: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            ViewTransitionManager.tran = .present
            return ViewTransitionManager()
        }
        
        if operation == .pop {
            ViewTransitionManager.tran = .dismiss
            return ViewTransitionManager()
        }
        
        return nil
    }
}

extension ViewTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        ViewTransitionManager.tran = .present
        return ViewTransitionManager()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        ViewTransitionManager.tran = .dismiss
        return ViewTransitionManager()
    }
    
}

extension ViewTransitionManager {
    
    private func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
            let toView = toVC?.view else {
                return
        }
        
        transitionContext.containerView.addSubview(toView)
        
        switch ViewTransitionManager.type {
        case .scale:
            scalePresent(fromView: fromView,
                         toView: toView,
                         transitionContext: transitionContext)
        case .circle:
            circlePresent(fromView: fromView,
                          toView: toView,
                          transitionContext: transitionContext)
        case .top:
            topPresent(fromView: fromView,
                       toView: toView,
                       transitionContext: transitionContext)
        }
        
    }
    
    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
            let toView = toVC?.view else {
                return
        }
        
        switch ViewTransitionManager.type {
        case .scale:
            scaleDismiss(fromView: fromView,
                         toView: toView,
                         transitionContext: transitionContext)
        case .circle:
            circleDismiss(fromView: fromView,
                          toView: toView,
                          transitionContext: transitionContext)
        case .top:
            topDismiss(fromView: fromView,
                       toView: toView,
                       transitionContext: transitionContext)
        }
    }
    
    private func scalePresent(fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        toView.alpha = 0.0
        toView.layer.anchorPoint = CGPoint(x: 0, y: 1.0)
        toView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: -screenHeight)
        toView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: ViewTransitionManager.duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            toView.alpha = 1.0
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { (_) in
            toView.alpha = 1.0
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            transitionContext.completeTransition(true)
        }
        
    }
    
    private func scaleDismiss(fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning){
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        UIView.animate(withDuration: ViewTransitionManager.duration, animations: {
            fromView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
    private func circlePresent(fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.addSubview(toView)
        let startCircle: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: screenWidth / 2, y: screenHeight / 2, width: a(50), height: a(50)))
        let x: CGFloat = screenWidth / 2
        let y: CGFloat = screenHeight / 2
        //求出半径 pow a的x次方
        let radius: CGFloat = sqrt(pow(x, 2) + pow(y, 2))
        let endCircle: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        let endPath = UIBezierPath(rect: toView.frame)
        endPath.append(endCircle)
        let startPath = UIBezierPath(rect: toView.frame)
        startPath.append(startCircle)
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.path = endPath.cgPath
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.fillRule = .evenOdd
        
        let maskLayerAnimation: CABasicAnimation = CABasicAnimation()
        maskLayerAnimation.fromValue = startPath.cgPath
        maskLayerAnimation.toValue = endPath.cgPath
        maskLayerAnimation.duration = transitionDuration(using: transitionContext)
        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        maskLayerAnimation.setValue(transitionContext, forKey: "transitionContext")
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
        
        let blackLayer = CALayer()
        blackLayer.frame = toView.bounds
        blackLayer.backgroundColor = UIColor.rgba(0, 0, 0, 0.6).cgColor
        blackLayer.mask = maskLayer
        toView.layer.addSublayer(blackLayer)
    }
    
    private func circleDismiss(fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0
        }) { b in
            transitionContext.completeTransition(true)
        }
    }
    
    private func topPresent(fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        toView.subviews[1].transform = CGAffineTransform(translationX: 0, y: screenHeight)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.subviews[1].transform = CGAffineTransform(translationX: 0, y: 0)
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
    private func topDismiss(fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.subviews[1].transform = CGAffineTransform(translationX: 0, y: screenHeight)
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}

extension ViewTransitionManager: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if ViewTransitionManager.type == .circle {
            let transitionContext: UIViewControllerContextTransitioning = anim.value(forKey: "transitionContext") as! UIViewControllerContextTransitioning
            transitionContext.completeTransition(true)
            if ViewTransitionManager.tran == .present {
                transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view.layer.mask = nil
                let layers = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view.layer.sublayers
                layers![layers!.count - 1].removeFromSuperlayer()
            }
        }
    }
}


