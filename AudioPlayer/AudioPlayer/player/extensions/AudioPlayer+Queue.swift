//
//  AudioPlayer+Queue.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 29/03/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

extension AudioPlayer {
    /// The items in the queue if any.
    public var items: [AudioItem]? {
        return queue?.queue
    }

    /// The current item index in queue.
    public var currentItemIndexInQueue: Int? {
        return currentItem.flatMap { queue?.items.firstIndex(of: $0) }
    }

    /// A boolean value indicating whether there is a next item to play or not.
    public var hasNext: Bool {
        return queue?.hasNextItem ?? false
    }

    /// A boolean value indicating whether there is a previous item to play or not.
    public var hasPrevious: Bool {
        return queue?.hasPreviousItem ?? false
    }

    /// Plays an item.
    ///
    /// - Parameter item: The item to play.
    public func play(item: AudioItem) {
        play(items: [item])
    }
    
    public func play(index: Int) {
        guard index < (queue?.items.count ?? 0) else {
            return
        }
        let toPlayItem =  queue?.items[index]
        currentItem = toPlayItem
    }
    
    /// Creates a queue according to the current mode and plays it.
    ///
    /// - Parameters:
    ///   - items: The items to play.
    ///   - index: The index to start the player with.
    public func play(items: [AudioItem], startAtIndex index: Int = 0) {
        if !items.isEmpty {
            queue = AudioItemQueue(items: items, mode: mode)
            queue?.delegate = self
            if let realIndex = queue?.queue.firstIndex(of: items[index]) {
                queue?.nextPosition = realIndex
            }
            currentItem = queue?.nextItem() // 设置item时开始播放
        } else {
            stop()
            queue = nil
        }
    }
    
    /// Adds an item at the end of the queue. If queue is empty and player isn't playing, the behaviour will be similar
    /// to `play(item:)`.
    ///
    /// - Parameter item: The item to add.
    public func add(item: AudioItem) {
        add(items: [item])
    }
    
    public func add(item: AudioItem, immediatelyPlay:Bool) {
        add(items: [item], immediatelyPlay: immediatelyPlay)
    }

    /// Adds items at the end of the queue. If the queue is empty and player isn't playing, the behaviour will be
    /// similar to `play(items:)`.
    ///
    /// - Parameter items: The items to add.
    public func add(items: [AudioItem]) {
        if let queue = queue {
            queue.add(items: items)
        } else {
            play(items: items)
        }
    }
    
    public func add(items:[AudioItem], immediatelyPlay:Bool) {
        if let queue = queue {
            queue.add(items: items)
        } else {
            if immediatelyPlay {
                play(items: items)
            }
            if  queue == nil {
                self.queue = AudioItemQueue(items: items, mode: mode)
                self.queue?.delegate = self
            }
        }
    }

    /// Removes an item at a specific index in the queue.
    ///
    /// - Parameter index: The index of the item to remove.
    public func removeItem(at index: Int) {
        queue?.remove(at: index)
    }
}

extension AudioPlayer: AudioItemQueueDelegate {
    /// Returns a boolean value indicating whether an item should be consider playable in the queue.
    ///
    /// - Parameters:
    ///   - queue: The queue.
    ///   - item: The item we ask the information for.
    /// - Returns: A boolean value indicating whether an item should be consider playable in the queue.
    func audioItemQueue(_ queue: AudioItemQueue, shouldConsiderItem item: AudioItem) -> Bool {
        return delegate?.audioPlayer(self, shouldStartPlaying: item) ?? true
    }
}
