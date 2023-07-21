//
//  TextAskWidgetView.swift
//  EngagementSDK
//
//

import UIKit
import EngagementSDK

class CustomTextAskView: UIView {
    
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    var titleView: WidgetTitleView = {
        let view = WidgetTitleView()
//        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var body: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bodyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    var footer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    var confirmationLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.text = " "
        return label
    }()
    
    let submitReplyThemeableView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var submitReplyButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    let userReplyThemableView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let userReplyTextView: UITextView = {
        let inputView = UITextView()
        inputView.backgroundColor = .white
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        inputView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        inputView.typingAttributes[.paragraphStyle] = style
        return inputView
    }()
    
    let submitButtonAndConfirmationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        addSubviews()
        applyLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(body)
        stackView.addArrangedSubview(footer)
        addSubview(userReplyThemableView)
        addSubview(bodyStackView)
        bodyStackView.addArrangedSubview(promptLabel)
        bodyStackView.addArrangedSubview(userReplyTextView)
        bodyStackView.addArrangedSubview(submitButtonAndConfirmationContainer)
        addSubview(confirmationLabel)
        addSubview(submitReplyThemeableView)
        addSubview(submitReplyButton)
        addSubview(characterCountLabel)
    }
    
    func applyLayoutConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bodyStackView.topAnchor.constraint(equalTo: body.topAnchor, constant: 16),
            bodyStackView.leadingAnchor.constraint(equalTo: body.leadingAnchor, constant: 16),
            bodyStackView.trailingAnchor.constraint(equalTo: body.trailingAnchor, constant: -16),
            bodyStackView.bottomAnchor.constraint(equalTo: body.bottomAnchor, constant: -16),
            
            userReplyTextView.heightAnchor.constraint(equalToConstant: 72),
            
            userReplyThemableView.topAnchor.constraint(equalTo: userReplyTextView.topAnchor),
            userReplyThemableView.leadingAnchor.constraint(equalTo: userReplyTextView.leadingAnchor),
            userReplyThemableView.trailingAnchor.constraint(equalTo: userReplyTextView.trailingAnchor),
            userReplyThemableView.bottomAnchor.constraint(equalTo: userReplyTextView.bottomAnchor),
            
            submitReplyButton.topAnchor.constraint(equalTo: submitButtonAndConfirmationContainer.topAnchor),
            submitReplyButton.leadingAnchor.constraint(equalTo: submitButtonAndConfirmationContainer.leadingAnchor),
            submitReplyButton.bottomAnchor.constraint(equalTo: submitButtonAndConfirmationContainer.bottomAnchor),
            submitReplyButton.widthAnchor.constraint(equalToConstant: 62),
            
            confirmationLabel.topAnchor.constraint(equalTo: submitButtonAndConfirmationContainer.topAnchor),
            confirmationLabel.leadingAnchor.constraint(equalTo: submitReplyButton.trailingAnchor, constant: 8),
            confirmationLabel.trailingAnchor.constraint(equalTo: submitButtonAndConfirmationContainer.trailingAnchor),
            confirmationLabel.bottomAnchor.constraint(equalTo: submitButtonAndConfirmationContainer.bottomAnchor),
            
            submitButtonAndConfirmationContainer.heightAnchor.constraint(equalToConstant: 40),
            
            submitReplyThemeableView.topAnchor.constraint(equalTo: submitReplyButton.topAnchor),
            submitReplyThemeableView.leadingAnchor.constraint(equalTo: submitReplyButton.leadingAnchor),
            submitReplyThemeableView.trailingAnchor.constraint(equalTo: submitReplyButton.trailingAnchor),
            submitReplyThemeableView.bottomAnchor.constraint(equalTo: submitReplyButton.bottomAnchor),
            
            characterCountLabel.bottomAnchor.constraint(equalTo: userReplyTextView.bottomAnchor, constant: -4),
            characterCountLabel.trailingAnchor.constraint(equalTo: userReplyTextView.trailingAnchor, constant: -4),
            characterCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
    }
}
