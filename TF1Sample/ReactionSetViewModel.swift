//
//  ReactionSetViewModel.swift
//  TF1Sample
//
//  Created by Work on 7/11/24.
//

import Foundation
import LiveLikeSwift
import LiveLikeCore

protocol ReactionSetViewModelListener: AnyObject {
    func totalReactionCountDidChange(count: Int)
}

// Data representing a list/set of reactions
class ReactionSetViewModel {
    
    @Atomic var totalReactionCount: Int {
        didSet {
            listeners.publish { $0.totalReactionCountDidChange(count: totalReactionCount) }
        }
    }
    let reactions: [ReactionViewModel]
    
    var listeners: Listener<ReactionSetViewModelListener> = Listener()
    
    var reactionSession: ReactionSession
    
    init(totalReactionCount: Int, reactions: [ReactionViewModel], reactionSession: ReactionSession) {
        self.totalReactionCount = totalReactionCount
        self.reactions = reactions
        
        self.reactionSession = reactionSession
        
        reactionSession.sessionDelegate = self
    }
    
}

extension ReactionSetViewModel: ReactionSessionDelegate {
    func reactionSession(_ reactionSession: ReactionSession, didAddReaction reaction: UserReaction) {
        reactions.first(where: { $0.reactionID == reaction.reactionID })?.count += 1
        self.totalReactionCount += 1
        
    }
    
    func reactionSession(_ reactionSession: ReactionSession, didRemoveReaction reaction: UserReaction) {
        reactions.first(where: { $0.reactionID == reaction.reactionID })?.count -= 1
        self.totalReactionCount -= 1
    }
}

