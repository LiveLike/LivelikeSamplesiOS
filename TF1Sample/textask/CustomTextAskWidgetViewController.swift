//
//  TextAskWidgetViewController.swift
//  EngagementSDK
//
//

import UIKit
import LiveLikeSwift
import EngagementSDK

class CustomTextAskWidgetViewController: BaseTextAskWidgetViewController {
    
    private let model: TextAskWidgetModel
    
    override var currentState: WidgetState {
        willSet {
            previousState = self.currentState
        }
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.widgetDidEnterState(widget: self, state: self.currentState)
                switch self.currentState {
                case .ready:
                    break
                case .interacting:
                    self.enterInteractingState()
                case .results:
                    self.enterResultState()
                case .finished:
                    self.enterFinishedState()
                }
            }
        }
    }
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    var closeButtonCompletion: ((WidgetViewModel) -> Void)?
    
    override init(model: TextAskWidgetModel) {
        self.model = model
        super.init(model: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.leadingAnchor.constraint(equalTo: widgetView.confirmationLabel.leadingAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: widgetView.confirmationLabel.centerYAnchor)
        ])
        
//        widgetView.titleView.closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        widgetView.titleView.titleLabel.text = model.title
        widgetView.promptLabel.text = model.prompt
        if let userReply = model.mostRecentReply {
            widgetView.userReplyTextView.text = userReply.text
            self.disableInteractions()
            widgetView.confirmationLabel.text = model.confirmationMessage
            widgetView.characterCountLabel.isHidden = true
        }
        
        if model.isInteractivityExpired() {
            self.disableInteractions()
        }

//        self.beginInteractiveUntilTimer { [weak self] in
//            guard let self = self else { return }
//            self.disableInteractions()
//        }
        
        model.registerImpression { _ in }
    }
    
    override func submitReplyButtonSelected(_ sender: UIButton) {
        guard let reply = widgetView.userReplyTextView.text else { return }
        
        activityIndicator.startAnimating()
        self.disableInteractions()
//        self.widgetView.userReplyTextView.theme(askTheme.replyTextDisabled)
        
        self.model.submitReply(reply) { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            switch result {
            case .success:
                self.widgetView.confirmationLabel.text = self.model.confirmationMessage
                self.widgetView.characterCountLabel.isHidden = true
            case .failure:
                self.setSubmitButtonIsEnabled(true)
                self.widgetView.userReplyTextView.isEditable = true
//                self.widgetView.userReplyThemableView.applyContainerProperties(self.askTheme.replyTextView)
            }
        }
    }
    
    override func moveToNextState() {
        switch self.currentState {
        case .ready:
            self.currentState = .interacting
        case .interacting:
            self.currentState = .results
        case .results:
            self.currentState = .finished
        case .finished:
            break
        }
    }
    
    override func addCloseButton(_ completion: @escaping (WidgetViewModel) -> Void) {
        self.closeButtonCompletion = completion
//        widgetView.titleView.showCloseButton()
    }
    
    override func addTimer(seconds: TimeInterval, completion: @escaping (WidgetViewModel) -> Void) {
        self.widgetView.titleView.beginTimer(
            duration: seconds,
            animationFilepath: theme.lottieFilepaths.timer
        ) { [weak self] in
            guard let self = self else { return }
            completion(self)
        }
    }
    
    private func enterInteractingState() {
        self.delegate?.widgetStateCanComplete(widget: self, state: .interacting)
    }
    
    private func enterResultState() {
        self.delegate?.widgetStateCanComplete(widget: self, state: .results)
    }

    private func enterFinishedState() {
        self.delegate?.widgetStateCanComplete(widget: self, state: .finished)
    }
    
    @objc private func closeButtonPressed() {
        self.closeButtonCompletion?(self)
    }
    
    private func disableInteractions() {
        self.widgetView.userReplyTextView.isEditable = false
        self.setSubmitButtonIsEnabled(false)
    }
}
