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
            let originalQuestions = try await questionsManager.getQuestionsFromDisk(filename: "original-questions")
//            print("Original Questions loaded")
            let newQuestions = try await questionsManager.getQuestionsFromDisk(filename: "2025-06-08-questions")
//            print(newQuestions.count)

            /// The reordering does not work properly because of difference of wording in source and new questions
//            let orderedQuestions = reorderQuestions(source: originalQuestions, questions: Set(newQuestions))
            let updatePairs: [Pair] = [.init(source: "72", new: "162"),
                                       .init(source: "73", new: "163")]
            let updatedQuestions: [Question] = updateSpecificQuestions(source: originalQuestions, questions: Set(newQuestions),
                                                                       pairs: updatePairs)
            // Ignoring the ID updates because it isnt important
            //            let updatedQuestions = updateIDs(questions: originalQuestions)
            try await questionsManager.writeQuestionsToFile(updatedQuestions)
            
            
//            var newQuestions = try await questionsManager.getQuestionsFromDisk(filename: "2025-06-08-questions")
//            let originalQuestions = try await questionsManager.getQuestionsFromDisk(filename: "2025-06-12-category-added")
//            addCategoryAndContext(to: &newQuestions, originalQuestions: originalQuestions)
//            try await questionsManager.writeQuestionsToFile(newQuestions)

//            let updatePairs: [Pair] = [.init(source: "159", new: "15"),
//                                       .init(source: "163", new: "9"),
//                                       .init(source: "164", new: "10")]
//            let updatedQuestions: [Question] = updateSpecificQuestions(source: originalQuestions, questions: Set(newQuestions),
//                                                                       pairs: updatePairs)
//            try await questionsManager.writeQuestionsToFile(updatedQuestions)

        } catch {
            print("Error: \(error)")
        }

        print("Hello, World!")
    }
    
    /// This function is not needed because category and context have already been added to the json file
    func addCategoryAndContext(to questions: inout Array<Question>, originalQuestions: Array<Question>) {
        var questionNumbers: [Int] = Array(0...459).map { $0 }

        for (index, question) in questions.enumerated() {
            if question.question == originalQuestions[index].question {
                questions[index].category = originalQuestions[index].category
                questions[index].context = originalQuestions[index].context
                questionNumbers.removeAll(where: { $0 == index })
            } else {
                print("Question not found \n \(question.question) \n \(originalQuestions[index].question)")
            }
        }
        if !questionNumbers.isEmpty {
            print ("The question numbers of Original Questions that were not found in latest data: \(questionNumbers.count) ")
            print( questionNumbers.map {String ($0) }.joined(separator: ", "))
        }

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
                                        category: foundQuestion.category,
                                        question: foundQuestion.question,
                                        a: foundQuestion.a,
                                        b: foundQuestion.b,
                                        c: foundQuestion.c,
                                        d: foundQuestion.d,
                                        solution: foundQuestion.solution,
                                        context: foundQuestion.context,
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
    /// Does not fully work because the source question and the new question text dont align
    func reorderQuestions(source: [Question], questions: Set<Question>) -> [Question] {
        var questionNumbers: [String] = Array(1...460).map { String($0) }
        var output: [Question] = []
        for sourceQuestion in source {
            if let foundQuestion = questions.first(where: { q in
                q == sourceQuestion
            }) {
                output.append(.init(id: sourceQuestion.id,
                                    num: sourceQuestion.num,
                                    category: sourceQuestion.category,
                                    question: foundQuestion.question,
                                    a: foundQuestion.a,
                                    b: foundQuestion.b,
                                    c: foundQuestion.c,
                                    d: foundQuestion.d,
                                    solution: foundQuestion.solution,
                                    context: foundQuestion.context,
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
            
            let newQuestion = Question(id: newID, num: question.num, category: question.category, question: question.question,
                                       a: question.a, b: question.b, c: question.c, d: question.d,
                                       solution: question.solution, context: question.context, translation: question.translation,
                                       imageUrl: question.imageUrl)
            output.append(newQuestion)
        }
        return output
    }
}
