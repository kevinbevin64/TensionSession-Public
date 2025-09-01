//
//  ToolbarTimeView.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/5/25.
//

import SwiftUI

struct ToolbarTimeView: ToolbarContent {
    let timeKeeper: TimeKeeperProtocol
    
    init(_ timeKeeper: TimeKeeperProtocol) {
        self.timeKeeper = timeKeeper
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            TimeKeeperView(timeKeeper)
            
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
