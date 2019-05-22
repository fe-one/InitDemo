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
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
        view.addSubview(rootContainer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func pinToParent(parent: UIView, subView: UIView, _ next: @escaping () -> ()) {
        parent.addSubview(subView)
        pinContainer.append(next)
    }
    
    override func viewDidLayoutSubviews() {
        rootContainer.pin.all(view.pin.safeArea)
        rootContainer.flex.layout()
        // 然后再执行相关的pin
        for pin in pinContainer {
            pin()
        }
        // 在初始化或viewDidLoad 时 navigationController 为nil要在之后阶段在调用对navigationController的操作
        openSwipe()
    }
    
    //开启 push视图 右滑手势()
    fileprivate func openSwipe(){
        if(self.navigationController != nil){
            self.navigationController!.interactivePopGestureRecognizer!.delegate = self as! UIGestureRecognizerDelegate;
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController?.viewControllers.count == 1{
            return false;
        }
        return true;
    }
}

// 用于在页面内迁入弹框
class BaseModalController: BaseViewController {
    var containerView = UIView()
    var onCancel: (() -> ())?
    var onDismiss: (() -> ())?
    var shouldCancel = true
    
    init() {
        super.init(title: "Modal")
        modalPresentationStyle = .overCurrentContext
        // 背景区域点击消失
        let tapCancel = UITapGestureRecognizer()
        tapCancel.addTarget(self, action: #selector(cancel))
        view.addGestureRecognizer(tapCancel)
        // 显示区域，即子视图 拦截事件
        let none = UITapGestureRecognizer()
        none.addTarget(self, action: #selector(doNothing))
        containerView.addGestureRecognizer(none)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func cancel() {
        if shouldCancel {
            onCancel?()
            self.dismiss(animated: true)
        }
    }
    
    @objc func doNothing() {
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        onDismiss?()
    }
}
