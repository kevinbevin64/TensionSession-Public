//
//  ExerciseRecordCard.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/22/25.
//

import SwiftUI

struct ExerciseRecordCard: View {
    let exercise: Exercise
    let isActive: Bool
    
    init(_ exercise: Exercise, isActive: Bool) {
        self.exercise = exercise
        self.isActive = isActive
    }
    
    var body: some View {
        NavigationLink(value: isActive ? exercise : nil) {
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(.top, 5)
                        .padding(.leading, -1)
                        .foregroundStyle(Color.white.opacity(0.66))
                    
                    Text("\(exercise.name)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(exercise.setsPlanned) sets")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontWeight(.light)
                        .padding(.leading, 1)
                        .foregroundColor(.white.opacity(0.8))
                    
                }
                
                Spacer()
                
                VStack {
                    // Completion ring
                }
            }
        }
        .contentShape(Rectangle()) // Allows the full card to be clickable 
    }
}

#Preview {
    ZStack {
        Color.white
            .ignoresSafeArea(edges: .all)

        List {
            ExerciseRecordCard(Exercise(name: "Test Exercise", sets: 3, reps: 12, weight: Weight(100, in: getSystemWeightUnit())), isActive: true)
            ExerciseRecordCard(Exercise(name: "Test Exercise", sets: 3, reps: 12, weight: Weight(100, in: getSystemWeightUnit())), isActive: true)
            ExerciseRecordCard(Exercise(name: "Test Exercise", sets: 3, reps: 12, weight: Weight(100, in: getSystemWeightUnit())), isActive: true)
            ExerciseRecordCard(Exercise(name: "Test Exercise", sets: 3, reps: 12, weight: Weight(100, in: getSystemWeightUnit())), isActive: true)
            ExerciseRecordCard(Exercise(name: "Test Exercise", sets: 3, reps: 12, weight: Weight(100, in: getSystemWeightUnit())), isActive: true)
        }
        .listStyle(.plain)
    }
}
