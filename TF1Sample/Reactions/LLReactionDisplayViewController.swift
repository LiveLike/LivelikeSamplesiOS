import UIKit
import LiveLikeSwift

class LLReactionDisplayViewController: UIViewController {
    
    var reactionSetViewModel: LLReactionSetViewModel? {
        didSet {
            reactionCountDisplayView.reset() 
            reactionSetViewModel?.listeners.addListener(self)
            
            reactionCountDisplayView.countLabel.text = reactionSetViewModel?.totalReactionCount.roundedWithAbbreviations
            reactionSetViewModel?.reactions.forEach {
                if $0.count > 0 {
                    reactionCountDisplayView.showReactionIcon(
                        reactionID: $0.reactionID,
                        imageURL: $0.imageUrl
                    )
                }
            }
        }
    }
    
    let reactionCountDisplayView: LLReactionCountDisplayView = {
        let view = LLReactionCountDisplayView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(reactionCountDisplayView)
        NSLayoutConstraint.activate([
            reactionCountDisplayView.topAnchor.constraint(equalTo: view.topAnchor),
            reactionCountDisplayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reactionCountDisplayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reactionCountDisplayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
}

extension LLReactionDisplayViewController: LLReactionSetViewModelListener {
    func totalReactionCountDidChange(count: Int) {
        DispatchQueue.main.async {
            self.reactionCountDisplayView.countLabel.text = count.roundedWithAbbreviations
        }
        
    }
    
    func reactionAdded(reactionID: String, imageURL: URL, oldCount: Int, newCount: Int) {
        if oldCount == 0 {
            reactionCountDisplayView.showReactionIcon(
                reactionID: reactionID,
                imageURL: imageURL
            )
        }
    }
    
    func reactionRemoved(reactionID: String, newCount: Int) {
        if newCount == 0 {
            reactionCountDisplayView.hideReactionIcon(
                reactionID: reactionID
            )
        }
    }
    

}
