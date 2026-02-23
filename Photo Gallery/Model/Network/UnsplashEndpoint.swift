//
//  UnsplashEndpoint.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 23.02.26.
//

import Foundation

enum UnsplashEndpoint: Endpoint {
    case listPhotos(page: Int, perPage: Int)

    var baseURL: String {
        "https://api.unsplash.com"
    }

    var path: String {
        switch self {
        case .listPhotos:
            return "/photos"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .listPhotos(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        }
    }

    var headers: [String: String] {
        ["Authorization": "Client-ID \(APIKeyProvider.unsplashAccessKey)"]
    }
}
