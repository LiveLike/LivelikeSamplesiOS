//
//  CustomTextChoiceWidgetView.swift
//  VerizonLivelike
//
//  Created by Changdeo Jadhav on 03/04/23.
//

import UIKit

class CustomTextChoiceWidgetView: UIView {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()

    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let widgetTag: UILabel = {
        let label = UILabel()
        label.text = "CHOICE WIDGET"
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3/1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        //label.font = UIFont(name: "VerizonNHGeDS-Bold", size: 24)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bodyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        layer.cornerRadius = 8

        addSubview(stackView)
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(bodyView)

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 21).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -21).isActive = true

        headerView.addSubview(widgetTag)
        widgetTag.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        widgetTag.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        widgetTag.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        widgetTag.heightAnchor.constraint(equalToConstant: 12).isActive = true

        headerView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: widgetTag.bottomAnchor, constant: 4).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 56).isActive = true

        bodyView.addSubview(optionsStackView)
        optionsStackView.topAnchor.constraint(equalTo: bodyView.topAnchor).isActive = true
        optionsStackView.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor).isActive = true
        optionsStackView.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor).isActive = true
        optionsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        optionsStackView.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomTextChoiceWidgetOptionView: UIButton {
    
    let id: String
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        //label.font = UIFont(name: "VerizonNHGeDS-Bold", size: 16)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return label
    }()

    let percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        //label.font = UIFont(name: "VerizonNHGeDS-Bold", size: 16)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return label
    }()

    let progressViewWidthConstraint: NSLayoutConstraint

    let progressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.933, green: 0, blue: 0, alpha: 1)
        return view
    }()

    init(id: String, showBiggerOption:Bool) {
        
        self.id = id
        progressViewWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        super.init(frame: .zero)

        if(showBiggerOption){
            self.heightAnchor.constraint(equalToConstant: 64).isActive = true
        } else {
            self.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
        
        
        layer.cornerRadius = 8
        layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        layer.borderWidth = 1
        clipsToBounds = true
        

        addSubview(textLabel)
        addSubview(percentageLabel)
        addSubview(progressView)

        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50).isActive = true
        //textLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        textLabel.layer.zPosition = 1
        
        percentageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        percentageLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        percentageLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        percentageLabel.layer.zPosition = 1
        //percentageLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        progressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        progressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        progressViewWidthConstraint.isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
