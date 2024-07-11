import UIKit
import EngagementSDK
import LiveLikeCore
import LiveLikeSwift

struct SelfUserReaction {
    let id: String
    let reactionID: String
}

class ReactionViewController: UIViewController {
    
    // Properties
    private let sdk: EngagementSDK
    var targetGroupID: String
    var targetID: String
    var reactionSession: ReactionSession?
    var reactionSpaceID: String?
    var reactionCounts: [String: Int] = [:]
    var selfUserReactions: [SelfUserReaction] = []
    var reactionViews: [ReactionView] = []
    
    var reactionSetViewModel: ReactionSetViewModel!
    
    // UI Elements
    private let stackView = UIStackView()
    private let mediaRepository: MediaRepository = MediaRepository.shared
    
    private let reactionsHolder: UIStackView = {
        let stackView: UIStackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 2.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Initializer
    init(sdk: EngagementSDK, targetGroupID: String, targetID: String) {
        self.sdk = sdk
        self.targetGroupID = targetGroupID
        self.targetID = targetID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        Task {
            do {
                self.reactionSetViewModel = try await ReactionViewModelFactory.make(
                    sdk: self.sdk,
                    targetGroupID: self.targetGroupID,
                    targetID: self.targetID
                )
                setupReactions()
            } catch {
                
            }
        }
    }
    
    private func setupView() {
        
        view.addSubview(reactionsHolder)
        
        NSLayoutConstraint.activate([
            reactionsHolder.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            reactionsHolder.topAnchor.constraint(equalTo: view.safeTopAnchor),
            reactionsHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reactionsHolder.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func reactionButtonTapped(_ sender: UITapGestureRecognizer!) {
        if let reactionView = sender.view as? ReactionView {
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
            self.reactionSetViewModel.reactions.enumerated().forEach { index, reaction in
                let reactionView = ReactionView(
                    reactionViewModel: reaction
                )
                
                reactionView.isUserInteractionEnabled = true
                reactionView.tag = index
                reactionView.translatesAutoresizingMaskIntoConstraints = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.reactionButtonTapped(_:)))
                tap.delegate = self
                reactionView.addGestureRecognizer(tap)
                NSLayoutConstraint.activate([
                    reactionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 34.0)
                ])
                
                self.reactionsHolder.addArrangedSubview(reactionView)
                self.reactionViews.append(reactionView)
            }
        }
    }
}

extension UIView {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }

    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }

    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }

    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        }
        return trailingAnchor
    }

    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        }
        return leadingAnchor
    }
}



extension ReactionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
