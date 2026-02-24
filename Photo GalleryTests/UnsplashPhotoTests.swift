//
//  UnsplashPhotoTests.swift
//  Photo GalleryTests
//
//  Created by Никита Горьковой on 24.02.26.
//

@testable import Photo_Gallery
import Testing

@Suite("UnsplashPhoto")
@MainActor
struct UnsplashPhotoTests {

    @Test("displayTitle formats slug into readable title")
    func displayTitleWithSlug() {
        let photo = TestData.makePhoto(slug: "beautiful-sunset-over-ocean")
        #expect(photo.displayTitle == "Beautiful sunset over ocean")
    }

    @Test("displayTitle falls back to user name when slug is nil")
    func displayTitleWithoutSlug() {
        let photo = TestData.makePhoto(slug: nil, userName: "John Doe")
        #expect(photo.displayTitle == "John Doe")
    }

    @Test("displayTitle falls back to user name when slug is empty")
    func displayTitleWithEmptySlug() {
        let photo = TestData.makePhoto(slug: "", userName: "John Doe")
        #expect(photo.displayTitle == "John Doe")
    }

    @Test("displayDescription prefers description over altDescription")
    func displayDescriptionPrimary() {
        let photo = TestData.makePhoto(description: "A beautiful photo")
        #expect(photo.displayDescription == "A beautiful photo")
    }

    @Test("displayDescription falls back to altDescription")
    func displayDescriptionFallback() {
        let photo = TestData.makePhoto(description: nil, altDescription: "Alt text")
        #expect(photo.displayDescription == "Alt text")
    }

    @Test("displayDescription returns placeholder when both are nil")
    func displayDescriptionPlaceholder() {
        let photo = TestData.makePhoto(description: nil, altDescription: nil)
        #expect(photo.displayDescription == "No description")
    }
}
