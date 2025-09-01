//
//  ExercisePlanGrid.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/28/25.
//

import SwiftUI

struct PlanGridView: View {
    @Environment(DataDelegate.self) var dataDelegate
    @Environment(Companion.self) var companion
    
    @State var selectedWorkout: Workout?
    @State var newWorkoutName: String = ""
    @State var isShowingWorkoutNameAlert: Bool = false
    
    var body: some View {
        Group {
            if let selectedWorkout {
                NavigationStack {
                    ScrollView {
                    // Workout selector
                    WorkoutSelector(
                        selection: $selectedWorkout,
                        options: dataDelegate.templateWorkouts,
                        onCreateWorkoutTapped: {
                            showWorkoutNameAlert()
                        },
                        onDeleteWorkoutTapped: {
                            deleteWorkout(selectedWorkout)
                        }
                    )
                    .padding( 10)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    
                    let spacing = CGFloat(16)
                    let columns = [
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing)
                    ]
                    
                    
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(selectedWorkout.exercises.sorted(by: { $0.dateAdded < $1.dateAdded } )) { exercise in
                                PlanGridExerciseItem(exercise) {
                                    companion.updateTemplateWorkout(selectedWorkout)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        removeExercise(exercise, from: selectedWorkout)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            
                            ZStack {
                                Button {
                                    addNewExercise(to: selectedWorkout)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(canAddExercise ? Color.white : Color.gray, .quaternary)
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                }
                                .disabled(!canAddExercise)
                                .buttonStyle(ShrinkingCircleButtonStyle())
                                .contentShape(.containerRelative)
                                .containerShape(.circle)
                                .padding()
                            }
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .background(.quaternary.opacity(0.5))
                            .contentShape(.containerRelative)
                            .containerShape(.rect(cornerRadius: 30))
                            .aspectRatio(1, contentMode: .fit)
                        }
                        .padding()
                    }
                    .navigationTitle("Plan")
                }
            } else {
                // There are no workouts
                NavigationStack {
                    NoWorkoutsPrompt {
                        print("Doing this")
                        showWorkoutNameAlert()
                    }
                    .navigationTitle("Plan")
                }
            }
        }
        .alert("Name your workout", isPresented: $isShowingWorkoutNameAlert) {
            createWorkoutAlertActions
        } message: {
            createWorkoutAlertMessage
        }
        .task {
            // Set the selected workout
            selectedWorkout = dataDelegate.templateWorkouts.first
        }
    }
    
    @ViewBuilder
    var createWorkoutAlertActions: some View {
        TextField("Workout name", text: $newWorkoutName)
        Button("Cancel", role: .cancel) {
            dismissWorkoutNameAlert()
        }
        Button("OK") {
            createNewWorkout(name: newWorkoutName)
            newWorkoutName = ""
            dismissWorkoutNameAlert()
        }
        .disabled({
            print("Evaluating newWorkout.name: \(newWorkoutName)")
            return newWorkoutName
        }() == "")
    }
    
    var createWorkoutAlertMessage: some View {
        Text("Enter a name for your new workout.")
    }
}

// MARK: - VIEW LOGIC
extension PlanGridView {
    func showWorkoutNameAlert() {
        isShowingWorkoutNameAlert = true
    }
    
    func dismissWorkoutNameAlert() {
        isShowingWorkoutNameAlert = false
    }
    
    func createNewWorkout(name: String = "") {
        let newWorkout = Workout(name: name)
        addNewWorkout(newWorkout)
    }
    
    func addNewWorkout(_ workout: Workout) {
        dataDelegate.addTemplateWorkout(workout)
        companion.addTemplateWorkout(workout)
        selectedWorkout = workout
    }
    
    func deleteWorkout(_ workout: Workout) {
        dataDelegate.deleteTemplateWorkout(workout)
        companion.deleteTemplateWorkout(workout)
        
        // Ensure all workouts are cleared if there should be zero templates
        if dataDelegate.templateWorkouts.isEmpty {
            companion.deleteAllTemplateWorkouts()
        }
        
        // Find a new template to set as the selectedWorkout
        selectedWorkout = dataDelegate.templateWorkouts.first
    }
    
    func addNewExercise(to workout: Workout) {
        let preferredWeightUnit = dataDelegate.userInfo.weightPreference.weightUnit
        workout.add(
            Exercise(
                name: "",
                sets: defaultSetCount,
                reps: defaultRepCount,
                weight: Weight(defaultWeightValue, in: preferredWeightUnit)
            )
        )
    }
    
    func removeExercise(_ exercise: Exercise, from workout: Workout) {
        workout.exercises.removeAll { $0.id == exercise.id }
        companion.updateTemplateWorkout(workout)
    }
    
    var canAddExercise: Bool {
        guard let selectedWorkout else {
            // Return false if the selectedWorkout is nil
            return false
        }
        
        return selectedWorkout.exercises.isEmpty || selectedWorkout.exercises.last?.name != ""
    }
}
