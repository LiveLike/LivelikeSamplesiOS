import Foundation
import LiveLikeSwift
import LiveLikeCore

protocol LLReactionSetViewModelListener: AnyObject {
    func totalReactionCountDidChange(count: Int)
    func reactionAdded(reactionID: String, imageURL: URL, oldCount: Int, newCount: Int)
    func reactionRemoved(reactionID: String, newCount: Int)
}

// Model representing a collection of reactions
class LLReactionSetViewModel {
    
    @Atomic var totalReactionCount: Int {
        didSet {
            listeners.publish { $0.totalReactionCountDidChange(count: totalReactionCount) }
        }
    }
    let reactions: [LLReactionViewModel]
    
    var listeners: Listener<LLReactionSetViewModelListener> = Listener()
    
    var reactionSession: ReactionSession
    
    init(totalReactionCount: Int, reactions: [LLReactionViewModel], reactionSession: ReactionSession) {
        self.totalReactionCount = totalReactionCount
        self.reactions = reactions
        
        self.reactionSession = reactionSession
        
        reactionSession.sessionDelegate = self
    }
    
}

extension LLReactionSetViewModel: ReactionSessionDelegate {
    func reactionSession(_ reactionSession: ReactionSession, didAddReaction reaction: UserReaction) {
        guard let reaction = reactions.first(where: { $0.reactionID == reaction.reactionID }) else { return }
        let oldCount = reaction.count
        reaction.count += 1
        self.listeners.publish {
            $0.reactionAdded(
                reactionID: reaction.reactionID,
                imageURL: reaction.imageUrl,
                oldCount: oldCount,
                newCount: reaction.count
            )
        }
        self.totalReactionCount += 1
        
    }
    
    func reactionSession(_ reactionSession: ReactionSession, didRemoveReaction reaction: UserReaction) {
        guard let reaction = reactions.first(where: { $0.reactionID == reaction.reactionID }) else { return }
        reaction.count -= 1
        self.listeners.publish {
            $0.reactionRemoved(
                reactionID: reaction.reactionID,
                newCount: reaction.count
            )
        }
        self.totalReactionCount -= 1
    }
}

