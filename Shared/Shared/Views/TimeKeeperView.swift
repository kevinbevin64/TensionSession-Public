//
//  TimeKeeperView.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/20/25.
//

import SwiftUI

struct TimeKeeperView: View {
    let timeKeeper: TimeKeeperProtocol
    
    init(_ timeKeeper: TimeKeeperProtocol) {
        self.timeKeeper = timeKeeper
    }
    
    var body: some View {
        Text("\(timeKeeper.timeDisplay)")
            .font(.body)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(.yellow)
    }
}
