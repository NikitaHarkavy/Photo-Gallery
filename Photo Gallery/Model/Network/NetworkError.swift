//
//  NetworkError.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 23.02.26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.Error.invalidURL
        case .invalidResponse:
            return L10n.Error.invalidResponse
        case .httpError(let statusCode):
            return L10n.Error.httpError(statusCode: statusCode)
        case .decodingError:
            return L10n.Error.decodingFailed
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}
