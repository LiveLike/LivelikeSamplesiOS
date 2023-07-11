import Foundation
import LiveLikeSwift

/// Makes submitting votes more responsive by preemptively modifying the vote counts before the server responds
/// Assumes initial vote counts contains user's vote if exists
/// Assumes submitVote will always succeed
/// Assumes that next realtime update will contain my vote
class PollWidgetViewModel {
    
    private var voteCountsByOptionID: [String: Int]
    private let model: PollWidgetModel
    private var lastVotedOptionID: String?
    
    var voteCountsDidChange: () -> Void = { }
    
    init(model: PollWidgetModel) {
        voteCountsByOptionID = model.options.reduce(into: [:], { result, option in
            result[option.id] = option.voteCount
        })
        self.lastVotedOptionID = model.mostRecentVote?.optionID
        self.model = model
        model.delegate = self
    }
    
    func getVoteCount(optionID: String) -> Int {
        return voteCountsByOptionID[optionID] ?? 0
    }
    
    func getVoteCountTotal() -> Int {
        return voteCountsByOptionID.values.reduce(0, +)
    }
    
    func submitVote(
        optionID: String
    ) {
        if let lastVotedOptionID = lastVotedOptionID {
            // decrement the previous vote option by 1
            let voteCount = voteCountsByOptionID[lastVotedOptionID] ?? 0
            let decrementedVoteCount = voteCount > 0 ? voteCount - 1 : 0
            voteCountsByOptionID[lastVotedOptionID] = decrementedVoteCount
        }
        // increment the new vote option
        let newVoteCount = (voteCountsByOptionID[optionID] ?? 0) + 1
        voteCountsByOptionID[optionID] = newVoteCount
        
        model.submitVote(optionID: optionID)
        lastVotedOptionID = optionID
        
        voteCountsDidChange()
    }
}

extension PollWidgetViewModel: PollWidgetModelDelegate {
    
    func pollWidgetModel(
        _ model: PollWidgetModel,
        voteCountDidChange voteCount: Int,
        forOption optionID: String
    ) {
        voteCountsByOptionID = model.options.reduce(into: [:], { result, option in
            result[option.id] = option.voteCount
        })
        voteCountsDidChange()
    }
    
}
