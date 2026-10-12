//
//  WorkoutGenerator.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/10/26.
//

#if os(iOS)
import FoundationModels
import SwiftUI

@Observable
public final class WorkoutGenerator {
    
    public var availability = SystemLanguageModel.default.availability
        
    public private(set) var stage: Stage
    
    private let catalog: Exercise.Catalog
    
    private var activity: Task<Void, Never>?
    
    public init(catalog: Exercise.Catalog) {
        self.stage = .ready
        self.catalog = catalog
    }
    
    public func generate(
        accordingTo description: String
    ) {
        
        assert(availability == .available)
        assert({
            switch stage {
            case .ready: return true
            default: return false
            }
        }())
        assert(activity == nil || activity?.isCancelled == true)

        stage = .active
        
        activity = Task { [weak self] in
            
            guard let self else { return }
            
            defer {
                if Task.isCancelled == false {
                    self.activity = nil
                }
            }
            
            let session = LanguageModelSession(
                model: SystemLanguageModel(),
                instructions: WorkoutGenerator.instructions
            )
            
            do {
                
                let schema = try GenerationSchema(
                    root: self.workoutSchema(),
                    dependencies: []
                )
                let response = try await session.respond(to: description, schema: schema)
                guard Task.isCancelled == false else { return }
                let generatedWorkout = try GeneratedWorkout(response.content)
                let workout = try self.workout(from: generatedWorkout)
                self.stage = .done(workout)
                
            } catch is CancellationError {
                return
            } catch {
                guard Task.isCancelled == false else { return }
                print("Error: \(error.localizedDescription)")
                self.stage = .errored(.generationError)
            }
        }
    }
    
    public func cancel() {
        
        assert({
            switch stage {
            case .active, .done, .errored: return true
            default: return false
            }
        }())
        
        stage = .ready
        activity?.cancel()
    }
    
    private func workoutSchema() -> DynamicGenerationSchema {
        
        let kindNames = catalog.all.map(\.name)
        
        let exercise = DynamicGenerationSchema(
            name: "GeneratedExercise",
            properties: [
                DynamicGenerationSchema.Property(
                    name: "kind",
                    schema: DynamicGenerationSchema(name: "ExerciseKind", anyOf: kindNames)
                ),
                DynamicGenerationSchema.Property(
                    name: "equipment",
                    schema: DynamicGenerationSchema(type: GeneratedEquipment.self)
                ),
                DynamicGenerationSchema.Property(
                    name: "setsPlanned",
                    schema: DynamicGenerationSchema(type: Int.self)
                ),
                DynamicGenerationSchema.Property(
                    name: "repsPlanned",
                    schema: DynamicGenerationSchema(type: Int.self)
                ),
                DynamicGenerationSchema.Property(
                    name: "weightPlanned",
                    schema: DynamicGenerationSchema(type: GeneratedWeight.self)
                )
            ]
        )
        
        return DynamicGenerationSchema(
            name: "GeneratedWorkout",
            properties: [
                DynamicGenerationSchema.Property(
                    name: "name",
                    schema: DynamicGenerationSchema(type: String.self)
                ),
                DynamicGenerationSchema.Property(
                    name: "exercises",
                    schema: DynamicGenerationSchema(
                        arrayOf: exercise,
                        minimumElements: 1,
                        maximumElements: 8
                    )
                ),
                DynamicGenerationSchema.Property(
                    name: "description",
                    description: "A brief description of this workout",
                    schema: DynamicGenerationSchema(type: String.self)
                )
            ]
        )
    }
    
    private func workout(
        from generatedWorkout: GeneratedWorkout
    ) throws -> Workout {
        
        var exercises = [Exercise]()
        
        for (i, generatedExercise) in generatedWorkout.exercises.enumerated() {
            
            do {
                
                let kind = try catalog.existing(trimmedAndNeatened: generatedExercise.kind)
                let equipment: Exercise.Equipment = {
                    switch generatedExercise.equipment {
                    case .barbell: return .barbell
                    case .dumbbell: return .dumbbell
                    case .kettlebell: return .kettlebell
                    case .machine: return .machine
                    case .cable: return .cable
                    case .bodyweight: return .bodyweight
                    }
                }()
                let weight = {
                    let value = Double(generatedExercise.weightPlanned.wholeNumberValue)
                                + Double(generatedExercise.weightPlanned.addHalf ? 0.5 : 0)
                    let unit: Weight.Unit = {
                        switch generatedExercise.weightPlanned.unit {
                        case .kilograms: return .kilograms
                        case .pounds: return .pounds
                        }
                    }()
                    return Weight(value, unit)
                }()
                
                exercises.append(Exercise(
                    id2: UUID(),
                    order: i,
                    kind: kind,
                    equipment: equipment,
                    setsPlanned: generatedExercise.setsPlanned,
                    repsPlanned: generatedExercise.repsPlanned,
                    weightPlanned: weight,
                    setDetails: []
                ))
            } catch {
                throw Error.generationError
            }
        }
        
        return Workout(
            id2: UUID(),
            order: 0,
            name: generatedWorkout.name,
            state: .unstarted,
            startInstant: nil,
            exercises: exercises
        )
    }
}
#endif // os(iOS)
