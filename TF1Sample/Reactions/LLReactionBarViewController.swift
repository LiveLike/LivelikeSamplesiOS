import UIKit
import LiveLikeCore
import LiveLikeSwift

class LLReactionBarViewController: UIViewController {
    
    // Properties
    var reactionSession: ReactionSession?
    var reactionViews: [LLReactionView] = []
    
    var reactionSetViewModel: LLReactionSetViewModel? {
        didSet {
            // reset
            reactionViews.forEach { $0.removeFromSuperview() }
            reactionViews.removeAll()
            
            // setup
            setupReactions()
        }
    }
    
    // UI Elements
    private let stackView = UIStackView()
    private let mediaRepository: MediaRepository = MediaRepository.shared
    
    private let reactionsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reactionsHolder: UIStackView = {
        let stackView: UIStackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 4.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        
        reactionsContainer.layer.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1).cgColor
        reactionsContainer.layer.cornerRadius = 6
        reactionsContainer.layer.borderWidth = 1
        reactionsContainer.layer.borderColor = UIColor(red: 0.816, green: 0.827, blue: 0.835, alpha: 1).cgColor
        
        view.addSubview(reactionsContainer)
        reactionsContainer.addSubview(reactionsHolder)
        
        NSLayoutConstraint.activate([
            reactionsHolder.leadingAnchor.constraint(equalTo: reactionsContainer.leadingAnchor, constant: 6),
            reactionsHolder.topAnchor.constraint(equalTo: reactionsContainer.topAnchor, constant: 6),
            reactionsHolder.bottomAnchor.constraint(equalTo: reactionsContainer.bottomAnchor, constant: -6),
            reactionsHolder.trailingAnchor.constraint(equalTo: reactionsContainer.trailingAnchor, constant: -6),
            
            reactionsContainer.topAnchor.constraint(equalTo: view.topAnchor),
            reactionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reactionsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reactionsContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
    }

    @objc private func reactionButtonTapped(_ sender: UITapGestureRecognizer!) {
        if let reactionView = sender.view as? LLReactionView {
            UIAccessibility.post(notification: .layoutChanged, argument: reactionView)
            
            if reactionView.reactionViewModel.isSelected {
                reactionView.reactionViewModel.removeReaction()
            } else {
                reactionView.reactionViewModel.addReaction()
            }
        }
    }
    
    private func setupReactions() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let reactionSetViewModel = self.reactionSetViewModel else { return }
            reactionSetViewModel.reactions.enumerated().forEach { index, reaction in
                let reactionView = LLReactionView(
                    reactionViewModel: reaction
                )
                
                reactionView.isUserInteractionEnabled = true
                reactionView.tag = index
                reactionView.translatesAutoresizingMaskIntoConstraints = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.reactionButtonTapped(_:)))
                reactionView.addGestureRecognizer(tap)
                NSLayoutConstraint.activate([
                    reactionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 34.0)
                ])
                
                self.reactionsHolder.insertArrangedSubview(reactionView, at: 0)
                self.reactionViews.append(reactionView)
            }
        }
    }
}
