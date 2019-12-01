import Foundation

struct Question {
    let text: String
    let answersTotal: Int
    var answers: Set<String>
}

extension Question: Decodable {
    init(from decoder: Decoder) throws {
        let question = try decoder.container(keyedBy: QuestionKeys.self)
        
        self.text = try question.decode(String.self, forKey: .text)
        self.answers = try question.decode(Set<String>.self, forKey: .answers)
        
        self.answersTotal = self.answers.count
    }
    
    
    enum QuestionKeys: String, CodingKey {
        case text = "question"
        case answers = "answer"
    }
    
}
