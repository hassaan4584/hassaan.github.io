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
    let question: String
    let a: String
    let b: String
    let c: String
    let d: String
    let solution: String
    let translation: [String: Translation]
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case num, question, a, b, c, d, solution, translation
        case imageUrl = "image"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container =  encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(num, forKey: .num)
        try container.encode(question, forKey: .question)
        try container.encode(a, forKey: .a)
        try container.encode(b, forKey: .b)
        try container.encode(c, forKey: .c)
        try container.encode(d, forKey: .d)
        try container.encode(imageUrl, forKey: .imageUrl)
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
    static func random() -> Question {
        let questionText = "\(String.random(length: 5)) In Germany, people are allowed to openly say something against the government because ..."
        return Question(id: .random(length: 10),
                        num: "Question no 1",
                        question: questionText,
                        a: "freedom of religion applies here. freedom of religion applies here.",
                        b: "people pay taxes.",
                        c: "people have the right to vote.",
                        d: "freedom of expression applies here.",
                        solution: "d",
                        translation: [:],
                        imageUrl: Bool.random() ? "https://www.einbuergerungstest-online.de/img/fragen/055.png" : nil
                        )
    }

    static func randomSmall() -> Question {
        let questionText = "\(String.random(length: 5)) In Germany, people are allowed to openly say something against the government because ..."
        return Question(id: .random(length: 10),
                        num: "Question no 1",
                        question: questionText,
                        a: "1",
                        b: "2",
                        c: "3",
                        d: "4",
                        solution: "d",
                        translation: [:],
                        imageUrl: Bool.random() ? "https://www.einbuergerungstest-online.de/img/fragen/055.png" : nil
                        )
    }

    static func incorrectImage() -> Question {
        let questionText = "\(String.random(length: 5)) In Germany, the government because ..."
        return Question(id: .random(length: 10),
                        num: "Question no 1",
                        question: questionText,
                        a: "people have the right to vote.",
                        b: "people have the right to vote.",
                        c: "people have the right to vote.",
                        d: "people have the right to vote.",
                        solution: "d",
                        translation: [:],
                        imageUrl: "https://www.einbuergerungstest-online"
                        )
    }

}

struct OutputQuestion: Encodable {
    let id: String
    let num: String
    let question: String
    let a: String
    let b: String
    let c: String
    let d: String
    let solution: String
    let translation: [String: Translation]
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id = "_keyA_id"
        case num = "_keyB_num"
        case question = "_keyC_question"
        case a = "_keyD_a"
        case b = "_keyE_b"
        case c = "_keyF_c"
        case d = "_keyG_d"
        case solution = "_keyH_solution"
        case imageUrl = "_keyI_image"
        case translation = "_keyJ_translation"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container =  encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(num, forKey: .num)
        try container.encode(question, forKey: .question)
        try container.encode(a, forKey: .a)
        try container.encode(b, forKey: .b)
        try container.encode(c, forKey: .c)
        try container.encode(d, forKey: .d)
        try container.encode(imageUrl, forKey: .imageUrl)
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
    
    init(id: String, num: String, question: String, a: String, b: String, c: String, d: String, solution: String, translation: [String : Question.Translation], imageUrl: String?) {
        self.id = id
        self.num = num
        self.question = question
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.solution = solution
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


