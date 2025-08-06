//
//  CompleteSetButton.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/29/25.
//

import SwiftUI

struct CompleteSetButton: ToolbarContent {
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                action()
            } label: {
                // "Pause" text with a pause button
                HStack {
                    Text("Done")
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
            }
            .padding(toolbarButtonEdgeInsets)
            .foregroundStyle(.completeSetButtonFG)
            .background(.completeSetButtonBG, in: Capsule())
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
