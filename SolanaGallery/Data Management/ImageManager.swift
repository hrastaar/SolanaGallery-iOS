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

    /// This function returns a UIImage object found from the url provided.
    /// Attempts to fetch UIImage from localized cache if available
    ///
    /// - Warning: The cache doesn't have a timeout. Data persists as long as the application session is open.
    /// - Parameter imageUrlString: String object representing a web url that contains an image
    /// - Returns: Completion that provides a UIImage? object that is nil if image not found
    func fetchImage(imageUrlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
            completion(cachedImage)
            return
        }

        guard let url = URL(string: imageUrlString),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data)
        else {
            completion(nil)
            return
        }

        imageCache.setObject(image, forKey: imageUrlString as NSString)
        completion(image)
    }
}
