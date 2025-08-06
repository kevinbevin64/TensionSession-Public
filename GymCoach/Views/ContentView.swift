//
//  ContentView.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/18/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var dataDelegate: DataDelegate
    @State var companion: Companion

    var body: some View {
        TabView {
            Tab("Record", systemImage: "dumbbell.fill") {
                RecordView(dataDelegate: dataDelegate)
            }
            
            Tab("Plan", systemImage: "wrench.adjustable.fill") {
                PlanView(dataDelegate: dataDelegate, companion: companion)
            }
            
            Tab("Analyze", systemImage: "chart.xyaxis.line") {
                AnalyzeView(dataDelegate: dataDelegate)
            }
        }
    }
}
