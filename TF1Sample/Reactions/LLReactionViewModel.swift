import Foundation
import LiveLikeCore
import LiveLikeSwift

protocol LLReactionViewModelListener: AnyObject {
    func isSelectedDidChange(isSelected: Bool)
    func countDidChange(count: Int)
}

// Data representing a single reaction
public class LLReactionViewModel {
    
    let reactionID: String
    let targetID: String
    let imageUrl: URL
    
    @Atomic var isSelected: Bool {
        didSet {
            listeners.publish { $0.isSelectedDidChange(isSelected: isSelected) }
        }
    }
    @Atomic var count: Int {
        didSet {
            listeners.publish { $0.countDidChange(count: count) }
        }
    }
    
    var listeners: Listener<LLReactionViewModelListener> = Listener()
    
    let reactionSession: ReactionSession
    var userReactionID: String?
    
    init(
        reactionID: String,
        targetID: String,
        isSelected: Bool,
        imageUrl: URL,
        count: Int,
        reactionSession: ReactionSession,
        userReactionID: String?
    ) {
        self.reactionID = reactionID
        self.targetID = targetID
        self.isSelected = isSelected
        self.imageUrl = imageUrl
        self.count = count
        self.reactionSession = reactionSession
        self.userReactionID = userReactionID
    }
    
    func addReaction() { 
        reactionSession.addUserReaction(
            targetID: targetID,
            reactionID: reactionID,
            customData: nil
        ) { result in
            switch result {
            case .failure:
                break
            case .success(let userReaction):
                self.userReactionID = userReaction.id
                self.isSelected = true
            }
        }
    }
    
    func removeReaction() {
        guard let userReactionID = self.userReactionID else { return }
        reactionSession.removeUserReaction(
            userReactionID: userReactionID
        ) { result in
            switch result {
            case .failure:
                break
            case .success:
                self.userReactionID = nil
                self.isSelected = false
            }
        }
    }
    
}
