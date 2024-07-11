//
//  ReactionViewModelFactory.swift
//  TF1Sample
//
//  Created by Work on 7/11/24.
//

import Foundation
import EngagementSDK
import LiveLikeSwift

class ReactionViewModelFactory {
    
    static func make(
        sdk: EngagementSDK,
        targetGroupID: String,
        targetID: String
    ) async throws -> ReactionSetViewModel{
        let reactionSpace = try await withCheckedThrowingContinuation { c in
            sdk.reaction.getReactionSpaces(
                reactionSpaceID: nil,
                targetGroupID: targetGroupID,
                page: .first
            ) {
                c.resume(with: $0)
            }
        }.first!
        
        let reactionSession = sdk.reaction.createReactionSession(
            reactionSpace: reactionSpace
        )
        
        let reactionPack = try await withCheckedThrowingContinuation { c in
            sdk.reaction.getReactionPackInfo(
                reactionPackID: reactionSpace.reactionPackIDs.first!
            ) {
                c.resume(with: $0)
            }
        }
        
        let reactionCounts = try await withCheckedThrowingContinuation { c in
            reactionSession.getUserReactionsCount(
                reactionSpaceID: reactionSpace.id,
                targetID: [targetID],
                page: .first
            ) { 
                c.resume(with: $0)
            }
        }.first!
        
        return ReactionSetViewModel(
            totalReactionCount: reactionCounts.reactions.map { $0.count }.reduce(0, +),
            reactions: reactionPack.emojis.map { emoji in
                let reactions = reactionCounts.reactions.first(where: { $0.reactionID == emoji.id })
                return ReactionViewModel(
                    reactionID: emoji.id,
                    targetID: targetID,
                    isSelected: reactions?.selfReactedUserReactionId != nil,
                    imageUrl: emoji.file,
                    count: reactions?.count ?? 0,
                    reactionSession: reactionSession,
                    userReactionID: reactions?.selfReactedUserReactionId
                )
            }, reactionSession: reactionSession
        )
    }
    
}
