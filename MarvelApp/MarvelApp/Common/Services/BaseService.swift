//
//  BaseService.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
import Alamofire

class BaseService {
    static let serverUrl = "http://gateway.marvel.com"
    static let privateKey = "bb10eccb2ff07631d2eabda3fe7561d0b9fb4444"
    static let publicKey = "7c2e898bfbbd5f229c16d3bc97aaee31"
    
    static func url(forEndpoint endpoint: String, withQuery query: String = "") -> String {
        let date = Date()
        let hashString = BaseService.hashString(withDate: date)
        return "\(serverUrl)\(endpoint)?\(query)&ts=\(date.timeIntervalSince1970)&apikey=\(publicKey)&hash=\(hashString)"
    }
    
    private static func hashString(withDate date: Date) -> String {
        let data = MD5(string:"\(date.timeIntervalSince1970)\(privateKey)\(publicKey)")
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}

// Cryptography methods
extension BaseService {
    
    private static func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
}

// Error handling methods
extension BaseService {
    
    static func isErrorCode(_ code: Int) -> Bool {
        return code > 201
    }
    
    static func handle<T>(response: DataResponse<Any>, callback: ((T?, Error?) -> Void)? = nil) where T: Codable {
        switch response.result {
        case .success(let value):
            if let castedValue = value as? [String : Any] {
                if let jsonData = try? JSONSerialization.data(withJSONObject: castedValue,
                                                              options: .prettyPrinted),
                    let response = try? JSONDecoder().decode(GenericResponse<T>.self,
                                                             from: jsonData) {
                    if isErrorCode(response.code) {
                        // todo: create method to handle server errors
                        callback?(nil, MarvelError.invalidResponse)
                    } else {
                        callback?(response.data, nil)
                    }
                } else {
                    callback?(nil, MarvelError.invalidResponse)
                }
            }
            break
        case .failure(let error):
            callback?(nil, error)
        }

    }
}
