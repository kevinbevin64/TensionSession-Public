//
//  TogglableNumber.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/2/25.
//

import SwiftUI

struct TitledRoundedRectangle<T: StringProtocol>: View {
    let title: T
    let cornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            // Bounding box
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.1))
                .padding(8)
                .padding(.vertical, 20)
            
            // The title
            Text(title)
                .font(.system(size: 20))
        }
        .contentShape(Rectangle()) // Makes the entire shape clickable
    }
}
