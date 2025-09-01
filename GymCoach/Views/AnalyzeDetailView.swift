
//
//  ExerciseDataView.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/29/25.
//

import SwiftUI

struct ExerciseDataView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(DataDelegate.self) var dataDelegate
    @Environment(WorkoutDataAnalyzer.self) var workoutDataAnalyzer
    
    let exerciseName: String
    
    var body: some View {
        if workoutDataAnalyzer.getLast(10, weightsFor: exerciseName) == [] {
            // No history
            Text("This exercise has no history yet")
        } else {
            List {
                Section("Weight Graph") {
                    WeightLineChart(
                        weights: workoutDataAnalyzer.getLast(10, weightsFor: exerciseName).map {
                            $0.converted(to: dataDelegate.userInfo.weightPreference.weightUnit).value
                        },
                        width: 300,
                        height: 200
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    //                    .listItemTint(Color.clear)
                    .listRowInsets(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
                    .contentShape(Rectangle())
                }
                
                let data = workoutDataAnalyzer.exerciseData[exerciseName]?.reversed() ?? []
                ForEach(data.indices, id: \.self) { i in
                    if !data[i].weights.isEmpty {
                        Section(data[i].date.formatted(date: .abbreviated, time: .omitted)) {
                            let length = data[i].weights.count
                            ForEach(data[i].weights.indices, id: \.self) { j in
                                Text("\(data[i].weights[length - j - 1].description)")
                            }
                        }
                    }
                }
                
                
                Section {
                    EmptyView()
                } footer: {
                    Text("Weight trend for \(exerciseName).")
                        .multilineTextAlignment(.leading)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .opacity(0.80)
                }
            }
        }
    }
}
