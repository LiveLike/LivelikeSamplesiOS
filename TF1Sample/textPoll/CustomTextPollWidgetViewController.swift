//
//  CustomTextPollWidgetViewController.swift
//  VerizonLivelike
//
//  Created by Changdeo Jadhav on 03/04/23.
//

import LiveLikeSwift
import UIKit
import EngagementSDK

class CustomTextPollWidgetViewController: Widget {
    private let model: PollWidgetModel
    private let viewModel: PollWidgetViewModel

    private var optionViews: [CustomTextChoiceWidgetOptionView] = []

    var choiceView: CustomTextChoiceWidgetView {
        if let view = view as? CustomTextChoiceWidgetView {
            return view
        }
        return CustomTextChoiceWidgetView()
    }

    private var selectedOptionIndex: Int?

    override init(model: PollWidgetModel) {
        self.model = model
        self.viewModel = PollWidgetViewModel(model: model)
        super.init(model: model)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let choiceView = CustomTextChoiceWidgetView()

        choiceView.widgetTag.text = "TEXT POLL"
        choiceView.titleLabel.text = model.question
        model.options.enumerated().forEach { index, option in
            let choiceOptionView = CustomTextChoiceWidgetOptionView(id: option.id, showBiggerOption: (model.options.count == 2))
            choiceOptionView.textLabel.text = option.text
            choiceOptionView.tag = index
            choiceOptionView.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            choiceView.optionsStackView.addArrangedSubview(choiceOptionView)
            optionViews.append(choiceOptionView)
        }
        view = choiceView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        model.delegate = self
        
        if model.mostRecentVote != nil {
            DispatchQueue.main.async {
                self.showResultsFromWidgetOptions()
            }
        }
        self.model.registerImpression()
    }
    
    private func showResultsFromWidgetOptions() {
        let viewDataPairs = zip(self.optionViews, self.model.options)
            .filter { view, data in view.id == data.id }

        for (view, data) in viewDataPairs {
            if let vote = model.mostRecentVote, data.id == vote.optionID {
                // view.optionThemeStyle = .selected
                // self.applyOptionTheme(optionView: view, optionTheme: nil)
            } else {
                // view.optionThemeStyle = .unselected
                // self.applyOptionTheme(optionView: view, optionTheme: nil)
            }

            view.layer.backgroundColor =  UIColor(red: 0.106, green: 0.114, blue: 0.122, alpha: 1).cgColor
            let voteCount = viewModel.getVoteCount(optionID: data.id)
            let votePercentage = self.viewModel.getVoteCountTotal() > 0
                ? CGFloat(voteCount) / CGFloat(self.viewModel.getVoteCountTotal())
                : 0
            
            view.layer.borderColor = UIColor.clear.cgColor
            view.percentageLabel.text = "\(Int(votePercentage * 100))%"
            view.progressViewWidthConstraint.constant = votePercentage * view.bounds.width
            view.percentageLabel.isHidden = false
        }
    }
    

    @objc private func optionSelected(_ button: UIButton) {
        
        if selectedOptionIndex == nil {
            optionViews.forEach {
                $0.layer.borderColor = UIColor.clear.cgColor
                $0.layer.backgroundColor = UIColor(red: 0.106, green: 0.114, blue: 0.122, alpha: 1).cgColor
            }
        }
        if let previousSelectedIndex = selectedOptionIndex {
            let previousSelectedChoiceView = optionViews[previousSelectedIndex]
            //previousSelectedChoiceView.backgroundColor = .white
            previousSelectedChoiceView.percentageLabel.textColor = .white
            previousSelectedChoiceView.textLabel.textColor = .white
            previousSelectedChoiceView.layer.borderColor = UIColor.white.cgColor
            previousSelectedChoiceView.progressView.backgroundColor = .red
        } else {
            // on first selection, reveal percentage label and progress view
            optionViews.forEach {
                $0.layer.borderColor = UIColor.white.cgColor
            }
        }

        guard let choiceView = button as? CustomTextChoiceWidgetOptionView else { return }
        //choiceView.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        choiceView.textLabel.textColor = .white
        choiceView.percentageLabel.textColor = .white
        //choiceView.backgroundColor = .black
        choiceView.layer.borderColor = UIColor.clear.cgColor
        choiceView.progressView.backgroundColor = .red

        selectedOptionIndex = button.tag

        let optionID = model.options[button.tag].id
        model.submitVote(optionID: optionID)
    }
}

extension CustomTextPollWidgetViewController: PollWidgetModelDelegate {
    func pollWidgetModel(_ model: PollWidgetModel, voteCountDidChange voteCount: Int, forOption optionID: String) {
        DispatchQueue.main.async {
            guard let optionIndex = model.options.firstIndex(where: { $0.id == optionID }) else { return }
            guard model.totalVoteCount > 0 else { return }
            let votePercentage = (CGFloat(voteCount) / CGFloat(model.totalVoteCount))
            self.optionViews[optionIndex].percentageLabel.text = "\(Int(votePercentage * 100))%"
            self.optionViews[optionIndex].progressViewWidthConstraint.constant = votePercentage * self.optionViews[optionIndex].bounds.width
        }
    }
}
