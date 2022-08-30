//
//  SolanaGalleryAPIError.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 7/16/22.
//

import Foundation

class SolanaGalleryAPIError: Error {
    let error: Error?
    let message: String
    let errorType: SolanaGalleryAPIErrorType

    init(
        error: Error? = nil,
        message: String = "SolanaGalleryAPI Error occurred",
        errorType: SolanaGalleryAPIErrorType = .unknown
    ) {
        self.error = error
        self.message = message
        self.errorType = errorType
    }
}

enum SolanaGalleryAPIErrorType {
    case timeout
    case responseParsing
    case unknown
}
