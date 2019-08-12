//
//  Logger.swift
//  InitDemo
//
//  Created by dev on 2019/8/12.
//  Copyright © 2019 dev. All rights reserved.
//

import SwiftProtobuf
import AppsFlyerLib
import UIKit

enum LoggerPage: String {
    case app = "app"
    case modal = "modal"
    case guide = "guide"
    case payGuide = "payGuide"
    case payDuet = "payDuet"
    case authorize = "authorize"
    case index = "index"
    case duet = "duet"
    case select = "select"
    case popRating = "popRating"
}

class Logger {
    static func console(_ items: Any...) {
        #if DEBUG
        print(items)
        #endif
    }
    
    static func error(_ message: String) -> Error {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    static func logEvent(page: LoggerPage, name: String, parameters: [String: Any] = [:]) {
        let btnName = "event_\(page.rawValue)_\(name)"
        Logger.log(btnName, parameters: parameters)
    }
    
    static func logErr(page: LoggerPage, name: String, err: Error? = nil, parameters: [String: Any] = [:]) {
        let btnName = "error_\(page.rawValue)_\(name)"
        var params = parameters
        params["error"] = err?.localizedDescription
        Logger.log(btnName, parameters: params)
    }
    
    private static func log(_ name: String, parameters: [String: Any] = [:]) {
        AppsFlyerTracker.shared().trackEvent(name, withValues: parameters);
        Logger.logUpload(name, parameters: parameters)
    }
    
    // 自己服务器再存一份日志
    static func logUpload(_ name: String, parameters: [String: Any] = [:]) {
        var body = LogMessage()
        body.name = name
        body.ver = UIDevice.current.appVersion
        do {// 尝试json parameters
            if parameters.count > 0, let message = String(data: try JSONSerialization.data(withJSONObject: parameters), encoding: .utf8) {
                body.message = Base64Encrypt(s: message, salt: 8)
            }
        } catch {
        }
        
        request("/log", method: .post, encoding: ProtobufEncoding(body))
    }
}

