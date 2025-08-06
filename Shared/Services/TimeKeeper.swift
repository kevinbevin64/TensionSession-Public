//
//  Clock.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/23/25.
//

import Foundation
import SwiftData

// Note: I named this class `TimeKeeper` instead of Timer because it should be able to provide both
// timer- and stopwatch-like functionality.

// This service publishes one value, `displayTime`, which is observed by a view.
@Observable
final class TimeKeeper {
    // This is the value that is observed by timer views. All other values are un-observed.
    var timeDisplay: String {
        let timeElapsed = timeElapsed
        let seconds = timeElapsed.truncatingRemainder(dividingBy: 60)
        let minutes = timeElapsed - seconds
        
        let secondsString = String(format: "%02d", Int(seconds.rounded(.down)))
        let minutesString = String(format: "%02d", Int(minutes.rounded(.down) / 60))
        return "\(minutesString):\(secondsString)"
    }
    
    var isRunning: Bool {
        timerTask != nil
    }
    
    // The amount of time this TimeKeeper has spent active
    private var timeElapsed: TimeInterval
    
    // The time that this TimeKeeper was started
    private var startTime: Date?
    
    // The time that this TimeKeeper was last paused
    private var lastPausedTime: Date?
    
    // The total amount of time this TimeKeeper has spent
    private var pauseDuration: TimeInterval

    // The task that updates the timeElapsed value
    private var timerTask: Task<Void, Never>?
    
    init(
        timeElapsed: TimeInterval = .zero,
        pauseDuration: TimeInterval = .zero
    ) {
        self.timeElapsed = timeElapsed
        self.startTime = nil
        self.lastPausedTime = nil
        self.pauseDuration = pauseDuration
    }
    
    func resume() {
        // Only start the timer if it is not already running.
        // NOTE: timeTask is non-nil when the timer is running; nil when it isn't running.
        guard timerTask == nil else { return }
        
        if startTime == nil {
            // If we are starting (not resuming), grab the start time
            startTime = Date()
        } else {
            // When we resume, the last paused time must have been previously stored.
            guard let lastPausedTime else {
                preconditionFailure("Last paused time must be stored before resuming.")
            }
            
            pauseDuration += Date().timeIntervalSince(lastPausedTime)
            self.lastPausedTime = nil
        }
        
        timerTask = Task {
            // Update timeElapsed
            guard let startTime = self.startTime else {
                preconditionFailure("Start time must be set before starting the timer.")
            }
            
            // Update the timeElapsed every 50 milliseconds
            while !Task.isCancelled {
                // Update timeElapsed on the main thread. 
                await MainActor.run {
                    timeElapsed = Date().timeIntervalSince(startTime) - pauseDuration
                }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }
    
    func pause() {
        // Only pause the timer is there is one running.
        guard timerTask != nil else { return }
        
        // Record time when last paused
        lastPausedTime = Date()
        
        // Cancel the timerTask
        timerTask?.cancel()
        timerTask = nil
    }
    
    func reset() {
        // Cancel the timer if it's running
        timerTask?.cancel()
        timerTask = nil

        // Reset all state
        timeElapsed = 0
        startTime = nil
        lastPausedTime = nil
        pauseDuration = 0
    }
}

// MARK: - Plan
/// TimeKeeper role: Act as either a stopwatch or a timer, executing a closure when a provided
/// alert duration has elapsed.
///
/// Functions:
///   - resume: starts or continues the TimeKeeper
///   - pause: pauses the TimeKeeper
///   - reset: resets the values of the TimeKeeper
///
/// Variables:
///   - public timeDisplay
///   - private timeElapsed = .zero
///   - private startTime (optional)
///   - private lastPausedTime (optional)
///   - private pauseDuration = .zero
///
/// Idea:
///   - Keep track of the start time
///     - So, I need a startTime that is an optional Date
///   - Update the timeDisplay every time I check the time
///     - timeDisplay gets its information from the difference between the current time and the
///       start time
///   - Handling pausing
///     - In addition to the timeDisplay which keeps track of the amount of time spent while the
///       TimeKeeper was running, we have a pauseDuration which tracks the amount of time spent
///       while in a paused state. To calculate timeDisplay, we do:
///           Date.now - startTime - pauseDuration
///     - We also need a lastPausedTime, so that when the timer is resumed again, we can can add the
///       difference between the current time and last paused time to the pauseDuration, which
///       can then be used in the calculation of timeDisplay
///       - Because time display displays either a stopwatch or timer, and I want to always know
///         the stopwatch time, there will be a private variable, timeElapsed
///
///   - Handling stopping
///     - When the time is stopped, then then we save the elapsed time to the timeElapsed variable
///
///   - Handling resetting
///     - Set the timeElapsed to 0, make startTime nil, make lastPausedTime nil,
///
///   - Main implementation:
///     - When the TimeKeeper is resumed, start a Task that updates the timeElapsed value every
///       50 milliseconds (20 times a second)
///     - when the TimeKeepr is paused, stop that Task
///     - when the TimeKeeper is stopped, stop/kill(?) that Task
///
