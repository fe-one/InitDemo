//
//  Http.swift
//  InitDemo
//
//  Created by dev on 2019/5/22.
//  Copyright © 2019 dev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftProtobuf

private let baseURL = "http://127.0.0.1:8081/api/v1" // 本地测试



private let alamoFireManager: SessionManager = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 40
    configuration.timeoutIntervalForResource = 40
    
    return Alamofire.SessionManager(configuration: configuration)
}()

// 补全url
func u(_ path: String) -> String {
    return "\(baseURL)\(path)"
}

struct ProtobufEncoding: ParameterEncoding {
    private let body: Message
    
    init(_ body: Message) {
        self.body = body
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        urlRequest.httpBody = try body.jsonUTF8Data()
        
        // 设置headers
        var headers: HTTPHeaders
        if let existingHeaders = urlRequest.allHTTPHeaderFields {
            headers = existingHeaders
        } else {
            headers = HTTPHeaders()
        }
        headers["Content-Type"] = "application/json"
        urlRequest.allHTTPHeaderFields = headers
        // 始终尝试把user_id加到query上
        guard let url = urlRequest.url else {
            throw AFError.parameterEncodingFailed(reason: .missingURL)
        }
//        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
//            if UserManager.shared.user.userID != "" {
//                urlComponents.percentEncodedQuery = "user_id=" + UserManager.shared.user.userID
//                urlRequest.url = urlComponents.url
//            }
//        }
        //        print(try body.jsonString(), urlRequest.url)
        return urlRequest
    }
}

func request(_ path: String, method: HTTPMethod = .get, parameters: Parameters? = nil,
             encoding: ParameterEncoding = URLEncoding.default,
             complete completionHandler: ((Data) throws -> ())? = nil,
             error errorHandler: ((Error) -> ())? = nil) {
    alamoFireManager.request(u(path), method: method, parameters: parameters, encoding: encoding)
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let value):
                do {
                    try completionHandler?(value)
                } catch {
                    print("request complete handler error:", error)
                }
            case .failure(let error):
                print("request error:", error)
                errorHandler?(error)
            }
    }
}

