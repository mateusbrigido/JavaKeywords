import Foundation

struct GameState {
    
    private(set) var question: Question
    
    var isRunning: Bool = false
    var answers: Set<String>
    var rightAnswers: [String]
    
    var score: String {
        return String(format: "%02d/%02d", self.rightAnswers.count, self.question.answersTotal)
    }
    
    var won: Bool {
        return answers.count == 0
    }
    
    init(question: Question) {
        self.question = question
        self.answers = question.answers
        self.rightAnswers = [String]()
    }
    
    func checkWord(_ word: String) -> String? {
        return answers.first(where: { $0 == word })
    }
    
    mutating func addRightAnswer(_ word: String) {
        rightAnswers.insert(word, at: 0)
        answers.remove(word)
    }
    
    mutating func start() {
        isRunning = true
    }
    
    mutating func reset() {
        rightAnswers = [String]()
        isRunning = false
    }
    
}
