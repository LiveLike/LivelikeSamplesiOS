import EngagementSDK
import UIKit
import LiveLikeCore

class LLTextQuizWidgetViewController: UIViewController {
    private var choiceViews: [LLTextChoiceWidgetOptionView] = []
    
    var quizView: LLTextQuizWidgetView!

    var model: LLQuizViewModel

    init(model: LLQuizViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        
        self.quizView = LLTextQuizWidgetView()
        
        quizView.backgroundColor = .white
        
        quizView.choiceView.widgetTag.text = model.tag
        quizView.choiceView.widgetTag.font = UIFont(name: "TNTDigital-Bold", size: 10)
        quizView.choiceView.widgetTag.textColor = UIColor(red: 0.4, green: 0.06, blue: 0.4, alpha: 1)
        
        quizView.choiceView.titleLabel.text = model.question
        quizView.choiceView.titleLabel.font = UIFont(name: "TNTDigital-Medium", size: 14)
        quizView.choiceView.titleLabel.textColor = UIColor(red: 0.08, green: 0.14, blue: 0.18, alpha: 1)
        
        model.choices.enumerated().forEach { index, option in
            let choiceOptionView = LLTextChoiceWidgetOptionView(id: option.id)
            choiceOptionView.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.92, alpha: 1)
            choiceOptionView.layer.cornerRadius = 4
            choiceOptionView.textLabel.text = option.text
            choiceOptionView.percentageLabel.text =  "\(Int(round(model.getVotePercentage(choiceID: option.id) * 100)))%"
            choiceOptionView.textLabel.font = UIFont(name: "TNTDigital-Medium", size: 14)
            choiceOptionView.percentageLabel.font = UIFont(name: "TNTDigital-Medium", size: 18)
            if let imageURL = option.imageURL {
                MediaRepository.shared.getImage(url: imageURL) { result in
                    switch result {
                    case .failure:
                        break
                    case .success(let imageResult):
                        choiceOptionView.imageView.image = imageResult.image
                    }
                }
            }

            choiceOptionView.percentageLabel.isHidden = true
            choiceOptionView.progressView.isHidden = true
            choiceOptionView.buttonCompletion = { choiceView in
                self.model.selectChoice(choiceID: choiceView.id)
            }
            
            choiceOptionView.heightAnchor.constraint(equalToConstant: 45).isActive = true
            quizView.choiceView.optionsStackView.addArrangedSubview(choiceOptionView)
            choiceViews.append(choiceOptionView)
        }
        
        quizView.button.contentEdgeInsets = .init(top: 8, left: 20, bottom: 9, right: 20)
        quizView.button.backgroundColor = UIColor(red: 0.8, green: 0.13, blue: 0.8, alpha: 1)
        quizView.button.layer.cornerRadius = 2
        quizView.button.setTitle("SUBMIT", for: .normal)
        quizView.button.titleLabel?.font = UIFont(name: "TNTDigital-Bold", size: 14)
        quizView.button.addTarget(self, action: #selector(submitAnswerSelected), for: .touchUpInside)
        
        self.view = self.quizView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        model.registerImpression()
        
        if model.isQuizExpired {
            self.quizDidExpire()
        }
        
        if model.isAnswerSubmitted {
            self.answerSubmitted()
        }
        
    }
    
    @objc private func submitAnswerSelected() {
        model.submitAnswer()
    }

}

extension LLTextQuizWidgetViewController: LLQuizViewModelListener {
    func selectedChoiceDidChange(choiceID: String?) {
        if let choiceID = choiceID {
            self.choiceViews.forEach { choiceView in
                if choiceView.id == choiceID {
                    choiceView.backgroundColor = UIColor(red: 0.36, green: 0.4, blue: 0.42, alpha: 1)
                } else {
                    choiceView.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.92, alpha: 1)
                }
            }
        }
    }
    
    func answerSubmitted() {
        DispatchQueue.main.async {
            self.quizView.isUserInteractionEnabled = false
            self.quizView.button.alpha = 0.5
            self.choiceViews.forEach { choiceView in
                guard let choice = self.model.choices.first(where: { $0.id == choiceView.id }) else { return }
                choiceView.progressView.isHidden = false
                choiceView.percentageLabel.isHidden = false
                
                let votePercentage = self.model.getVotePercentage(choiceID: choice.id)
                choiceView.progressViewWidthConstraint.constant = CGFloat(votePercentage) * choiceView.textLabel.bounds.width
                choiceView.percentageLabel.text = "\(Int(round(votePercentage * 100)))%"
                
                if choice.id == self.model.selectedChoiceID {
                    choiceView.backgroundColor = UIColor(red: 0.82, green: 0.83, blue: 0.84, alpha: 1)
                }
                
                if choice.isCorrect {
                    let correctGreen = UIColor(red: 0, green: 0.52, blue: 0.5, alpha: 1)
                    choiceView.progressView.backgroundColor = correctGreen
                    choiceView.layer.borderColor = correctGreen.cgColor
                    choiceView.layer.borderWidth = 1
                    choiceView.textLabel.textColor = correctGreen
                    choiceView.percentageLabel.textColor = correctGreen
                } else if !choice.isCorrect {
                    let incorrectRed = UIColor(red: 0.73, green: 0.22, blue: 0.18, alpha: 1)
                    choiceView.progressView.backgroundColor = incorrectRed
                    choiceView.layer.borderColor = incorrectRed.cgColor
                    choiceView.layer.borderWidth = 1
                    choiceView.textLabel.textColor = incorrectRed
                    choiceView.percentageLabel.textColor = incorrectRed
                }
            }
        }
    }
    
    func quizDidExpire() {
        self.quizView.isUserInteractionEnabled = false
        self.quizView.button.setTitle("QUIZ EXPIRED", for: .normal)
        self.quizView.button.alpha = 0.5
        
        answerSubmitted()
    }
    
    func votePercentageDidChange(choiceID: String, votePercentage: Float) {
        DispatchQueue.main.async {
            guard let choiceView =  self.choiceViews.first(where: { $0.id == choiceID }) else { return }
            choiceView.percentageLabel.text = "\(Int(round(votePercentage * 100)))%"
            choiceView.progressViewWidthConstraint.constant = CGFloat(votePercentage) * choiceView.textLabel.bounds.width
        }
    }
}
