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
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "Server error (status: \(statusCode))"
        case .decodingError:
            return "Failed to parse server response"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}
