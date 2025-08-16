//
//  ExerciseView.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/18/25.
//

import SwiftUI

struct ExerciseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var viewModel: ViewModel
    
    init(_ exercise: Exercise, _ timeKeeper: TimeKeeper) {
        self.viewModel = ViewModel(exercise: exercise, timeKeeper: timeKeeper)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.indigo.opacity(0.6), .indigo.opacity(0.3), .indigo.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 50) {
                exerciseName
                setCounter
                
                HStack {
                    repPicker
                    weightPicker
                }
            }
        }
        .toolbar {
            CompleteSetButton { viewModel.completeSet() }
            ToolbarTimeView(viewModel.timeKeeper)
        }
    }
    
    var exerciseName: some View {
        Text(viewModel.exercise.name)
            .font(.largeTitle)
    }
    
    var setCounter: some View {
        Text("Set \(viewModel.exercise.setsDone + 1)")
    }
    
    var repPicker: some View {
        VStack {
            Text("Reps")
            
            Picker(selection: Binding(
                get: { viewModel.repsDone },
                set: { viewModel.repsDone = $0 }
            )) {
                ForEach(Array(stride(from: minRepCount, to: maxRepCount, by: 1)), id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            } label: {
                Text("hello there")
            }
            .pickerStyle(.wheel)
        }
    }
    
    var weightPicker: some View {
        VStack {
            Text("Weight")
            
            Picker(selection: Binding(
                get: { viewModel.weightUsed.value },
                set: { viewModel.weightUsed = Weight($0, in: .kilograms) }
            )) {
                ForEach(Array(stride(from: minWeightValue, to: maxWeightValue, by: 0.5)), id: \.self) { value in
                    Text("\(value.oneDPString)").tag(value)
                }
            } label: {
                Text("hello there")
            }
            .pickerStyle(.wheel)
        }
    }
    
    @Observable
    final class ViewModel {
        let exercise: Exercise
        var repsDone: Int
        var weightUsed: Weight
        let timeKeeper: TimeKeeper
        
        init(exercise: Exercise, timeKeeper: TimeKeeper) {
            self.exercise = exercise
            self.repsDone = exercise.setDetails[0].repsPlanned
            self.weightUsed = exercise.setDetails[0].weightPlanned
            self.timeKeeper = timeKeeper
        }
        
        func completeSet() {
            exercise.addSet(repsDone: self.repsDone, weightUsed: self.weightUsed)
            resetTimeKeeper()
        }
        
        func resetTimeKeeper() {
            timeKeeper.reset()
            timeKeeper.resume()
        }
    }
}

#Preview {
    ExerciseView(
        Exercise(name: "Test", sets: 3, reps: 12, weight: Weight(100, in: .kilograms)),
        TimeKeeper()
    )
}
