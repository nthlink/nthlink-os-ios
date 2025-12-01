//
//  ImageCacheManager.swift
//  nthLink
//
//  Created by Vaneet Modgill on 28/02/25.
//

import UIKit
import Kingfisher
struct ImageCacheKey {
    private let newsImage = "newsImage"
    
    func getNewsImageKey(url: String) -> String {
        return newsImage + url
    }
    
}

class ImageCacher:NSObject {
    static let shared = ImageCacher()
    private let cache = ImageCache.default
    
    private override init() {
        super.init()
    }
    
    func clearCache() {
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    func cacheImage(_ image: UIImage, cacheKey: String) {
        DispatchQueue.global().async { [weak self] in
            self?.cache.store(image, forKey: cacheKey)
        }
    }
   func getCacheImage(cacheKey: String, completionHandler: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.cache.retrieveImage(forKey: cacheKey, completionHandler: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completionHandler(value.image)
                    case .failure:
                        completionHandler(nil)
                    }
                }
            })
        }
    }
        
}
