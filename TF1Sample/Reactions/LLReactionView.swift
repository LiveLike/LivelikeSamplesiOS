import UIKit
import LiveLikeCore
import LiveLikeSwift

class LLReactionView: UIView {
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
        reactionCount.font = UIFont(name: "TNTDigital-Medium", size: 10)
        reactionCount.textAlignment = .center
        reactionCount.adjustsFontSizeToFitWidth = true
        return reactionCount
    }()

    private let mediaRepository: MediaRepository = MediaRepository.shared
    
    public var isMine: Bool {
        didSet {
            if isMine {
                layer.borderColor = UIColor(red: 0.8, green: 0.13, blue: 0.8, alpha: 1).cgColor
                backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.92, alpha: 1)
            } else {
                layer.borderColor = UIColor.white.cgColor
                backgroundColor = .white
            }
        }
    }
    
    var reactionViewModel: LLReactionViewModel

    public init(reactionViewModel: LLReactionViewModel) {
        self.reactionViewModel = reactionViewModel
        self.isMine = reactionViewModel.isSelected
        super.init(frame: .zero)
        reactionViewModel.listeners.addListener(self)
        reactionCountLabel.text = reactionViewModel.count.roundedWithAbbreviations
        self.isAccessibilityElement = true
        self.accessibilityTraits = .button
        setUpViews()

        mediaRepository.getImage(url: reactionViewModel.imageUrl) { [weak self] in
            switch $0 {
            case .success(let result):
                self?.reactionIcon.image = result.image
            case .failure(let error):
                log.error(error)
            }
        }
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        
        if isMine {
            layer.borderColor = UIColor(red: 0.8, green: 0.13, blue: 0.8, alpha: 1).cgColor
            backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.92, alpha: 1)
        } else {
            layer.borderColor = UIColor.white.cgColor
            backgroundColor = .white
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LLReactionView: LLReactionViewModelListener {
    func isSelectedDidChange(isSelected: Bool) {
        DispatchQueue.main.async {
            self.isMine = isSelected
        }
    }
    
    func countDidChange(count: Int) {
        DispatchQueue.main.async {
            self.setCount(count)
        }
    }
}

// MARK: - Public
extension LLReactionView {

    public func setCount(_ count: Int) {
        guard count > 0 else {
            reactionCountLabel.text = nil
            return
        }
        reactionCountLabel.text = count.roundedWithAbbreviations
    }

}

// MARK: - Private
private extension LLReactionView {
    func setUpViews() {
        let vStack = UIStackView(arrangedSubviews: [
            reactionIcon,
            reactionCountLabel
        ])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        
        addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            reactionIcon.widthAnchor.constraint(equalToConstant: 26.0),
            reactionIcon.heightAnchor.constraint(equalToConstant: 26.0),
            
            reactionCountLabel.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
}

extension MediaRepository.GetImageResult {
    var image: UIImage {
        return UIImage(data: self.imageData) ?? UIImage()
    }
}

extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)k"
        }
        else {
            return "\(self)"
        }
    }
}
