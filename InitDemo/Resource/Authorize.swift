//
//  Authorize.swift
//  InitDemo
//
//  Created by dev on 2019/8/29.
//  Copyright © 2019 dev. All rights reserved.
//

import Photos
import AssetsLibrary
import MediaPlayer
import CoreTelephony
import CoreLocation
import AVFoundation
import Speech

enum AuthorizeType: String {
    /// 相机
    case camera = "camera"
    /// 相册
    case photo = "photo"
    /// 位置
    case location = "location"
    /// 网络
    case network = "network"
    /// 麦克风
    case microphone = "microphone"
    /// 媒体库
    case media
    ///语音转文字
    case speechRecognizer = "speech"
}


class Authorize {
    static let shared = Authorize()
    
    func hasAuthorizeABy(_ type: AuthorizeType) -> Bool {
        switch type {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            return status == AVAuthorizationStatus.authorized
            
        default:
            return false
        }
    }
    
    func handle(_ type: AuthorizeType, _ isSet: Bool? = true, _ action: @escaping ((Bool) -> ()) = { _ in
        }) {
        switch type {
        case .network:
            self.authorizeNetwork(isSet, action)
        case .camera:
            self.authorizeCamera(isSet, action)
        case .photo:
            self.authorizePhoto(isSet, action)
        case .location:
            self.authorizeLocation(isSet, action)
        case .microphone:
            self.authorizeMicrophone(isSet, action)
        case .media:
            self.authorizeMedia(isSet, action)
        case .speechRecognizer:
            self.authorizeSpeechRecognizer(isSet, action)
        }
    }
    
    // MARK: - 开启媒体资料库/Apple Music 服务
    /// 开启媒体资料库/Apple Music 服务
    @available(iOS 9.3, *)
    func authorizeMedia(_ isSet: Bool? = nil, _ action: @escaping ((Bool) -> ())) {
        let authStatus = MPMediaLibrary.authorizationStatus()
        if authStatus == MPMediaLibraryAuthorizationStatus.notDetermined {
            MPMediaLibrary.requestAuthorization { (status) in
                if (status == MPMediaLibraryAuthorizationStatus.authorized) {
                    DispatchQueue.main.async {
                        action(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        action(false)
                        if isSet == true {
                            self.goSetting(.media)
                        }
                    }
                }
            }
        } else if authStatus == MPMediaLibraryAuthorizationStatus.authorized {
            action(true)
        } else {
            action(false)
            if isSet == true {
                goSetting(.media)
            }
        }
    }
    
    // MARK: - 检测是否开启联网
    /// 检测是否开启联网
    func authorizeNetwork(_ isSet: Bool? = nil, _ action: @escaping ((Bool) -> ())) {
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            if state == CTCellularDataRestrictedState.restrictedStateUnknown || state == CTCellularDataRestrictedState.restricted {
                DispatchQueue.main.async {
                    action(false)
                    if isSet == true {
                        self.goSetting(.network)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    action(true)
                }
            }
        }
        
        let state = cellularData.restrictedState
        print("\(state == CTCellularDataRestrictedState.restrictedStateUnknown) \(state == CTCellularDataRestrictedState.restricted)")
        if state == CTCellularDataRestrictedState.restrictedStateUnknown {
            DispatchQueue.main.async {
                action(true)
            }
        }
    }
    
    // MARK: - 检测是否开启定位
    /// 检测是否开启定位
    func authorizeLocation(_ isSet: Bool? = nil, _ action: @escaping ((Bool) -> ())) {
        var isOpen = false
        //    if CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .denied {
        //        isOpen = true
        //    }
        if CLLocationManager.authorizationStatus() != .restricted && CLLocationManager.authorizationStatus() != .denied {
            isOpen = true
        }
        if isOpen == false && isSet == true {
            goSetting(.location)
        }
        action(isOpen)
    }
    
    // MARK: - 检测是否开启摄像头
    /// 检测是否开启摄像头 (可用)
    func authorizeCamera(_ isSet: Bool? = nil, _ action: @escaping ((Bool) -> ())) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                DispatchQueue.main.async {
                    action(granted)
                    if granted == false && isSet == true {
                        self.goSetting(.camera)
                    }
                }
            }
        } else if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
            action(false)
            if isSet == true {
                self.goSetting(.camera)
            }
        } else {
            action(true)
        }
    }
    
    // MARK: - 检测是否开启相册
    /// 检测是否开启相册
    func authorizePhoto(_ isSet: Bool? = nil, _ action: @escaping ((Bool) -> ())) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization() { (status) in
                let granted = status != PHAuthorizationStatus.restricted && status != PHAuthorizationStatus.denied
                DispatchQueue.main.async {
                    action(granted)
                    if granted == false && isSet == true {
                        self.goSetting(.photo)
                    }
                }
            }
        } else if authStatus == PHAuthorizationStatus.restricted || authStatus == PHAuthorizationStatus.denied {
            action(false)
            if isSet == true {
                goSetting(.photo)
            }
        } else {
            action(true)
        }
    }
    
    // MARK: - 检测是否开启麦克风
    /// 检测是否开启麦克风
    func authorizeMicrophone(_ isSet: Bool? = true, _ action: @escaping ((Bool) -> ())) {
        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
        if permissionStatus == AVAudioSession.RecordPermission.undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                print("granted \(granted)")
                action(granted)
            }
        } else if permissionStatus == AVAudioSession.RecordPermission.denied || permissionStatus == AVAudioSession.RecordPermission.undetermined {
            if isSet == true {
                self.goSetting(.microphone)
            }
            action(false)
        } else {
            action(true)
        }
    }
    
    func authorizeSpeechRecognizer(_ isSet: Bool? = true, _ action: @escaping ((Bool) -> ())) {
        let status = SFSpeechRecognizer.authorizationStatus()
        var result = false
        if status == SFSpeechRecognizerAuthorizationStatus.authorized {
            result = true
        } else if status == SFSpeechRecognizerAuthorizationStatus.notDetermined { // 请求授权
            SFSpeechRecognizer.requestAuthorization { authStatus in
                OperationQueue.main.addOperation {
                    action(authStatus == .authorized)
                }
            }
            return
        } else {
            if isSet == true {
                self.goSetting(.speechRecognizer)
            }
        }
        action(result)
    }
    
    
    // MARK: - 跳转系统设置界面
    func goSetting(_ type: AuthorizeType? = nil) {
        let url = URL(string: UIApplication.openSettingsURLString)
        let action = {
            if UIApplication.shared.canOpenURL(url!) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (success) in })
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }
        }
        action()
    }
    
}
