//
//  ToolbarTimeView.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/5/25.
//

import SwiftUI

struct ToolbarTimeView: ToolbarContent {
    let timeKeeper: TimeKeeper
    
    init(_ timeKeeper: TimeKeeper) {
        self.timeKeeper = timeKeeper
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("\(timeKeeper.timeDisplay)")
                .font(.body)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.yellow)
            
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            
        }
        .toolbar {
            ToolbarTimeView({ let timeKeeper = TimeKeeper(); timeKeeper.resume(); return timeKeeper; }())
        }
    }
}
