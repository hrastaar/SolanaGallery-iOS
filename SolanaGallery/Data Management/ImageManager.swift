//
//  ImageManager.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/21/22.
//

import UIKit

class ImageManager {
    static let sharedInstance = ImageManager()
    
    var imageCache = NSCache<NSString, UIImage>()

    func fetchImage(imageUrlString: String, completion: @escaping (UIImage?) -> Void) -> Void {
        if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: imageUrlString),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            completion(nil)
            return
        }
        
        imageCache.setObject(image, forKey: imageUrlString as NSString)
        completion(image)
        return
    }
}
