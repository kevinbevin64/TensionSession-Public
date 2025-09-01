//
//  AnalyzeGridExerciseItem.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/29/25.
//

import SwiftUI

struct AnalyzeGridExerciseItem: View {
    @Environment(DataDelegate.self) var dataDelegate
    @Environment(WorkoutDataAnalyzer.self) var workoutDataAnalyzer
    
    let exerciseName: String
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Text(exerciseName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.2)
                    .layoutPriority(1)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            Divider().background(Color.white)
            Spacer()
            
            WeightLineChart(
                weights: workoutDataAnalyzer.getLast(10, weightsFor: exerciseName).map {
                    $0.converted(to: dataDelegate.userInfo.weightPreference.weightUnit).value
                },
                width: 130,
                height: 80
            )
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(.quaternary)
        .contentShape(.containerRelative)
        .containerShape(.rect(cornerRadius: gridItemCornerRadius))
        .aspectRatio(1, contentMode: .fit)
    }
}
