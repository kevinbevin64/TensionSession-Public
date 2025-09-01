//
//  NoExercisesPrompt.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/29/25.
//

import SwiftUI

struct NoExercisesPrompt: View {
    var body: some View {
        VStack(spacing: promptSpacing) {
            Image(systemName: "plus.magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: promptGlyphWidth, height: promptGlyphHeight)
            
            Text("This workout has no exercises. Add exercises in the 'Plan' tab.")
                .multilineTextAlignment(.center)
                .font(promptTextFont)
                .fontDesign(promptTextDesign)
        }
        .foregroundStyle(.promptFG)
    }
}
