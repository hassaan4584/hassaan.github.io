//
//  QuestionsManager.swift
//  LebenInDeutschland-DataParser
//
//  Created by Hassaan Ahmed on 08.06.25.
//

import Foundation
import Combine

class QuestionsManager: ObservableObject {

    var allQuestions: [Question]

    init() {
        allQuestions = []
    }

    @discardableResult
    func getQuestionsFromDiskWithPublisher() -> AnyPublisher<[Question], Error> {
        return Future<[Question], Error> { [weak self] promise in
            Task {
                do {
                    let nsdata = NSData(contentsOfFile: Bundle.main.path(forResource: "original-questions", ofType: "json")!)
                    let data = Data(nsdata!)
                    let questionList = try JSONDecoder().decode([Question].self, from: data)
                    guard questionList.count > 300 else {
                        promise(.failure(QuestionsListError.noQuestionsAvailable))
                        return
                    }
                    self?.allQuestions = questionList
                    promise(.success(questionList))
                } catch {
                    promise(.failure(QuestionsListError.unableToReadQuestionsFile))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getQuestionsFromDisk(filename: String = "original-questions") async throws -> [Question] {
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "json") else {
            throw QuestionsListError.unableToReadQuestionsFile
        }
        
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        let questionList = try JSONDecoder().decode([Question].self, from: data)
        
        guard questionList.count > 300 else {
            throw QuestionsListError.noQuestionsAvailable
        }
        
        self.allQuestions = questionList
        
        return questionList
    }
    
    // 2. Update questions and save to new file
       func writeQuestionsToFile(_ questions: [Question], filename: String = "updated-questions") async throws {
           var emptyCategory: [String] = []
           var emptyContext: [String] = []
           let updatedQuestions = questions.map { q in
               if q.category.isEmpty {
                   emptyCategory.append(q.num)
               }
               if q.context == nil {
                   emptyContext.append(q.num)
               }
               return OutputQuestion(id: q.id, num: q.num, intNumber: q.intNumber!, category: q.category, question: q.question, a: q.a, b: q.b,
                                     c: q.c, d: q.d, solution: q.solution, context: q.context ?? "", translation: q.translation,
                              imageUrl: q.imageUrl)
           }
           print ("Empty category: \(emptyCategory)")
           print ("Empty context: \(emptyContext)")
           
           // Create new URL for the updated file
           let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let outputURL = documentsURL.appendingPathComponent("\(filename).json")
           
           do {
               let encoder = JSONEncoder()
               encoder.outputFormatting = .prettyPrinted
               encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
               let data = try encoder.encode(updatedQuestions)
               var stringData = String(data: data, encoding: .utf8)!
               stringData = stringData.replacingOccurrences(of: "_keyA_", with: "")
                   .replacingOccurrences(of: "_keyB_", with: "")
                   .replacingOccurrences(of: "_keyC_", with: "")
                   .replacingOccurrences(of: "_keyD_", with: "")
                   .replacingOccurrences(of: "_keyE_", with: "")
                   .replacingOccurrences(of: "_keyF_", with: "")
                   .replacingOccurrences(of: "_keyG_", with: "")
                   .replacingOccurrences(of: "_keyH_", with: "")
                   .replacingOccurrences(of: "_keyI_", with: "")
                   .replacingOccurrences(of: "_keyJ_", with: "")
                   .replacingOccurrences(of: "_keyK_", with: "")
                   .replacingOccurrences(of: "_keyL_", with: "")
                   .replacingOccurrences(of: "_keyM_", with: "")
                   .replacingOccurrences(of: "_keyN_", with: "")
                   .replacingOccurrences(of: "_keyO_", with: "")
                   .replacingOccurrences(of: "_keyP_", with: "")
                   .replacingOccurrences(of: "\" : ", with: "\": ")
               let newData = stringData.data(using: .utf8)!
               try newData.write(to: outputURL, options: [.atomic])
               print("Successfully saved updated questions to: \(outputURL.path)")
               try validateOutputSuccess(fileURL: outputURL, actualQuestions: questions)
           } catch {
               print("Failed to write updated questions: \(error)")
               throw QuestionsListError.failedToWriteUpdatedFile
           }

       }
    
    func validateOutputSuccess(fileURL: URL, actualQuestions: [Question]) throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw NSError(domain: "FileError", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "File not found at \(fileURL.path)"])
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let outputQuestions = try decoder.decode([Question].self, from: data)
        if outputQuestions.count != actualQuestions.count {
            fatalError("The number of questions in the output file does not match.")
        }
    }
}
