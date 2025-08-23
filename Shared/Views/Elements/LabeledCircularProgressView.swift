//
//  ProgressView.swift
//  GymCoach
//
//  Created by Kevin Chen on 8/20/25.
//

import SwiftUI

struct LabeledCircularProgressView<Content: View>: View {
    let progress: Double
    let label: () -> Content
    
    init(value: Double, total: Double = 1.0, @ViewBuilder label: @escaping () -> Content) {
        self.progress = min(value / total, 1.0)
        self.label = label
    }
    
    init(value: Int, total: Int, @ViewBuilder label: @escaping () -> Content) {
        self.init(value: Double(value), total: Double(total), label: label)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill((Color.black.opacity(0.3)))
            
            ProgressView(value: progress)
                .progressViewStyle(.circular)
                .tint(.blue)
            
            label()
        }
    }
}
