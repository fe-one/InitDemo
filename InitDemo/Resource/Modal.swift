//
//  Modal.swift
//  InitDemo
//
//  Created by dev on 2019/8/29.
//  Copyright © 2019 dev. All rights reserved.
//
import UIKit
import FlexLayout
import PinLayout

class ModalController: UIViewController {
    var onDismiss = {} // 关闭回调
    var onMainBtn = {} // 主要按钮功能回调
    
    var maskView = UIView()
    var container = UIView()
    
    var page: LoggerPage = .modal
    
    init(page: LoggerPage = .modal) {
        super.init(nibName: nil, bundle: nil)
        self.page = page
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupMask()
        setupContainer()
    }
    
    func setupMask() {
        maskView.frame = view.bounds
        maskView.backgroundColor = UIColor.rgba(4, 4, 15, 0.6)
        view.addSubview(maskView)
        maskView.addTapAction { [unowned self] in
            Logger.logEvent(page: self.page, name: "btnClose")
            self.dismiss(animated: true)
        }
    }
    
    func setupContainer() {
        container.backgroundColor = .white
        view.addSubview(container)
    }
    
    // 右上角叉关闭按钮 默认 40 x 40
    func setupTopRightCloseBtn(right: CGFloat, top: CGFloat, imageName: String) {
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: imageName), for: .normal)
        closeBtn.imageView?.frame.size = CGSize(width: a(11), height: a(11))
        closeBtn.addAction(for: .touchUpInside) { [unowned self] in
            Logger.logEvent(page: self.page, name: "btnClose")
            self.dismiss(animated: true)
        }
        
        container.addSubview(closeBtn)
        closeBtn.pin.size(a(40)).right(right).top(top)
    }
    
    // 中间的关闭文案按钮 example: not now
    func setupCenterCloseLabelBtn(bottom: CGFloat, font: UIFont, color: UIColor, title: String = "Not now") {
        let closeBtn = UIButton()
        closeBtn.setTitle(title, for: .normal)
        closeBtn.setTitleColor(color, for: .normal)
        closeBtn.titleLabel?.font = font
        closeBtn.addAction(for: .touchUpInside) { [unowned self] in
            Logger.logEvent(page: self.page, name: "btnClose")
            self.dismiss(animated: true)
        }
        
        container.addSubview(closeBtn)
        closeBtn.pin.width(50%).height(font.lineHeight).hCenter().bottom(bottom)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        onDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.logEvent(page: page, name: "show")
        Logger.console("===\(page)_show")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.logEvent(page: page, name: "hide")
        Logger.console("===\(page)_hide")
    }
    
}

