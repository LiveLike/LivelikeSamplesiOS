//
//  File.swift
//  TF1Sample
//
//  Created by Work on 7/12/24.
//

import UIKit

class TextQuizWidgetView: UIView {

    var choiceView: LLTextChoiceWidgetView = LLTextChoiceWidgetView()
    var button: UIButton = UIButton()
    
    init() {
        super.init(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        buttonContainer.addSubview(button)
        
        let vStack = UIStackView(arrangedSubviews: [
            choiceView,
            buttonContainer
        ])
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(vStack)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            button.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 33),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
