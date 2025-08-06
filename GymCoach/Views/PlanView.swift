//
//  PlanView.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/23/25.
//

import Foundation
import SwiftUI

struct PlanView: View {
    @State var viewModel: ViewModel
    // Add state for alert and text field
    @State private var showNewWorkoutAlert = false
    @State private var newWorkoutName = ""
    
    init(dataDelegate: DataDelegate, companion: CompanionProtocol) {
        self.viewModel = ViewModel(dataDelegate: dataDelegate, companion: companion)
    }
    
    var body: some View {
        NavigationStack {
            List {
                WorkoutSelector(selection: $viewModel.selectedWorkout, options: viewModel.dataDelegate.templateWorkouts) {
                    // Show alert instead of creating workout directly
                    showNewWorkoutAlert = true
                } onDeleteWorkoutTapped: {
                    if let selectedWorkout = viewModel.selectedWorkout {
                        viewModel.delete(selectedWorkout)
                    }
                }
                
                // Show the exercises for a workout if there is at least one template workout
                // and the selectedWorkout is non-nil.
                if let workout = viewModel.selectedWorkout, !viewModel.templateWorkouts.isEmpty {
                    // List of exercises
                    ForEach(workout.exercises.sorted(by: { $0.dateAdded < $1.dateAdded })) { exercise in
                        ExercisePlanCard(exercise, weightPreference: viewModel.dataDelegate.userInfo.weightPreference)
                            .listRowInsets(exercisePlanCardEdgeInsets)
                            .roundedListItemStyle(cornerRadius: 16, backgroundColor: .exerciseCardBG)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", role: .destructive) {
                                    viewModel.selectedWorkout?.exercises.removeAll(where: { $0.id == exercise.id })
                                }
                            }
                    }
                    
                    if viewModel.lastAddedExercise == nil || viewModel.lastAddedExercise?.name != "" {
                        // Add a new exercise
                        Button("Add new exercise") {
                            viewModel.createNewExercise()
                        }
                    }
                }
            }
            .roundedListStyle()
            .navigationTitle("Plan")
        }
        // Add alert for naming new workout
        .alert("Name your workout", isPresented: $showNewWorkoutAlert) {
            TextField("Workout name", text: $newWorkoutName)
            Button("Cancel", role: .cancel) {
                newWorkoutName = ""
            }
            Button("OK") {
                viewModel.add(Workout(name: newWorkoutName))
                newWorkoutName = ""
            }.disabled(newWorkoutName.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("Please enter a name for your new workout.")
        }
    }
    
    var testingUtility: some View {
        VStack {
            Text("Number of templates: \(viewModel.templateWorkouts.count)")
            Text("Selected workout: \(viewModel.selectedWorkout != nil ? viewModel.selectedWorkout!.name : "nil")")
            Button("Create workout") {
                viewModel.createWorkout()
            }
            Button("Delete all") {
                viewModel.deleteAllTemplates()
            }
            
            Button("Create historical workout") {
                viewModel.dataDelegate.addHistoricalWorkout(Workout(name: "Test", isTemplate: false))
            }
            
            Button("Verify counts") {
                if viewModel.templateWorkouts.count == viewModel.dataDelegate.fetchTemplateWorkouts().count {
                    print(true)
                } else {
                    print(false)
                }
            }
            
            Button("Delete all historical workouts") {
                viewModel.dataDelegate.deleteAllHistoricalWorkouts()
            }
        }
    }
    
    @Observable
    @MainActor final class ViewModel {
        let dataDelegate: DataDelegate
        let companion: CompanionProtocol
        var templateWorkouts: [Workout] { dataDelegate.templateWorkouts }
        var selectedWorkout: Workout?
        var lastAddedExercise: Exercise? {
            selectedWorkout?.exercises.last
        }
        
        init(dataDelegate: DataDelegate, companion: CompanionProtocol) {
            self.dataDelegate = dataDelegate
            self.companion = companion
            self.selectedWorkout = templateWorkouts.first
            
        }
        
        func add(_ workout: Workout) {
            if templateWorkouts.isEmpty { selectedWorkout = workout }
            assert(selectedWorkout != nil, "selectedWorkout still nil after adding workout.")
            dataDelegate.addTemplateWorkout(workout)
            companion.addTemplateWorkout(workout)
        }
        
        func createWorkout() {
            add(Workout(name: "Test workout", exercises: [
                Exercise(name: "Bench Press", sets: 3, reps: 12, weight: Weight(100, in: .kilograms)),
                Exercise(name: "Chest Press", sets: 3, reps: 12, weight: Weight(100, in: .kilograms)),
                Exercise(name: "Leg Press", sets: 3, reps: 12, weight: Weight(100, in: .kilograms))
            ]))
        }
        
        func delete(_ workout: Workout) {
            if let selectedWorkout, selectedWorkout == workout {
                var foundReplacement: Bool = false // If a replacement workout is not found, selectedWorkout gets set nil
                for templateWorkout in templateWorkouts {
//                    assert(templateWorkout.id != workout.id, "Workout that was supposed to be deleted is still present in persistent storage.")
                    if templateWorkout.id != workout.id {
                        self.selectedWorkout = templateWorkout
                        foundReplacement = true
                        break
                    }
                }
                if !foundReplacement {
                    self.selectedWorkout = nil
                }
            }
            // The workout needs to be removed first to prevent stale reference
            companion.deleteTemplateWorkout(workout)
            dataDelegate.deleteTemplateWorkout(workout)
        }
        
        func deleteAllTemplates() {
            selectedWorkout = nil
            dataDelegate.deleteAllTemplateWorkouts()
            companion.deleteAllTemplateWorkouts()
        }
        
        func setSelectedWorkout(_ workout: Workout) {
            selectedWorkout = workout
        }
        
        func add(_ exercise: Exercise) {
            guard let selectedWorkout else {
                assertionFailure("When called, this method should not have a nil selectedWorkout.")
                return
            }
            selectedWorkout.add(exercise)
        }
        
        func createNewExercise() {
            guard selectedWorkout != nil else {
                assertionFailure("When called, this method should not have a nil selectedWorkout.")
                return
            }
            add(Exercise(name: "", sets: defaultSetCount, reps: defaultRepCount, weight: Weight(defaultWeightValue, in: .kilograms)))
        }
    }
}
