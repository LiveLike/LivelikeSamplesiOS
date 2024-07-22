import UIKit

class LLCommentaryCardReactionViewController: UIViewController {
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ReactionButton"), for: .normal)
        return button
    }()
    
    var reactionDisplayVC: LLReactionDisplayViewController = {
        let vc = LLReactionDisplayViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.isHidden = true
        return vc
    }()
    var reactionBarVC: LLReactionBarViewController = {
        let vc = LLReactionBarViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.alpha = 0
        return vc
    }()
    
    var reactionSetViewModel: LLReactionSetViewModel? {
        didSet {
            reactionBarVC.reactionSetViewModel = reactionSetViewModel
            reactionDisplayVC.reactionSetViewModel = reactionSetViewModel
            
            if let reactionSetViewModel = reactionSetViewModel {
                if reactionSetViewModel.totalReactionCount > 0 {
                    reactionDisplayVC.view.isHidden = false
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(button)
        view.addSubview(reactionDisplayVC.view)
        view.addSubview(reactionBarVC.view)
        
        addChild(reactionDisplayVC)
        addChild(reactionBarVC)
        
        reactionDisplayVC.didMove(toParent: self)
        reactionBarVC.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            reactionBarVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            reactionBarVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reactionBarVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            reactionBarVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(equalToConstant: 40),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            reactionDisplayVC.view.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 12),
            reactionDisplayVC.view.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            reactionDisplayVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
        ])
        
        button.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
    }
    
    @objc func buttonSelected() {
        UIView.animate(withDuration: 0.1, animations: {
            self.reactionBarVC.view.alpha = 1
        })
    }
    
}
