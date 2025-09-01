//
//  NoTemplatesPrompt.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/29/25.
//

import SwiftUI

/// This view is shown when a user is at RecordView
struct NoTemplatesPrompt: View {
    var body: some View {
        VStack(spacing: promptSpacing) {
            Image(systemName: "questionmark.text.page.fill")
                .resizable()
                .scaledToFit()
                .frame(width: promptGlyphWidth, height: promptGlyphHeight)
            
            Text("No template workouts found\nCreate one in the 'Plan' tab")
                .multilineTextAlignment(.center)
                .font(promptTextFont)
                .fontDesign(promptTextDesign)
        }
        .foregroundStyle(.promptFG)
    }
}

#Preview {
    NoTemplatesPrompt()
}
