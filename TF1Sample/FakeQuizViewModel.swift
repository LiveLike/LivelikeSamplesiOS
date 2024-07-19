import Foundation

// for testing
class FakeQuizViewModel: LLQuizViewModel {
    func getVotePercentage(choiceID: String) -> Float {
        return 0
    }
    
    var selectedChoiceID: String? {
        didSet {
            self.delegate?.selectedChoiceDidChange(choiceID: selectedChoiceID)
        }
    }
    
    init(tag: String, question: String, choices: [LLQuizOptionViewModel], canSubmitAnswer: Bool, isQuizExpired: Bool, userDidAnswer: Bool) {
        self.tag = tag
        self.question = question
        self.choices = choices
        self.isQuizExpired = isQuizExpired
        self.isAnswerSubmitted = userDidAnswer
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            choices.forEach { choice in
                self.delegate?.votePercentageDidChange(choiceID: choice.id, votePercentage: Float.random(in: 0...1))
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
            self.delegate?.quizDidExpire()
        }
    }
    
    var tag: String
    
    var question: String
    
    var choices: [LLQuizOptionViewModel]
    
    var isAnswerSubmitted: Bool
    
    var isQuizExpired: Bool {
        didSet {
            
        }
    }
    
    func submitAnswer() {
        self.delegate?.answerSubmitted()
        self.isAnswerSubmitted = true
    }
    
    var delegate: (any LLQuizViewModelListener)?
    
    func registerImpression() {
    }
    
    func selectChoice(choiceID: String) {
        self.selectedChoiceID = choiceID
    }
}
