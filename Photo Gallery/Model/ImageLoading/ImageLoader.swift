//
//  ImageLoader.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 23.02.26.
//

import UIKit

protocol ImageLoaderProtocol: AnyObject {
    func loadImage(from urlString: String) async -> UIImage?
    func cachedImage(for urlString: String) -> UIImage?
}

final class ImageLoader: ImageLoaderProtocol {
    
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 200
    }

    // MARK: - Public Methods

    func cachedImage(for urlString: String) -> UIImage? {
        cache.object(forKey: NSString(string: urlString))
    }

    func loadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)

        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await session.data(from: url)

            try Task.checkCancellation()

            guard let image = UIImage(data: data) else { return nil }

            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
}
