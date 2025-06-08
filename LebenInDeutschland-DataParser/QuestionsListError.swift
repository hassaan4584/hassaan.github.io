//
//  QuestionsListError.swift
//  LebenInDeutschland-DataParser
//
//  Created by Hassaan Ahmed on 08.06.25.
//

import Foundation

enum QuestionsListError: Error {
    case noFavoritesAvailable
    case unableToLoadData
    case noQuestionsAvailable
    case unableToReadQuestionsFile
    case unknown
    case failedToWriteUpdatedFile


    var localizedDescription: String {
        switch self {
        case .noFavoritesAvailable:
            return "No favorite questions available"
        case .unableToLoadData:
            return "Unable to load questions"
        case .noQuestionsAvailable:
            return "No questions available"
        case .unableToReadQuestionsFile:
            return "Unable to read questions file"
        case .unknown:
            return "Some unknown error occurred2"
        case .failedToWriteUpdatedFile:
            return "Failed to write updated questions file"
        }
    }
}

