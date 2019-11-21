//
//  ImageDownloadService.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/20/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Alamofire
import AlamofireImage
import Foundation

class ImageDownloaderService {
    
    /**
     Shared instance variable
     */
    static let shared = ImageDownloaderService()
    
    /**
     Image cache handler variable
     */
    private let imageCache = AutoPurgingImageCache()
    
    private init() {}
    
    func cachedImage(withURL url: String) -> UIImage? {
        return imageCache.image(withIdentifier: url)
    }
    
    func requestImage(withURL url: String, callback: ((Error?) -> Void)? = nil) {
        Alamofire.request(url).responseImage { [weak self] response in
            guard response.error == nil else {
                callback?(response.error)
                return
            }
            
            switch response.result {
            case .success(let image):
                self?.imageCache.add(image, withIdentifier: url)
                callback?(nil)
            case .failure(let error):
                callback?(error)
            }
        }
    }
}
