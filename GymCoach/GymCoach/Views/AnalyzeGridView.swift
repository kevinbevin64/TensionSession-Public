//
//  AnalyzeGridView.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/29/25.
//

import SwiftUI

struct AnalyzeGridView: View {
    @Environment(WorkoutDataAnalyzer.self) var workoutDataAnalyzer
    
    var body: some View {
        NavigationStack {
            ScrollView {
                let spacing = CGFloat(16)
                let columns = [
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing)
                ]
            
            
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(workoutDataAnalyzer.exerciseData.keys.sorted(by: { $0 < $1 } )), id: \.self) { exerciseName in
                        NavigationLink(value: exerciseName) {
                            AnalyzeGridExerciseItem(exerciseName: exerciseName)
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: String.self) { exerciseName in
                ExerciseDataView(exerciseName: exerciseName)
                    .navigationTitle(exerciseName)
            }
            .navigationTitle("Analyze")
        }
    }
}
