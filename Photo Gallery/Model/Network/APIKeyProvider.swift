//
//  APIKeyProvider.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 23.02.26.
//

import Foundation

enum APIKeyProvider {

    static var unsplashAccessKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String,
              !key.isEmpty,
              key != "YOUR_UNSPLASH_ACCESS_KEY" else {
            fatalError(
                """
                ⚠️ Unsplash API key is missing.
                """
            )
        }
        return key
    }
}
