//
//  Question.swift
//  LebenInDeutschland-DataParser
//
//  Created by Hassaan Ahmed on 08.06.25.
//
import Foundation

struct Question: Codable, Identifiable, Hashable, Equatable {
    let id: String
    let num: String
    var intNumber: Int?
    var category: String
    let question: String
    let a: String
    let b: String
    let c: String
    let d: String
    let solution: String
    var context: String?
    let translation: [String: Translation]
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case num, intNumber, category, question, a, b, c, d, solution, context, translation
        case imageUrl = "image"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container =  encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(num, forKey: .num)
        try container.encode(intNumber, forKey: .intNumber)
        try container.encode(category, forKey: .category)
        try container.encode(question, forKey: .question)
        try container.encode(a, forKey: .a)
        try container.encode(b, forKey: .b)
        try container.encode(c, forKey: .c)
        try container.encode(d, forKey: .d)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(context, forKey: .context)
        try container.encode(translation, forKey: .translation)
        try container.encode(solution, forKey: .solution)
    }
    
    struct Translation: Codable, Hashable, Equatable {
        let question: String
        let a: String
        let b: String
        let c: String
        let d: String
        let context: String
    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        let optionsLHS: String = [lhs.a, lhs.b, lhs.c, lhs.d].sorted().joined(separator: " ")
            .replacingOccurrences(of: ".", with: "")
        let optionsRHS: String = [rhs.a, rhs.b, rhs.c, rhs.d].sorted().joined(separator: " ")
            .replacingOccurrences(of: ".", with: "")

        return lhs.question.lowercased() == rhs.question.lowercased() ||
        lhs.translation["en"]?.question.lowercased() ?? "" == rhs.translation["en"]?.question.lowercased() ?? "A" ||
        lhs.translation["fr"]?.question ?? "" == rhs.translation["fr"]?.question ?? "A" ||
        optionsLHS == optionsRHS
        
    }
}

struct OutputQuestion: Encodable {
    let id: String
    let num: String
    let intNumber: Int
    let category: String?
    let question: String
    let a: String
    let b: String
    let c: String
    let d: String
    let solution: String
    let context: String
    let translation: [String: Translation]
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "_keyA_id"
        case num = "_keyB_num"
        case intNumber = "_keyC_intNumber"
        case category = "_keyC_category"
        case question = "_keyE_question"
        case a = "_keyF_a"
        case b = "_keyH_b"
        case c = "_keyI_c"
        case d = "_keyJ_d"
        case solution = "_keyL_solution"
        case imageUrl = "_keyM_image"
        case context = "_keyN_context"
        case translation = "_keyO_translation"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container =  encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(num, forKey: .num)
        try container.encode(intNumber, forKey: .intNumber)
        try container.encode(category, forKey: .category)
        try container.encode(question, forKey: .question)
        try container.encode(a, forKey: .a)
        try container.encode(b, forKey: .b)
        try container.encode(c, forKey: .c)
        try container.encode(d, forKey: .d)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(context, forKey: .context)
        try container.encode(translation, forKey: .translation)
        try container.encode(solution, forKey: .solution)
    }
    
    struct Translation: Codable {
        let question: String
        let a: String
        let b: String
        let c: String
        let d: String
        let context: String
        
        enum CodingKeys: String, CodingKey {
            case question = "_keyA_question"
            case a = "_keyB_a"
            case b = "_keyC_b"
            case c = "_keyD_c"
            case d = "_keyE_d"
            case context = "_keyF_context"
        }
        
        init(q: Question.Translation) {
            self.question = q.question
            self.a = q.a
            self.b = q.b
            self.c = q.c
            self.d = q.d
            self.context = q.context
        }
        
    }
    
    init(id: String, num: String, intNumber: Int, category: String, question: String, a: String, b: String, c: String, d: String, solution: String,
         context: String, translation: [String : Question.Translation], imageUrl: String) {
        self.id = id
        self.num = num
        self.intNumber = intNumber
        self.category = category
        self.question = question
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.solution = solution
        self.context = context
        var trans = [String:Translation]()
        for (key, value) in translation {
            trans[key] = Translation(q: value)
        }
        self.translation = trans
        self.imageUrl = imageUrl
    }
}
extension String {
    static func random(length: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let characterArr = String((0..<length).hashValue).map { _ in letters.randomElement()! }
        return String(characterArr[0..<length])
    }
}


