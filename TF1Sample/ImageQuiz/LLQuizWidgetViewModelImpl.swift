import LiveLikeSwift

class LLQuizWidgetViewModelImpl: LLQuizViewModel {
    
    private let model: QuizWidgetModel
    
    init(model: QuizWidgetModel) {
        self.model = model
        self.tag = "QUIZ"
        self.question = model.question
        self.isQuizExpired = model.isInteractivityExpired()
        self.choices = model.choices.map {
            LLQuizOptionViewModel(
                id: $0.id,
                isCorrect: $0.isCorrect,
                imageURL: $0.imageURL,
                text: $0.text
            )
        }
        self.selectedChoiceID = model.mostRecentAnswer?.choiceID
        self.isAnswerSubmitted = model.mostRecentAnswer != nil
        
        model.delegate = self
    }
    
    var tag: String
    var question: String
    var isQuizExpired: Bool
    var choices: [LLQuizOptionViewModel]
    var selectedChoiceID: String? {
        didSet {
            self.delegate?.selectedChoiceDidChange(choiceID: selectedChoiceID)
        }
    }
    var isAnswerSubmitted: Bool
    
    var delegate: LLQuizViewModelListener?
    
    func submitAnswer() {
        guard let selectedChoiceID = selectedChoiceID else { return }
        guard !self.isAnswerSubmitted else { return }
        self.model.lockInAnswer(
            choiceID: selectedChoiceID
        ) { result in
            switch result {
            case .failure:
                break
            case .success:
                self.isAnswerSubmitted = true
                self.delegate?.answerSubmitted()
            }
        }
    }
    
    func registerImpression() {
        self.model.registerImpression()
    }
    
    func selectChoice(choiceID: String) {
        self.selectedChoiceID = choiceID
    }
    
    func getVotePercentage(choiceID: String) -> Float {
        guard let choice = model.choices.first(where: { $0.id  == choiceID }) else { return 0 }
        guard model.totalAnswerCount > 0 else { return 0 }
        let votePercentage = Float(choice.answerCount) / Float(model.totalAnswerCount)
        return votePercentage
    }
}

extension LLQuizWidgetViewModelImpl: QuizWidgetModelDelegate {
    func quizWidgetModel(
        _ model: QuizWidgetModel,
        answerCountDidChange answerCount: Int,
        forChoice choiceID: String
    ) {
        guard model.totalAnswerCount > 0 else {
            return
        }
        let votePercentage = Float(answerCount) / Float(model.totalAnswerCount)
        self.delegate?.votePercentageDidChange(choiceID: choiceID, votePercentage: votePercentage)
    }
}
