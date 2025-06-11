//
//  ContentViewModel.swift
//  LebenInDeutschland-DataParser
//
//  Created by Hassaan Ahmed on 08.06.25.
//

import Foundation
import Combine


struct Pair {
    let sourceQuestionNum: String
    let newDataQuestionNum: String
    
    init(source: String, new: String) {
        self.sourceQuestionNum = source
        self.newDataQuestionNum = new
    }
}
class ContentViewModel: ObservableObject {
    
    
    init() {
        Task {
            await fetchData()
        }
    }
    func fetchData() async {
        let questionsManager = QuestionsManager()
        do {
//            let originalQuestions = try await questionsManager.getQuestionsFromDisk(filename: "original-questions")
//            print("Original Questions loaded")
            let newQuestions = try await questionsManager.getQuestionsFromDisk(filename: "2025-06-11-questions")
//            print(originalQuestions.count, newQuestions.count)

//            let orderedQuestions = reorderQuestions(source: originalQuestions, questions: Set(newQuestions))
//            let updatePairs: [Pair] = [.init(source: "72", new: "162"),
//                                       .init(source: "73", new: "163")]
//            let updatedQuestions: [Question] = updateSpecificQuestions(source: originalQuestions, questions: Set(newQuestions),
//                                                                       pairs: updatePairs)
//            let updatedQuestions = updateIDs(questions: originalQuestions)
            try await questionsManager.writeQuestionsToFile(newQuestions)

        } catch {
            print("Error: \(error)")
        }

        print("Hello, World!")
    }
    
    /// Updates the `source` questions  from the new `questions` list 
    func updateSpecificQuestions(source: [Question], questions: Set<Question>, pairs: [Pair]) -> [Question]{
        var pairs = pairs
        var output: [Question] = []
        for sourceQuestion in source {
            if let pair = pairs.first(where: {$0.sourceQuestionNum == sourceQuestion.num}) {
                if let foundQuestion = questions.first(where: { q in
                    q.num == pair.newDataQuestionNum
                }) {
                    output.append(.init(id: sourceQuestion.id,
                                        num: sourceQuestion.num,
                                        question: foundQuestion.question,
                                        a: foundQuestion.a,
                                        b: foundQuestion.b,
                                        c: foundQuestion.c,
                                        d: foundQuestion.d,
                                        solution: foundQuestion.solution,
                                        translation: foundQuestion.translation,
                                        imageUrl: foundQuestion.imageUrl))
                    pairs.removeAll { $0.sourceQuestionNum == pair.sourceQuestionNum &&
                        $0.newDataQuestionNum == pair.newDataQuestionNum }
                }
            } else {
                output.append(sourceQuestion)
            }
        }
        if !pairs.isEmpty {
            print ("The question numbers of Original Questions that were not found in latest data: \(pairs.count) ")
            print( pairs.map(\.sourceQuestionNum).joined(separator: ", "))

        }
        return output
    }
    
    /// Returns the list of questions in the order similar of `source`
    func reorderQuestions(source: [Question], questions: Set<Question>) -> [Question] {
        var questionNumbers: [String] = Array(1...460).map { String($0) }
        var output: [Question] = []
        for sourceQuestion in source {
            if let foundQuestion = questions.first(where: { q in
                q.question == sourceQuestion.question
            }) {
                output.append(.init(id: sourceQuestion.id,
                                    num: sourceQuestion.num,
                                    question: foundQuestion.question,
                                    a: foundQuestion.a,
                                    b: foundQuestion.b,
                                    c: foundQuestion.c,
                                    d: foundQuestion.d,
                                    solution: foundQuestion.solution,
                                    translation: foundQuestion.translation,
                                    imageUrl: foundQuestion.imageUrl))
                questionNumbers.removeAll(where: { $0 == sourceQuestion.num})
            }
        }
        
        if !questionNumbers.isEmpty {
            print ("The question numbers of Original Questions that were not found in latest data: \(questionNumbers.count) ")
            print( questionNumbers.joined(separator: ", "))
        }
        return output
    }
    
    func updateIDs(questions: [Question]) -> [Question] {
        var output: [Question] = []
        for (index, question) in questions.enumerated() {
            guard index > 20 else {
                output.append(question)
                continue
            }
            var newID = String(question.id.dropFirst(5))
            let random  = String.random(length: 5)
            newID = random + newID
            
            let newQuestion = Question(id: newID, num: question.num, question: question.question,
                                       a: question.a, b: question.b, c: question.c, d: question.d,
                                       solution: question.solution, translation: question.translation,
                                       imageUrl: question.imageUrl)
            output.append(newQuestion)
        }
        return output
    }
}
