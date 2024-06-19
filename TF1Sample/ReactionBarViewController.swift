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
    
    // UI Elements
    private let stackView = UIStackView()
    private let mediaRepository: MediaRepository = MediaRepository.shared
    
    private let reactionsHolder: UIStackView = {
        let stackView: UIStackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0.0
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
        fetchReactionSpaces()
    }
    
    private func setupView() {
        
        view.addSubview(reactionsHolder)
        
        NSLayoutConstraint.activate([
            reactionsHolder.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            reactionsHolder.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            reactionsHolder.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func fetchReactionSpaces() {
        self.sdk.reaction.getReactionSpaces(reactionSpaceID: nil, targetGroupID: self.targetGroupID, page: .first) { result in
            switch result {
            case .success(let reactionSpaces):
                guard let reactionSpace = reactionSpaces.first else { return }
                self.reactionSession = self.sdk.reaction.createReactionSession(reactionSpace: reactionSpace)
                self.reactionSession?.sessionDelegate = self
                self.reactionSpaceID = reactionSpace.id
                self.fetchReactionPacks(reactionPackIDs: reactionSpace.reactionPackIDs)
                self.fetchUserReactions()
            case .failure(let error):
                self.fetchReactionSpaces()
                print("Error fetching reaction spaces: \(error)")
            }
        }
    }
    
    private func fetchReactionPacks(reactionPackIDs: [String]) {
        for packID in reactionPackIDs {
            self.sdk.reaction.getReactionPackInfo(reactionPackID: packID) { result in
                switch result {
                case .success(let reactionPack):
                    self.setupReactions(reactionPack: reactionPack)
                case .failure(let error):
                    print("Error fetching reaction pack info: \(error)")
                }
            }
        }
    }
    
    @objc private func reactionButtonTapped(_ sender: UITapGestureRecognizer!) {
        if let reactionView = sender.view as? ReactionView {
            UIAccessibility.post(notification: .layoutChanged, argument: reactionView)
            
            if let selfUserReactionIndex = self.selfUserReactions.firstIndex(where: { $0.reactionID == reactionView.reactionID }) {
                let selfUserReaction = self.selfUserReactions[selfUserReactionIndex]
                reactionSession?.removeUserReaction(userReactionID: selfUserReaction.id) { result in
                    switch result {
                    case .success(let userReaction):
                        self.selfUserReactions.remove(at: selfUserReactionIndex)
                        reactionView.isMine = false
                        print("Removed user reaction: \(userReaction)")
                    case .failure(let error):
                        print("Error removing user reaction: \(error)")
                    }
                }
            } else {
                reactionSession?.addUserReaction(targetID: self.targetID, reactionID: reactionView.reactionID, customData: nil) { result in
                    switch result {
                    case .success(let userReaction):
                        self.selfUserReactions.append(SelfUserReaction(id: userReaction.id, reactionID: userReaction.reactionID))
                        reactionView.isMine = true
                        print("Added user reaction: \(userReaction)")
                    case .failure(let error):
                        print("Error adding user reaction: \(error)")
                    }
                }
            }
        }
    }
    
    private func setupReactions(reactionPack: ReactionPack) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            reactionPack.emojis.enumerated().forEach { index, reaction in
                let reactionView = ReactionView(
                    reactionID: reaction.id,
                    imageURL: reaction.file,
                    reactionCount: 0,
                    name: reaction.name
                )
                
                reactionView.isUserInteractionEnabled = true
                reactionView.tag = index
                reactionView.translatesAutoresizingMaskIntoConstraints = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.reactionButtonTapped(_:)))
                reactionView.addGestureRecognizer(tap)
                NSLayoutConstraint.activate([
                    reactionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 34.0)
                ])
                
                self.reactionsHolder.addArrangedSubview(reactionView)
                self.reactionViews.append(reactionView)
            }
        }
    }
    
    private func fetchUserReactions() {
        guard let spaceID = reactionSpaceID else { return }
        reactionSession?.getUserReactionsCount(reactionSpaceID: spaceID, targetID: [self.targetID], page: .first) { result in
            switch result {
            case .success(let reactionCounts):
                self.updateReactionCounts(reactionCounts: reactionCounts)
            case .failure(let error):
                self.fetchReactionSpaces()
                print("Error fetching user reactions count: \(error)")
            }
        }
    }
    
    private func updateReactionCounts(reactionCounts: [UserReactionsCountResult]) {
        if reactionCounts.count > 0 {
            for reactionCount in reactionCounts[0].reactions {
                if reactionCount.selfReactedUserReactionID != nil {
                    self.selfUserReactions.append(SelfUserReaction(id: reactionCount.selfReactedUserReactionID, reactionID: reactionCount.reactionID))
                }
                self.reactionCounts[reactionCount.reactionID] = reactionCount.count
            }
            updateUI()
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for reactionView in self.reactionViews {
                if let count = self.reactionCounts[reactionView.reactionID] {
                    reactionView.setCount(count)
                }
                reactionView.isMine = self.selfUserReactions.contains(where: { $0.reactionID == reactionView.reactionID })
            }
        }
    }
}

extension ReactionViewController: ReactionSessionDelegate {
    func reactionSession(_ reactionSession: ReactionSession, didAddReaction reaction: UserReaction) {
        if reaction.targetID == targetID {
            self.reactionCounts[reaction.reactionID, default: 0] += 1
            updateUI()
        }
    }
    
    func reactionSession(_ reactionSession: ReactionSession, didRemoveReaction reaction: UserReaction) {
        if reaction.targetID == targetID {
            if self.reactionCounts[reaction.reactionID, default: 0] > 0 {
                self.reactionCounts[reaction.reactionID, default: 0] -= 1
            }
            updateUI()
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
