//
//  FavoritesStore.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 23.02.26.
//

import Foundation

protocol FavoritesStoreProtocol: AnyObject {
    func isFavorite(id: String) -> Bool
    func toggleFavorite(id: String)
}

final class FavoritesStore: FavoritesStoreProtocol {

    static let favoriteChangedNotification = Notification.Name("FavoritesStore.favoriteChanged")
    static let changedPhotoIDKey = "photoID"

    private let defaults: UserDefaults
    private let key = "favorites_photo_ids"

    private var favoriteIDs: Set<String> {
        get {
            let array = defaults.stringArray(forKey: key) ?? []
            return Set(array)
        }
        set {
            defaults.set(Array(newValue), forKey: key)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isFavorite(id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(id: String) {
        var ids = favoriteIDs
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        favoriteIDs = ids

        NotificationCenter.default.post(
            name: Self.favoriteChangedNotification,
            object: nil,
            userInfo: [Self.changedPhotoIDKey: id]
        )
    }
}
