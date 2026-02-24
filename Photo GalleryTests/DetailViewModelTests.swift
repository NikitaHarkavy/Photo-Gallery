//
//  DetailViewModelTests.swift
//  Photo GalleryTests
//
//  Created by Никита Горьковой on 24.02.26.
//

@testable import Photo_Gallery
import Testing

@Suite("DetailViewModel")
@MainActor
struct DetailViewModelTests {

    private let mockStore: MockFavoritesStore
    private let photos: [UnsplashPhoto]
    private let viewModel: DetailViewModel

    init() {
        mockStore = MockFavoritesStore()
        photos = TestData.makePhotos(count: 3)
        viewModel = DetailViewModel(
            photos: photos,
            initialIndex: 1,
            favoritesStore: mockStore
        )
    }

    @Test("numberOfPhotos returns correct count")
    func numberOfPhotos() {
        #expect(viewModel.numberOfPhotos == 3)
    }

    @Test("Initial index is set correctly")
    func initialIndex() {
        #expect(viewModel.currentIndex == 1)
    }

    @Test("item(at:) maps photo data correctly")
    func itemMapping() {
        let item = viewModel.item(at: 0)
        #expect(item.id == photos[0].id)
        #expect(item.title == photos[0].displayTitle)
        #expect(item.description == photos[0].displayDescription)
        #expect(item.authorName == photos[0].user.name)
    }

    @Test("toggleFavorite changes the favorite state")
    func toggleFavorite() {
        #expect(!viewModel.item(at: 0).isFavorite)
        viewModel.toggleFavorite(at: 0)
        #expect(viewModel.item(at: 0).isFavorite)
    }

    @Test("updateCurrentIndex updates the index")
    func updateIndex() {
        viewModel.updateCurrentIndex(2)
        #expect(viewModel.currentIndex == 2)
    }
}
