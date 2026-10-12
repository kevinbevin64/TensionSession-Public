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
    
    public init() {}
    
    public func create(
        givenDescription description: String,
        catalog: Exercise.Catalog
    ) async throws -> GeneratedWorkout {
        
        guard availability == .available else {
            throw Error.unavailable
        }
        
        let session = LanguageModelSession(
            model: SystemLanguageModel(),
            instructions: WorkoutGenerator.instructions
        )
        
        do {
            
            let schema = try GenerationSchema(
                root: workoutSchema(kindNames: catalog.all.map(\.name)),
                dependencies: []
            )
            let response = try await session.respond(to: description, schema: schema)
            let generatedWorkout = try GeneratedWorkout(response.content)
            return generatedWorkout
            
        } catch {
            print("Error: \(error.localizedDescription)")
            throw Error.generationError
        }
    }
    
    private func workoutSchema(kindNames: [String]) -> DynamicGenerationSchema {
        
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
}
#endif // os(iOS)
