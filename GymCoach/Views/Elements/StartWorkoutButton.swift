//
//  StartWorkoutButton.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/29/25.
//

import SwiftUI

/// A button used for starting a workout when the user wants to record a workout session.
struct StartWorkoutButton: ToolbarContent {
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                action()
            } label: {
                // "Start" text with a play button
                HStack {
                    Text("Start")
                    
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
            }
            .padding(toolbarButtonEdgeInsets)
            .foregroundStyle(.startButtonFG)
            .background(.startButtonBG, in: Capsule())
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            
        }
        .toolbar {
            StartWorkoutButton { }
        }
    }
}
