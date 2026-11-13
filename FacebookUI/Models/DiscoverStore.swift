//
//  DiscoverStore.swift
//  FacebookUI
//
//  Keeps the Discover screen's state: who is followed and which tiles
//  have been liked.
//

import Combine
import Foundation

final class DiscoverStore: ObservableObject {

    let topics: [TrendingTopic] = SampleDiscover.topics
    let tiles: [ExploreTile] = SampleDiscover.tiles
    let people: [DiscoverPerson] = SampleDiscover.people

    @Published private(set) var followedIDs: Set<String> = []
    @Published private(set) var likedTileIDs: Set<String> = []

    func isFollowing(_ person: DiscoverPerson) -> Bool {
        followedIDs.contains(person.id)
    }

    func toggleFollow(_ person: DiscoverPerson) {
        if followedIDs.contains(person.id) {
            followedIDs.remove(person.id)
        } else {
            followedIDs.insert(person.id)
        }
    }

    func isLiked(_ tile: ExploreTile) -> Bool {
        likedTileIDs.contains(tile.id)
    }

    func toggleLike(_ tile: ExploreTile) {
        if likedTileIDs.contains(tile.id) {
            likedTileIDs.remove(tile.id)
        } else {
            likedTileIDs.insert(tile.id)
        }
    }
}
