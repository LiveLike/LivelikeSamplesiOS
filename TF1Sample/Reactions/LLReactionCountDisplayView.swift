import UIKit
import LiveLikeCore

class LLReactionCountDisplayView: UIView {

    var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "TNTDigital-Medium", size: 12)
        return label
    }()
    
    var imageViews: [String: UIImageView] = [:]
    
    var hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        
        let spacingView = UIView(frame: .zero)
        hStack.addArrangedSubview(spacingView)
        hStack.addArrangedSubview(countLabel)
        addSubview(hStack)
        
        hStack.setCustomSpacing(8, after: spacingView)
        
        NSLayoutConstraint.activate([
            
            spacingView.widthAnchor.constraint(equalToConstant: 0),
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        imageViews.values.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
    }
    
    func showReactionIcon(reactionID: String, imageURL: URL) {
        if let imageView = imageViews[reactionID] {
            imageView.isHidden = true
        } else {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            MediaRepository.shared.getImage(
                url: imageURL
            ) { result in
                switch result {
                case .failure:
                    break
                case .success(let imageResult):
                    imageView.image = imageResult.image
                }
            }
            imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            self.imageViews[reactionID] = imageView
            self.hStack.insertArrangedSubview(imageView, at: 0)
        }
    }
    
    func hideReactionIcon(reactionID: String) {
        if let imageView = imageViews[reactionID] {
            imageView.isHidden = true
        }
    }
    
    
}


