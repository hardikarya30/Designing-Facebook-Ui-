//
//  FriendsStore.swift
//  FacebookUI
//
//  Holds the Friends screen's state: the friend list, the pending requests
//  and which suggestions are followed.
//

import Combine
import Foundation

final class FriendsStore: ObservableObject {

    @Published private(set) var friends: [Friend] = SampleFriends.friends
    @Published private(set) var requests: [FriendRequest] = SampleFriends.requests
    @Published private(set) var followedSuggestionIDs: Set<String> = []

    /// The account's full friend count, of which the list shows a part.
    let totalFriendCount = 2412

    let suggestions: [FriendSuggestion] = SampleFriends.suggestions

    func accept(_ request: FriendRequest) {
        requests.removeAll { $0.id == request.id }

        let friend = Friend(
            id: "friend-\(request.id)",
            name: request.name,
            initials: request.initials,
            palette: request.palette,
            isOnline: false,
            status: "New friend"
        )

        if !friends.contains(where: { $0.id == friend.id }) {
            friends.insert(friend, at: 0)
        }
    }

    func decline(_ request: FriendRequest) {
        requests.removeAll { $0.id == request.id }
    }

    func isFollowing(_ suggestion: FriendSuggestion) -> Bool {
        followedSuggestionIDs.contains(suggestion.id)
    }

    func toggleFollow(_ suggestion: FriendSuggestion) {
        if followedSuggestionIDs.contains(suggestion.id) {
            followedSuggestionIDs.remove(suggestion.id)
        } else {
            followedSuggestionIDs.insert(suggestion.id)
        }
    }
}
