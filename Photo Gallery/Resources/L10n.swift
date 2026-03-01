//
//  L10n.swift
//  Photo Gallery
//

import Foundation

enum L10n {

    enum Gallery {
        static let title = NSLocalizedString("gallery.title", comment: "Gallery screen title")
    }

    enum Favorites {
        static let title = NSLocalizedString("favorites.title", comment: "Favorites screen title")
        static let empty = NSLocalizedString("favorites.empty", comment: "Empty favorites placeholder")
    }

    enum Detail {
        static let moreHint = NSLocalizedString("detail.moreHint", comment: "Hint to expand detail panel")
    }

    enum Photo {
        static let noDescription = NSLocalizedString(
            "photo.noDescription",
            comment: "Fallback when photo has no description"
        )
    }

    enum Action {
        static let retry = NSLocalizedString("action.retry", comment: "Retry button title")
    }

    enum Error {
        static let invalidURL = NSLocalizedString("error.invalidURL", comment: "Invalid URL error")
        static let invalidResponse = NSLocalizedString(
            "error.invalidResponse",
            comment: "Invalid server response error"
        )
        static let decodingFailed = NSLocalizedString(
            "error.decodingFailed",
            comment: "JSON decoding error"
        )

        static func httpError(statusCode: Int) -> String {
            String(format: NSLocalizedString("error.httpError", comment: "HTTP error with status code"), statusCode)
        }
    }
}
