//
//  TestData.swift
//  Photo GalleryTests
//
//  Created by Никита Горьковой on 24.02.26.
//

@testable import Photo_Gallery

@MainActor
enum TestData {

    static func makePhoto(
        id: String = "test-id",
        slug: String? = "test-slug",
        description: String? = "Test description",
        altDescription: String? = "Alt description",
        userName: String = "Test User",
        username: String = "testuser"
    ) -> UnsplashPhoto {
        UnsplashPhoto(
            id: id,
            slug: slug,
            description: description,
            altDescription: altDescription,
            urls: PhotoURLs(
                raw: "https://example.com/raw.jpg",
                full: "https://example.com/full.jpg",
                regular: "https://example.com/regular.jpg",
                small: "https://example.com/small.jpg",
                thumb: "https://example.com/thumb.jpg"
            ),
            user: PhotoUser(name: userName, username: username)
        )
    }

    static func makePhotos(count: Int) -> [UnsplashPhoto] {
        (0..<count).map { makePhoto(id: "photo-\($0)", slug: "photo-slug-\($0)") }
    }
}
