import UIKit

class LLTextChoiceWidgetView: UIView {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
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
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
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

        addSubview(stackView)
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(bodyView)

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        headerView.addSubview(widgetTag)
        widgetTag.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        widgetTag.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        widgetTag.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        widgetTag.heightAnchor.constraint(equalToConstant: 12).isActive = true

        headerView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: widgetTag.bottomAnchor, constant: 6).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16).isActive = true

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

class LLTextChoiceWidgetOptionView: UIView {
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var buttonCompletion: (LLTextChoiceWidgetOptionView) -> Void = { _ in }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()

    let percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    var progressViewWidthConstraint: NSLayoutConstraint!

    let progressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let id: String
    
    init(id: String) {
        self.id = id

        super.init(frame: .zero)
        layer.cornerRadius = 4
        clipsToBounds = true

        addSubview(imageView)
        
        let progressContainer = UIView()
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(progressView)
        
        let textAndProgressStack = UIStackView(arrangedSubviews: [
            textLabel,
            progressContainer
        ])
        textAndProgressStack.translatesAutoresizingMaskIntoConstraints = false
        textAndProgressStack.axis = .vertical
        textAndProgressStack.spacing = 8
        
        addSubview(textAndProgressStack)
        addSubview(percentageLabel)
        addSubview(button)
        
        progressView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true

        
        textAndProgressStack.topAnchor.constraint(equalTo: topAnchor, constant: 9).isActive = true
        textAndProgressStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        textAndProgressStack.trailingAnchor.constraint(equalTo: percentageLabel.leadingAnchor, constant: -12).isActive = true
        textAndProgressStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9).isActive = true

        percentageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        percentageLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        percentageLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        percentageLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        NSLayoutConstraint.activate([
            self.button.topAnchor.constraint(equalTo: topAnchor),
            self.button.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.button.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        progressViewWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        progressViewWidthConstraint.isActive = true
        
        button.addTarget(self, action: #selector(choiceSelected), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func choiceSelected() {
        self.buttonCompletion(self)
    }
}
