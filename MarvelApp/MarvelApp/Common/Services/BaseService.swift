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

class BaseService {
    static let serverUrl = "http://gateway.marvel.com"
    static let privateKey = "bb10eccb2ff07631d2eabda3fe7561d0b9fb4444"
    static let publicKey = "7c2e898bfbbd5f229c16d3bc97aaee31"
    
    static func url(forEndpoint endpoint: String) -> String {
        let date = Date()
        let hashString = BaseService.hashString(withDate: date)
        return "\(serverUrl)\(endpoint)?ts=\(date.timeIntervalSince1970)&apikey=\(publicKey)&hash=\(hashString)"
    }
    
    private static func hashString(withDate date: Date) -> String {
        let data = MD5(string:"\(date.timeIntervalSince1970)\(privateKey)\(publicKey)")
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}

func MD5(string: String) -> Data {
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
