//
//  ViewController.swift
//  TF1Sample
//
//  Created by Changdeo Jadhav on 10/07/23.
//

import UIKit
import EngagementSDK

class ViewController: UIViewController {

    private let  interactiveTimelineWidgetViewDelegate = InteractiveTimelineWidgetViewDelegate()
    private var sdk: EngagementSDK!
    private let widgetTimeline: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let widgetView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(widgetTimeline)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            widgetTimeline.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            widgetTimeline.topAnchor.constraint(equalTo: safeArea.topAnchor),
            widgetTimeline.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            widgetTimeline.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        self.widgetTimeline.addSubview(widgetView)
        NSLayoutConstraint.activate([
            widgetView.leadingAnchor.constraint(equalTo: widgetTimeline.leadingAnchor),
            widgetView.topAnchor.constraint(equalTo: widgetTimeline.topAnchor),
            widgetView.trailingAnchor.constraint(equalTo: widgetTimeline.trailingAnchor),
            widgetView.bottomAnchor.constraint(equalTo: widgetTimeline.bottomAnchor),
            widgetView.widthAnchor.constraint(equalTo: widgetTimeline.widthAnchor)
        ])
        
        // Do any additional setup after loading the view.
        sdk = EngagementSDK(config: EngagementSDKConfig(clientID: "8PqSNDgIVHnXuJuGte1HdvOjOqhCFE1ZCR3qhqaS"))
    
        let reactionBarViewController = ReactionViewController(sdk: sdk, targetGroupID: "135f341f-9daf-461c-8c02-239f76aaf85f", targetID: "yourTargetID")
        
        self.addChild(reactionBarViewController)
        reactionBarViewController.didMove(toParent: self)
        reactionBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.widgetView.addArrangedSubview(reactionBarViewController.view)

        loadWidgetModelToShowStockWidget(id: "1e2a0fd9-ab97-4712-8fe2-8172bfeed3d8",kind: WidgetKind.imageQuiz)
//        loadWidgetModelToShowCustomWidget(id: "b046a70b-460c-4a2a-a26b-9985461916c7",kind: WidgetKind.imageSlider)
//        loadWidgetModelToShowCustomWidget(id: "39217a2d-2f1b-41c3-914b-95fa8a64594c",kind: WidgetKind.cheerMeter)
        let quizVC = LLTextQuizWidgetViewController(
            model: FakeQuizViewModel(
                tag: "QUIZ",
                question: "Who will score more goals in Euro 2024",
                choices: [
                    LLQuizOptionViewModel(
                        id: "test-1",
                        isCorrect: true,
                        text: "Kane"
                    ),
                    LLQuizOptionViewModel(
                        id: "test-2",
                        isCorrect: false,
                        text: "Foden"
                    )
                ],
                canSubmitAnswer: true,
                isQuizExpired: false,
                userDidAnswer: false
            )
        )
        self.presentWidget(widgetViewController: quizVC)
    
        
        
        
//        loadWidgetModelToShowStockWidget(id: "2d7f63cb-0ff0-4f0a-b3cf-81760d48be33",kind: WidgetKind.textPoll)
//        loadWidgetModelToShowStockWidget(id: "b046a70b-460c-4a2a-a26b-9985461916c7",kind: WidgetKind.imageSlider)
//        loadWidgetModelToShowCustomWidget(id: "151359d2-de10-4e14-aae1-85edc32f50bc",kind: WidgetKind.textAsk)
//        loadWidgetModelToShowStockWidget(id: "151359d2-de10-4e14-aae1-85edc32f50bc",kind: WidgetKind.textAsk)
    }

//    func loadWidgetModelToShowCustomWidget(id:String, kind:WidgetKind){
//        self.sdk?.getWidgetModel(id: id, kind: kind){ [self] result in
//            handleResult(result: result)
//        }
//        
//    }
    
    func loadWidgetModelToShowStockWidget(id:String, kind:WidgetKind){
        self.sdk?.getWidgetModel(id: id, kind: kind){ [self] result in
            switch result {
            case .success(let model):
                switch model {
                case .quiz(let quiz):
                    quiz.loadInteractionHistory { _ in
                        
                        let quizVC = LLTextQuizWidgetViewController(model: LLQuizWidgetViewModelImpl(model: quiz))
                        self.presentWidget(widgetViewController: quizVC)
                    }
                default:
                    break
                }
                
            case let .failure(error):
                print("\(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let alert = UIAlertController(
                        title: "Error",
                        message: "\(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func presentWidget(widgetViewController: LLTextQuizWidgetViewController){
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                let viewController = widgetViewController
                self.addChild(viewController)
                viewController.didMove(toParent: self)
                viewController.view.translatesAutoresizingMaskIntoConstraints = false
                self.widgetView.addArrangedSubview(viewController.view)
            }
            
        }
    }
    
//    func handleResult(result: Result<WidgetModel, Error>){
//        switch result {
//        case .failure(let error):
//            print(error)
//        case .success(let widgetModel):
//            switch widgetModel {
//            case let .cheerMeter(model):
//                model.loadInteractionHistory { result in
//                    switch result {
//                    case .failure(let error):
//                        print("\(error)")
//                    case .success(let interations):
//                        self.presentWidget(widgetViewController: DefaultWidgetFactory.makeWidget(from: widgetModel)!)
//                    }
//                }
//                break;
//            case .alert(_):
//                break
//            case .quiz(let quiz):
//                quiz.loadInteractionHistory { result in
//                    switch result {
//                    case .failure(let error):
//                        print("\(error)")
//                    case .success(let interations):
//                        self.presentWidget(widgetViewController: DefaultWidgetFactory.makeWidget(from: widgetModel)!)
//                    }
//                }
//                break
//            case .prediction(_):
//                break
//            case .predictionFollowUp(_):
//                break
//            case let .poll(model):
//                model.loadInteractionHistory { result in
//                    switch result {
//                    case .failure(let error):
//                        print("\(error)")
//                    case .success(let interations):
//                        self.presentWidget(widgetViewController: DefaultWidgetFactory.makeWidget(from: widgetModel)!)
//                    }
//                }
//                break
//            case let .imageSlider(model):
//                model.loadInteractionHistory { result in
//                    switch result {
//                    case .failure(let error):
//                        print("\(error)")
//                    case .success(let interations):
//                        self.presentWidget(widgetViewController: DefaultWidgetFactory.makeWidget(from: widgetModel)!)
//                    }
//                }
//                break
//            case .socialEmbed(_):
//                break
//            case .videoAlert(_):
//                break
//            case let .textAsk(model):
//                model.loadInteractionHistory { result in
//                    switch result {
//                    case .failure(let error):
//                        print("\(error)")
//                    case .success(let interations):
//                        self.presentWidget(widgetViewController: CustomTextAskWidgetViewController(model: model))
//                    }
//                }
//                
//                break
//            case .numberPrediction(_):
//                break
//            case .numberPredictionFollowUp(_):
//                break
//                
//            case .richPost(_):
//                break
//            }
//        }
//    }
    
}



