//
//  UnsplashPhoto.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 23.02.26.
//

import Foundation

struct UnsplashPhoto: Decodable, Sendable {
    let id: String
    let slug: String?
    let description: String?
    let altDescription: String?
    let urls: PhotoURLs
    let user: PhotoUser

    var displayTitle: String {
        if let slug, !slug.isEmpty {
            return slug
                .replacingOccurrences(of: "-", with: " ")
                .prefix(1).uppercased() + slug
                .replacingOccurrences(of: "-", with: " ")
                .dropFirst()
        }
        return user.name
    }

    var displayDescription: String {
        description ?? altDescription ?? "No description"
    }
}

struct PhotoURLs: Decodable, Sendable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoUser: Decodable, Sendable {
    let name: String
    let username: String
}
