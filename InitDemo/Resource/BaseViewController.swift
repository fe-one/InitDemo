//
//  BaseViewController.swift
//  InitDemo
//
//  Created by dev on 2019/5/22.
//  Copyright © 2019 dev. All rights reserved.
//
import UIKit
import FlexLayout
import PinLayout

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    let rootContainer = UIView()
    var pinContainer = [() -> ()]()
    var hadDidLayoutSubviews = false
    var page = LoggerPage.app
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    var hideStatusBar = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    init(title: String, page: LoggerPage) {
        super.init(nibName: nil, bundle: nil)
        self.page = page
        self.title = title
        view.insertSubview(rootContainer, at: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 设置状态栏颜色为白色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func pinToParent(parent: UIView, subView: UIView, _ next: @escaping () -> ()) {
        parent.addSubview(subView)
        if hadDidLayoutSubviews {
            next()
        } else {
            pinContainer.append(next)
        }
    }
    
    override func viewDidLayoutSubviews() {
        safeArea = view.pin.safeArea
        rootContainer.pin.all(view.pin.safeArea)
        rootContainer.flex.layout()
        for pin in pinContainer {
            pin()
        }
        
        hadDidLayoutSubviews = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Logger.logEvent(page: page, name: "show")
        Logger.console("===\(page)_show")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        openSwipe()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Logger.logEvent(page: page, name: "hide")
        Logger.console("===\(page)_hide")
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //开启 push视图 右滑手势()
    fileprivate func openSwipe() {
        if (self.navigationController != nil) {
            self.navigationController!.interactivePopGestureRecognizer!.delegate = self as UIGestureRecognizerDelegate;
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController?.viewControllers.count == 1 {
            return false;
        }
        return true;
    }
}

fileprivate let wrapperTag = 1001

// hint
extension BaseViewController {
    func alertHint(message: String, _ vc: UIView? = nil) {
        let wrapper = UILabel()
        wrapper.text = message
        wrapper.font = UIFont.size(18)
        wrapper.textColor = .white
        wrapper.sizeToFit()
        wrapper.backgroundColor = UIColor.rgba(4, 4, 15, 0.5)
        let alertRootView = vc ?? view
        // 以tag为标示 1001
        alertRootView!.subviews.forEach { (view) in
            if view.tag == wrapperTag {
                view.removeFromSuperview()
            }
        }
        wrapper.tag = wrapperTag
        
        alertRootView!.addSubview(wrapper)
        wrapper.pin.center(to: alertRootView!.anchor.center)
        let f = wrapper.layer.frame
        let x = a(14.5)
        let y = a(11.5)
        wrapper.layer.frame = CGRect(x: f.minX - x, y: f.minY, width: f.size.width + 2 * x, height: f.size.height + 2 * y)
        wrapper.layer.cornerRadius = a(4)
        wrapper.textAlignment = .center
        // 自动定时消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            UIView.animate(withDuration: 0.3, animations: {
                wrapper.alpha = 0
            }, completion: { (isCompletion) in
                wrapper.removeFromSuperview()
            })
        }
    }
    
}

