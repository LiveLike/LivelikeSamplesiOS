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
        sdk = EngagementSDK(config: EngagementSDKConfig(clientID: "mOBYul18quffrBDuq2IACKtVuLbUzXIPye5S3bq5"))
        loadWidgetModelToShowCustomWidget()
        loadWidgetModelToShowStockWidget()
    }

    func loadWidgetModelToShowCustomWidget(){
        self.sdk?.getWidgetModel(id: "a93edd55-44d0-4c17-a309-2281f4e0ac74", kind: WidgetKind.textPoll){ [self] result in
            handleResult(result: result)
        }
        
    }
    
    func loadWidgetModelToShowStockWidget(){
        self.sdk?.getWidget(id: "a93edd55-44d0-4c17-a309-2281f4e0ac74", kind: WidgetKind.textPoll){ [self] result in
            switch result {
                case let .success(widget):
                self.presentWidget(widgetViewController: widget)
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
    
    func presentWidget(widgetViewController: Widget){
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                let viewController = widgetViewController
                self.addChild(viewController)
                viewController.didMove(toParent: self)
                viewController.view.translatesAutoresizingMaskIntoConstraints = false
                self.widgetView.addArrangedSubview(viewController.view)
                viewController.delegate = self.interactiveTimelineWidgetViewDelegate
                viewController.moveToNextState()
            }
            
        }
    }
    
    func handleResult(result: Result<WidgetModel, Error>){
        switch result {
        case .failure(let error):
            print(error)
        case .success(let widgetModel):
            switch widgetModel {
            case let .cheerMeter(model):
                break;
            case .alert(_):
                break
            case .quiz(_):
                break
            case .prediction(_):
                break
            case .predictionFollowUp(_):
                break
            case let .poll(model):
                model.loadInteractionHistory { result in
                    switch result {
                    case .failure(let error):
                        print("\(error)")
                    case .success(let interations):
                        self.presentWidget(widgetViewController: CustomTextPollWidgetViewController(model: model))
                    }
                }
                break
            case .imageSlider(_):
                break
            case .socialEmbed(_):
                break
            case .videoAlert(_):
                break
            case .textAsk(_):
                break
            case .numberPrediction(_):
                break
            case .numberPredictionFollowUp(_):
                break
                
            }
        }
    }
    
}



