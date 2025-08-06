//
//  GymCoachTests.swift
//  GymCoachTests
//
//  Created by Kevin Chen on 7/18/25.
//

import Testing
import SwiftData
@testable import GymCoach

@MainActor struct DataDelegateTests {
    @Test
    func testAddTemplateWorkout() {
        let dataDelegate = makeDataDelegate()
        let newTemplate = Workout(name: "NewTemplate") // Defaults to template
        dataDelegate.addTemplateWorkout(newTemplate)
        #expect(dataDelegate.templateWorkouts.count == 1)
        #expect(dataDelegate.fetchTemplateWorkouts().count == 1)
        #expect(dataDelegate.historicalWorkouts.count == 0)
        #expect(dataDelegate.fetchHistoricalWorkouts().count == 0)
    }
    
    @Test
    func testAddHistoricalWorkout() {
        let dataDelegate = makeDataDelegate()
        let newHistorical = Workout(name: "NewHistorical", isTemplate: false)
        dataDelegate.addHistoricalWorkout(newHistorical)
        #expect(dataDelegate.templateWorkouts.count == 0)
        #expect(dataDelegate.fetchTemplateWorkouts().count == 0)
        #expect(dataDelegate.historicalWorkouts.count == 1)
        #expect(dataDelegate.fetchHistoricalWorkouts().count == 1)
    }
    
    @Test
    func testDeleteTemplateWorkout() {
        let dataDelegate = makeDataDelegate()
        let template1 = Workout(name: "Template1")
        let template2 = Workout(name: "Template2")
        dataDelegate.addTemplateWorkout(template1)
        dataDelegate.addTemplateWorkout(template2)
        dataDelegate.deleteTemplateWorkout(template1)
        dataDelegate.deleteTemplateWorkout(template2)
        #expect(dataDelegate.templateWorkouts.isEmpty)
        #expect(dataDelegate.fetchTemplateWorkouts().isEmpty)
    }
    
    @Test
    func testDeleteAllTemplateWorkouts() {
        let dataDelegate = makeDataDelegate()
        dataDelegate.addTemplateWorkout(Workout(name: "Test1"))
        dataDelegate.addTemplateWorkout(Workout(name: "Test2"))
        dataDelegate.addTemplateWorkout(Workout(name: "Test3"))
        #expect(dataDelegate.templateWorkouts.count == 3)
        #expect(dataDelegate.fetchTemplateWorkouts().count == 3)
        dataDelegate.deleteAllTemplateWorkouts()
        #expect(dataDelegate.templateWorkouts.isEmpty)
        #expect(dataDelegate.fetchTemplateWorkouts().count == 0)
    }
    
    @Test
    func testUserInfoWeightPreference() {
        let context = makeSampleContext()
        let dataDelegate = makeDataDelegate(context: context)
        
        dataDelegate.userInfo.weightPreference = .pounds
        #expect(dataDelegate.userInfo.weightUnit == .pounds) // Check in-memory value
        #expect(
            {
                let userInfos = try! context.fetch(FetchDescriptor<UserInfo>())
                assert(userInfos.count == 1)
                return userInfos[0].weightUnit
            }() == .pounds as Weight.WeightUnit
        ) // Check in-storage value
        
        dataDelegate.userInfo.weightPreference = .kilograms
        #expect(dataDelegate.userInfo.weightPreference == .kilograms)
        #expect(
            {
                let userInfos = try! context.fetch(FetchDescriptor<UserInfo>())
                assert(userInfos.count == 1)
                return userInfos[0].weightUnit
            }() == .kilograms as Weight.WeightUnit
        )
    }
    
    @Test
    func testExerciseWeightsCache() {
        let context = makeSampleContext()
        let dataDelegate = makeDataDelegate(context: context)
        
        // Store the cache in the persistent store
        dataDelegate.addExerciseWeightsCache(
            ExerciseWeightsCache(
                name: "Bench Press",
                weights: [
                    Weight(100, in: .kilograms),
                    Weight(115, in: .kilograms),
                    Weight(125, in: .kilograms),
                    Weight(120, in: .kilograms),
                    Weight(130, in: .kilograms),
                ]
            )
        )
        
        // Verify that the ExerciseWeightsCache exists in the in-memory array
        #expect(dataDelegate.exerciseWeightsCaches.contains { $0.name == "Bench Press" },
                "ExerciseWeightsCache not found in memory")
        
        print("\(dataDelegate.fetchExerciseWeightsCaches().count)")
        
        // Verify that the instance also exists in the persistent store
        #expect(dataDelegate.fetchExerciseWeightsCaches().count == 1,
                "ExerciseWeightsCache not found in the persistent store.")
        
    }
}

@MainActor struct RecordViewModelTests {
    @Test
    func testCompletedWorkoutSession() {
        // Tests that a workout moves from template to historical.
        let dataDelegate = makeDataDelegate()
        let template = Workout(name: "Test")
        dataDelegate.addTemplateWorkout(template)
        
        let viewModel = RecordView.ViewModel(dataDelegate: dataDelegate)
        #expect(dataDelegate.historicalWorkouts.count == 0)
        viewModel.startWorkout()
        #expect(template != viewModel.selectedWorkout!)
        viewModel.endWorkout()
        #expect(viewModel.templateWorkouts.count == 1)
        #expect(dataDelegate.historicalWorkouts.count == 1)
    }
}

@MainActor struct PlanViewModelTests {
    @Test
    func testAddWorkout() throws {
        let viewModel = PlanView.ViewModel(dataDelegate: makeDataDelegate(), companion: MockCompanion())
        
        // Add the new workout
        let newWorkout = Workout(name: "Test")
        viewModel.add(newWorkout)
        
        // Verify that the selectedWorkout was correctly set
        let workout = try #require(viewModel.selectedWorkout)
        #expect(workout == newWorkout)
        
        // Verify that the number of workouts is correct
        #expect(viewModel.templateWorkouts.count == 1)
        viewModel.add(Workout(name: "Test"))
        #expect(workout == newWorkout)
        #expect(viewModel.templateWorkouts.count == 2)
    }
    
    @Test
    func testDeleteWorkout() throws {
        let viewModel = PlanView.ViewModel(dataDelegate: makeDataDelegate(), companion: MockCompanion())
        let workout1 = Workout(name: "Test1")
        let workout2 = Workout(name: "Test2")
        viewModel.add(workout1)
        viewModel.add(workout2)
        
        // Verify the size of templateWorkouts and that the selectedWorkout is correct
        #expect(viewModel.selectedWorkout == workout1)
        #expect(viewModel.templateWorkouts.count == 2)
        viewModel.delete(workout1)
        #expect(viewModel.selectedWorkout == workout2)
        #expect(viewModel.templateWorkouts.count == 1)
        viewModel.delete(workout2)
        #expect(viewModel.selectedWorkout == nil)
        #expect(viewModel.templateWorkouts.count == 0)
    }
    
    @Test
    func testDeleteAllTemplates() {
        let viewModel = PlanView.ViewModel(dataDelegate: makeDataDelegate(), companion: MockCompanion())
        let workout1 = Workout(name: "Test1")
        let workout2 = Workout(name: "Test2")
        viewModel.add(workout1)
        viewModel.add(workout2)
        #expect(viewModel.templateWorkouts.count == 2)
        viewModel.deleteAllTemplates()
        #expect(viewModel.templateWorkouts.count == 0)
    }
    
    @Test
    func testAddExercise() throws {
        let viewModel = PlanView.ViewModel(dataDelegate: makeDataDelegate(), companion: MockCompanion())
        let workout = Workout(name: "Test")
        viewModel.add(workout)
        let selectedWorkout = try #require(viewModel.selectedWorkout)
        
        #expect(selectedWorkout.exercises.isEmpty)
        selectedWorkout.add(Exercise(name: "Test", sets: 3, reps: 12, weight: Weight(10, in: .kilograms)))
        #expect(selectedWorkout.exercises.count == 1)
    }
}

@MainActor struct AnalyzeViewModelTests {
    @Test
    func testToggleOrderMethod() {
        let dataDelegate = makeDataDelegate()
        let viewModel = AnalyzeView.ViewModel(dataDelegate: dataDelegate)
        #expect(viewModel.orderMethod == .forward)
        viewModel.toggleOrderMethod()
        #expect(viewModel.orderMethod == .reverse)
        viewModel.toggleOrderMethod()
        #expect(viewModel.orderMethod == .forward)
    }
}

@MainActor
func makeDataDelegate(context: ModelContext? = nil) -> DataDelegate {
    if let context {
        return DataDelegate(context: context)
    } else {
        return DataDelegate(context: makeSampleContext())
    }
}

@MainActor 
func makeSampleContext() -> ModelContext {
    let container = try! ModelContainer(
        for: Workout.self, Exercise.self, SyncInstruction.self, UserInfo.self, ExerciseWeightsCache.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return ModelContext(container)
}
