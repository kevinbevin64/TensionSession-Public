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
    
    init(catalog: Exercise.Catalog) {
        self.stage = .ready
        self.catalog = catalog
    }
    
    public func generate(
        accordingTo description: String
    ) {
        
        assert({
            switch stage {
            case .ready: return true
            default: return false
            }
        }())
        assert(activity == nil || activity?.isCancelled == true)
        
        if case let .unavailable(reason) = availability {
            
            switch reason {
                
            case .deviceNotEligible:
                stage = .errored(.unavailable(.deviceNotEligible))
            case .appleIntelligenceNotEnabled:
                stage = .errored(.unavailable(.appleIntelligenceNotEnabled))
            case .modelNotReady:
                stage = .errored(.unavailable(.modelNotReady))
            @unknown default:
                stage = .errored(.unavailable(.other))
            }
            
            return
        }

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
            
            let response: LanguageModelSession.Response<GeneratedContent>
            do {
                let schema = try GenerationSchema(
                    root: self.workoutSchema(),
                    dependencies: []
                )
                response = try await session.respond(to: description, schema: schema)
                guard Task.isCancelled == false else { return }
            } catch is CancellationError {
                return
            } catch {
                handleSessionResponseError(error)
                return
            }
            
            let generatedWorkout: GeneratedWorkout
            do {
                generatedWorkout = try GeneratedWorkout(response.content)
            } catch {
                let reason = "Failed to decode generated content."
                stage = .errored(.decodingError(reason))
                return
            }
            
            let workout: Workout
            do {
                workout = try self.workout(from: generatedWorkout)
                stage = .done(workout, generatedWorkout.description)
            } catch Error.decodingError(let reason) {
                stage = .errored(.decodingError(reason))
            } catch {
                let reason = """
                    Failed to materialize a workout \
                    from the generated workout for an unknown reason.
                    """
                stage = .errored(.decodingError(reason))
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
    
    private func handleSessionResponseError(_ error: Swift.Error) {
        
        let reason: String
        
        if #available(iOS 27.0, *) {
            
            switch error {
                
            case LanguageModelError.contextSizeExceeded:
                reason = "Generation failed due to excessive context."
                
            case LanguageModelError.guardrailViolation:
                reason = "Generation failed due to a guardrail violation."
                
            case LanguageModelError.rateLimited:
                reason = "Generation failed due to a rate limit."
                
            case LanguageModelError.refusal:
                reason = "Generation failed because the model refused to answer."
                
            case LanguageModelError.timeout:
                reason = "Generation failed due to a timeout."
                
            case LanguageModelError.unsupportedCapability:
                reason = "Generation failed due to an unsupported capability."
                
            case LanguageModelError.unsupportedGenerationGuide:
                reason = "Generation failed due to an unsupported generation guide."
                
            case LanguageModelError.unsupportedLanguageOrLocale:
                reason = "Generation failed due to an unsupported langauge or locale."
                
            case LanguageModelError.unsupportedTranscriptContent:
                reason = "Generation failed due to unsupported transcript content."
                
            case LanguageModelSession.Error.concurrentRequests:
                reason = "Generation failed due to concurrent requests."
                
            case LanguageModelSession.Error.transcriptMutationWhileResponding:
                reason = "Generation failed due to untimely transcript mutation."
                
            case SystemLanguageModel.Error.assetsUnavailable:
                reason = "Generation failed due to unavailable on-device model assets."
                
            default:
                reason = "Generation failed for an unknown reason."
            }
            
        } else {
            
            switch error {
                
            case LanguageModelSession.GenerationError.exceededContextWindowSize:
                reason = "Generation failed due to excessive context."
                
            case LanguageModelSession.GenerationError.guardrailViolation:
                reason = "Generation failed due to excessive context."
                
            case LanguageModelSession.GenerationError.rateLimited:
                reason = "Generation failed due to a rate limit."
                
            case LanguageModelSession.GenerationError.refusal:
                reason = "Generation failed because the model refused to answer."
                
            case LanguageModelSession.GenerationError.unsupportedGuide:
                reason = "Generation failed due to an unsupported generation guide."
                
            case LanguageModelSession.GenerationError.unsupportedLanguageOrLocale:
                reason = "Generation failed due to an unsupported langauge or locale."
                
            case LanguageModelSession.GenerationError.concurrentRequests:
                reason = "Generation failed due to concurrent requests."
                
            case LanguageModelSession.GenerationError.assetsUnavailable:
                reason = "Generation failed due to unavailable on-device model assets."
                
            case LanguageModelSession.GenerationError.decodingFailure:
                reason = "Generation failed due to a decoding failure."
                
            default:
                reason = "Generation failed for an unknown reason."
            }
        }
        
        stage = .errored(.generationError(reason))
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
                    description: """
                        A short description of this workout under 60 characters long. \
                        This is a fragment, **not** a sentence.
                        """,
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
                let reason = """
                    Failed to materialize a workout from the \
                    generated workout due to a missing exercise kind.
                    """
                throw Error.decodingError(reason)
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
