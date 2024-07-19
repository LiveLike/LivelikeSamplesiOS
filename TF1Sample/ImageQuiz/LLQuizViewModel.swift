import Foundation

protocol LLQuizViewModelListener {
    func quizDidExpire()
    func selectedChoiceDidChange(choiceID: String?)
    func answerSubmitted()
    func votePercentageDidChange(choiceID: String, votePercentage: Float)
}

protocol LLQuizViewModel {
    
    var tag: String { get set }
    var question: String { get set }
    var isQuizExpired: Bool { get }
    var isAnswerSubmitted: Bool { get }
    
    var choices: [LLQuizOptionViewModel] { get set }
    
    var selectedChoiceID: String? { get }
    
    func submitAnswer()
    
    var delegate: LLQuizViewModelListener? { get set }
    
    func registerImpression()
    
    func selectChoice(choiceID: String)
    
    func getVotePercentage(choiceID: String) -> Float
}

class LLQuizOptionViewModel {
    init(id: String, isCorrect: Bool, imageURL: URL? = nil, text: String) {
        self.id = id
        self.isCorrect = isCorrect
        self.imageURL = imageURL
        self.text = text
    }
    
    let id: String
    let isCorrect: Bool
    let imageURL: URL?
    let text: String
}
