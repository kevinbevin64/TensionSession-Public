//
//  NoWorkoutsPrompt.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/28/25.
//

import SwiftUI

struct NoWorkoutsPrompt: View {
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: promptSpacing) {
            Image(systemName: "apps.iphone.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: promptGlyphWidth, height: promptGlyphHeight)
            
            Text("Tap to create a workout")
                .multilineTextAlignment(.center)
                .font(promptTextFont)
                .fontDesign(promptTextDesign)
        }
        .foregroundStyle(.promptFG)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}
