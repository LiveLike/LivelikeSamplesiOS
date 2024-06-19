import Foundation
import UIKit
import LiveLikeCore
import LiveLikeSwift

open class ReactionView: UIView {
    public let reactionIcon: UIImageView = {
        let reactionIcon: UIImageView = UIImageView(frame: .zero)
        reactionIcon.translatesAutoresizingMaskIntoConstraints = false
        reactionIcon.contentMode = .scaleAspectFit
        reactionIcon.backgroundColor = .clear
        reactionIcon.isUserInteractionEnabled = false
        return reactionIcon
    }()

    private let reactionCountLabel: UILabel = {
        let reactionCount: UILabel = UILabel(frame: .zero)
        reactionCount.translatesAutoresizingMaskIntoConstraints = false
        reactionCount.textColor = .black
        reactionCount.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        return reactionCount
    }()

    private let reactionFocusView: UIView = {
        let reactionFocusView: UIView = UIView(frame: .zero)
        reactionFocusView.translatesAutoresizingMaskIntoConstraints = false
//        reactionFocusView.livelike_cornerRadius = 12.0
        reactionFocusView.alpha = 0.0
        return reactionFocusView
    }()

    public let reactionID: String

    private let name: String
    private let mediaRepository: MediaRepository = MediaRepository.shared

    public var isMine: Bool = false {
        didSet {
            if isMine {
                reactionFocusView.alpha = CGFloat(1.0)
            } else {
                reactionFocusView.alpha = CGFloat(0.0)
            }
        }
    }

    public init(reactionID: String, imageURL: URL, reactionCount: Int, name: String) {
        self.reactionID = reactionID
        self.name = name
        super.init(frame: .zero)
        reactionCountLabel.text = String(reactionCount)
        self.isAccessibilityElement = true
        self.accessibilityTraits = .button
        setUpViews()

        mediaRepository.getImage(url: imageURL) { [weak self] in
            switch $0 {
            case .success(let result):
                self?.reactionIcon.image = result.image
            case .failure(let error):
                log.error(error)
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public
extension ReactionView {

//    func setTheme(_ theme: Theme) {
//        reactionCountLabel.textColor = theme.chatReactions.panelCountsColor
//        reactionCountLabel.font = theme.messageReactionsCountFont
//        reactionFocusView.backgroundColor = theme.reactionsPopupSelectedBackground
//    }

    public func setCount(_ count: Int) {
        guard count > 0 else {
            reactionCountLabel.text = nil
            return
        }

        reactionCountLabel.text = String(count)
    }

}

// MARK: - Private
private extension ReactionView {
    func setUpViews() {
        addSubview(reactionFocusView)
        addSubview(reactionIcon)
        addSubview(reactionCountLabel)

        NSLayoutConstraint.activate([
            reactionFocusView.widthAnchor.constraint(equalToConstant: 34.0),
            reactionFocusView.heightAnchor.constraint(equalToConstant: 30.0),
            reactionFocusView.centerXAnchor.constraint(equalTo: centerXAnchor),
            reactionFocusView.centerYAnchor.constraint(equalTo: centerYAnchor),

            reactionIcon.widthAnchor.constraint(equalToConstant: 24.0),
            reactionIcon.heightAnchor.constraint(equalToConstant: 24.0),
            reactionIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            reactionIcon.centerYAnchor.constraint(equalTo: centerYAnchor),

            reactionCountLabel.topAnchor.constraint(equalTo: reactionFocusView.topAnchor),
            reactionCountLabel.trailingAnchor.constraint(equalTo: reactionFocusView.trailingAnchor)

        ])
    }
}

extension MediaRepository.GetImageResult {
    var image: UIImage {
        return UIImage(data: self.imageData) ?? UIImage()
    }
}
