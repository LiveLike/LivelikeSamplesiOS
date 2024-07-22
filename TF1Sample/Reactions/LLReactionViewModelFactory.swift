import Foundation
import LiveLikeSwift

class LLReactionViewModelFactory {
    
    enum Errors: Error {
        case noReactionSpaces
        case noReactionPacks
    }
    
    static func make(
        sdk: LiveLike,
        targetGroupID: String,
        targetID: String
    ) async throws -> LLReactionSetViewModel{
        let reactionSpace = try await withCheckedThrowingContinuation { c in
            sdk.reaction.getReactionSpaces(
                reactionSpaceID: nil,
                targetGroupID: targetGroupID,
                page: .first
            ) {
                c.resume(with: $0)
            }
        }.first
        
        guard let reactionSpace = reactionSpace else {
            throw Errors.noReactionSpaces
        }
        guard let reactionPackID = reactionSpace.reactionPackIDs.first else {
            throw Errors.noReactionPacks
        }
        
        let reactionSession = sdk.reaction.createReactionSession(
            reactionSpace: reactionSpace
        )
        
        let reactionPack = try await withCheckedThrowingContinuation { c in
            sdk.reaction.getReactionPackInfo(
                reactionPackID: reactionPackID
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
        }.first
        
        let totalReactionCount = reactionCounts?.reactions.map { $0.count }.reduce(0, +) ?? 0
        
        return LLReactionSetViewModel(
            totalReactionCount: totalReactionCount,
            reactions: reactionPack.emojis.map { emoji in
                let reactions = reactionCounts?.reactions.first(where: { $0.reactionID == emoji.id })
                return LLReactionViewModel(
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
