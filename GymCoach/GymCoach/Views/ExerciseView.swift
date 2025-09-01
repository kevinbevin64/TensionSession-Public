//
//  ExerciseView.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/18/25.
//

import SwiftUI
import SwiftData
import Charts

struct ExerciseView: View {
    // MARK: - Properties
    @Environment(DataDelegate.self) var dataDelegate
    @Environment(TimeKeeper.self) var timeKeeper
//    @Environment(WorkoutDataAnalyzer.self) var workoutDataAnalyzer
    
    let exercise: Exercise
    @State var currentRepsDone: Int
    @State var currentWeightUsed: Weight
    @State var showExerciseHistory: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - init
    init(_ exercise: Exercise) {
        self.exercise = exercise
        self.currentRepsDone = exercise.setDetails.first?.repsPlanned ?? 0
        self.currentWeightUsed = exercise.setDetails.first?.weightPlanned ?? Weight(value: 0, unit: .kilograms)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.uiBackground.opacity(0.5), Color.uiBackground.opacity(0.2), Color.uiBackground.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 10) {
                exerciseName
                setCounter
                
                HStack(spacing: 30) {
                    repSelector
                    weightSelector
                }
            }
        }
        .toolbar {
            // Top bar
            ToolbarItem(placement: .topBarTrailing) { setDoneButton }
            
            // Bottom bar
            ToolbarItemGroup(placement: .bottomBar) {
                showExerciseDataButton
                toggleWeightUnitButton
            }
            
            ToolbarItem(placement: .principal) {
                TimeKeeperView(timeKeeper)
            }
            
        }
        .sheet(isPresented: $showExerciseHistory) {
            // Showing the exercise history
            NavigationStack {
                ExerciseDataView(exerciseName: exercise.name)
                    .navigationTitle(exercise.name)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
//                    .toolbar {
//                        ToolbarItem(placement: .topBarTrailing) {
//                            Button {
//                                dismiss()
//                            } label: {
//                                Image(systemName: "xmark.circle.fill")
//                                    .symbolRenderingMode(.hierarchical)
//                                    .fontWeight(.bold)
//                                    .foregroundStyle(.white)
//                                    .font(.title3)
//                            }
//                        }
//                    }
            }
//            ExerciseDataView(exercise: exercise, workoutDataAnalyzer: workoutDataAnalyzer, dataDelegate: dataDelegate)
        }
    }
    
    // MARK: - VIEW COMPONENTS
    var setCounter: some View {
        HStack {
            Text("Set")
                .fontDesign(.rounded)
//                .foregroundStyle(Color.exerciseSetText)
//                .foregroundStyle(Color.set)
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 24, height: 24)
                
                Text("\(exercise.setsDone + 1)")
                    .fontDesign(.rounded)
                    .contentTransition(.numericText(value: Double(exercise.setsDone + 1)))
            }
        }
        .fontWeight(.medium)
    }
    
    @ViewBuilder
    var repSelector: some View {
        let repsPlanned = exercise.setDetails[exercise.setsDone < exercise.setDetails.count ? exercise.setsDone : exercise.setDetails.count - 1].repsPlanned
        VStack {
            Picker("Reps", selection: $currentRepsDone) {
                ForEach(Array(stride(from: minRepCount, to: maxRepCount, by: 1)), id: \.self) { repCount in
                    Text("\(repCount)").tag(repCount)
                }
            }
            .pickerStyle(.wheel)
            
            Text("\(repsPlanned)")
                .fontDesign(.rounded)
        }
    }
    
    @ViewBuilder
    var weightSelector: some View {
        let weightPlanned = exercise.setDetails[exercise.setsDone < exercise.setDetails.count ? exercise.setsDone : exercise.setDetails.count - 1].weightPlanned
        VStack {
            Picker("Weight", selection: $currentWeightUsed) {
                ForEach(Array(stride(from: minWeightValue, to: maxWeightValue, by: 0.5)), id: \.self) { value in
                    Text("\(value.oneDPString)").tag(Weight(value, in: currentWeightUsed.unit))
                }
            }
            .pickerStyle(.wheel)
            
            Text("\(weightPlanned.value.oneDPString)")
                .fontDesign(.rounded)
        }
    }
    
    var exerciseName: some View {
        Text("\(exercise.name)")
            .foregroundStyle(Color.exerciseName)
            .fontDesign(.rounded)
            .fontWeight(.medium)
            .font(.title3)
    }
    
    // MARK: - Toolbar buttons
    var setDoneButton: some View {
        Button {
            markSetDone()
        } label: {
            Image(systemName:"checkmark")
                .foregroundColor(.green)
        }
    }
    
    var toggleWeightUnitButton: some View {
        Button {
            toggleWeightUnit()
        } label: {
            Text(currentWeightUsed.unit == .kilograms ? "kg" : "lb")
                .fontDesign(.monospaced)
        }
    }
    
    var showExerciseDataButton: some View {
        Button {
            displayExerciseData()
        } label: {
            Image(systemName: "chart.xyaxis.line")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .tertiary)
        }
    }
}

// MARK: - VIEW LOGIC
extension ExerciseView {
    func markSetDone() {
        withAnimation() {
            exercise.addSet(repsDone: currentRepsDone, weightUsed: currentWeightUsed)
        }
        timeKeeper.reset()
        timeKeeper.resume()
        
        if shouldDismissThisView {
//            WKInterfaceDevice.current().play(.success)
            dismiss()
        } else {
//            WKInterfaceDevice.current().play(.directionUp)
        }
    }
    
    var shouldDismissThisView: Bool {
        exercise.setsDone >= exercise.setsPlanned
    }
    
    func toggleWeightUnit() {
        if currentWeightUsed.unit == .kilograms {
            currentWeightUsed.unit = .pounds
        } else {
            currentWeightUsed.unit = .kilograms
        }
//        WKInterfaceDevice.current().play(.click)
    }
    
    func displayExerciseData() {
        showExerciseHistory = true
    }
}
