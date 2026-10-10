//
//  WorkoutManager+Methods.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

import CryptoKit
import Foundation

@MainActor
public extension WorkoutManager {
    
    @discardableResult
    func createNewTemplate(called name: String) -> Workout {
        
        let newTemplate = Workout(
            order: unsortedTemplates.count,
            name: name
        )

        unsortedTemplates.append(newTemplate)

        if templateBuffer.selection == nil {
            templateBuffer.insert(newTemplate)
        }
        
        do {
            try save()
        } catch {
            print("Error: \(error)")
        }
        
        return newTemplate
    }
    
    @discardableResult
    func useBlankTemplate() -> Workout {
        
        let blankTemplate = Workout(order: 0, name: "Blank Workout")
        templateBuffer.insert(blankTemplate)
        return blankTemplate
    }
    
    func deleteTemplate(withId2 id2: UUID) {

        if let selection = templateBuffer.selection,
           selection.id2 == id2 && selection.state == .unstarted
        {
            templateBuffer.clearSelection()
        }

        unsortedTemplates.removeAll { $0.id2 == id2 }
        setTemplateOrder()
    }
    
    func rememberHistoricalWorkout() {
        
        guard let workout = templateBuffer.selection else { return }
        assert(templateBuffer.isReadyToEvictFinishedWorkout)
        
        unsortedHistory.append(workout)
        sortedHistory = unsortedHistory.sorted {
            
            guard let firstInstant = $0.startInstant,
                  let secondInstant = $1.startInstant else {
                assertionFailure()
                return true
            }
            
            return firstInstant > secondInstant
        }
        
        if let freshTemplate = freshTemplate() {
            templateBuffer.insert(freshTemplate)
        } else {
            templateBuffer.clearSelection()
        }
        
        try? save()
    }
    
    func freshTemplate() -> Workout? {
        
        guard let lastUsedId2 else {
            if let first = sortedTemplates.first {
                print(first.id2)
                assert(first.state == .unstarted)
            }
            return sortedTemplates.first
        }
        
        guard let workoutIndex = unsortedTemplates.firstIndex(
            where: { $0.id2 == lastUsedId2 }
        ) else {
            if let first = sortedTemplates.first {
                assert(first.state == .unstarted)
            }
            return sortedTemplates.first
        }
        
        return unsortedTemplates[workoutIndex]
    }
    
    func isTemplateOrderValid() -> Bool {
        
        for (i, template) in sortedTemplates.enumerated() {
            if template.order != i {
                return false
            }
        }
        return true
    }
    
    func setTemplateOrder() {
        
        for (i, template) in sortedTemplates.enumerated() {
            template.order = i
        }
    }
    
    func getTemplateWorkoutsHash() -> TemplateWorkoutsHash {
        
        let dtos = sortedTemplates.map { workout -> Workout.DTO in
            var dto = workout.getDTO()
            dto.unsortedExercises.sort { $0.order < $1.order }
            return dto
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try? encoder.encode(dtos)
        let digest = Data(SHA256.hash(data: data ?? Data()))
        let hash = TemplateWorkoutsHash(digest: digest)
        
        return hash
    }
    
    func add(_ workout: Workout) {
        
        workout.order = unsortedTemplates.count

        unsortedTemplates.append(workout)

        if templateBuffer.selection == nil {
            templateBuffer.insert(workout)
        }
        
        try? save()
    }
}

// MARK: Invoked by Companion

@MainActor
extension WorkoutManager {
    
    func addWorkout(_ workout: Workout) {
        
        workout.order = unsortedTemplates.count

        unsortedTemplates.append(workout)

        if templateBuffer.selection == nil {
            templateBuffer.insert(workout)
        }
        
        try? save()
    }
    
    func editTemplate(accordingTo workout: Workout) {
        
        guard let index = unsortedTemplates.firstIndex(where: {
            $0.id2 == workout.id2
        }) else {
            return
        }
        
        let actualWorkout: Workout = unsortedTemplates[index]
        
        actualWorkout.name = workout.name
        assert(workout.state == .unstarted)
        assert(workout.startInstant == nil)
        actualWorkout.unsortedExercises = workout.unsortedExercises
        
        try? save()
    }
    
    func deleteTemplate(_ workout: Workout) {
        
        let id2 = workout.id2
        
        unsortedTemplates.removeAll { $0.id2 == id2 }
        setTemplateOrder()

        if let selection = templateBuffer.selection,
           selection.id2 == id2 && selection.state == .unstarted
        {
            if let freshTemplate = freshTemplate() {
                templateBuffer.insert(freshTemplate)
            } else {
                templateBuffer.clearSelection()
            }
        }
        
        try? save()
    }
    
    func overwriteTemplates(_ templates: [Workout]) {
        
        print("Overwriting templates with \(templates.count) templates")
        
        
        if let selection = templateBuffer.selection,
           selection.state == .unstarted
        {
            templateBuffer.clearSelection()
        }
        
        unsortedTemplates.removeAll()
        unsortedTemplates.append(contentsOf: templates)
        
        if let freshTemplate = freshTemplate() {
            
            if let selection = templateBuffer.selection {
                
                if selection.state == .unstarted {
                    
                    templateBuffer.insert(freshTemplate)
                }
            } else {
                
                templateBuffer.insert(freshTemplate)
            }
        }
        
        try? save()
    }
}
