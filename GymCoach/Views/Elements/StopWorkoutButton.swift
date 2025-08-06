//
//  StopWorkoutButton.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/29/25.
//

import SwiftUI

/// A button used for stopping a workout.
struct StopWorkoutButton: ToolbarContent {
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                action()
            } label: {
                // "Stop" text with a stop icon
                HStack {
                    Text("Stop")
                    
                    Image(systemName: "stop.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
            }
            .padding(toolbarButtonEdgeInsets)
            .foregroundStyle(.stopButtonFG)
            .background(.stopButtonBG, in: Capsule())
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            
        }
        .toolbar {
            PauseWorkoutButton { }
        }
    }
}
