//
//  WorkoutSeletor.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/23/25.
//

import Foundation
import SwiftUI

struct WorkoutSelector: View {
    @Binding var selection: Workout?
    var workoutTemplates: [Workout]
    var onCreateWorkoutTapped: (() -> Void)?
    var onDeleteWorkoutTapped: (() -> Void)?

    init(
        selection: Binding<Workout?>,
        options workoutTemplates: [Workout],
        onCreateWorkoutTapped: (() -> Void)? = nil,
        onDeleteWorkoutTapped: (() -> Void)? = nil
    ) {
        self._selection = selection
        self.workoutTemplates = workoutTemplates
        self.onCreateWorkoutTapped = onCreateWorkoutTapped
        self.onDeleteWorkoutTapped = onDeleteWorkoutTapped
    }

    var body: some View {
        workoutOptionsMenu
            .foregroundStyle(.white)
    }

    var workoutOptionsMenu: some View {
        Menu {
            // Workout options
            Section("Templates") {
                Picker("Workouts", selection: $selection) {
                    ForEach(workoutTemplates) { workoutTemplate in
                        Text(workoutTemplate.name)
                            .tag(workoutTemplate)
                    }
                }
            }

            // Button to create another template workout
            if let onCreateWorkoutTapped {
                Button("Create template", systemImage: "plus") {
                    onCreateWorkoutTapped()
                }
            }
            
            // Button to remove the currently selected workout
            if let onDeleteWorkoutTapped {
                Button("Delete template", systemImage: "trash.fill", role: .destructive) {
                    onDeleteWorkoutTapped()
                }
            }
        } label: {
            HStack {
                Image(systemName: "chevron.down")
                Text(selection?.name ?? "No templates")
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedWorkout: Workout? = Workout(name: "Test workout 1")
    //    @Previewable @State var selectedWorkout: Workout? = nil
    @Previewable @State var options = [
        Workout(name: "Test workout 1"),
        Workout(name: "Test workout 2"),
        Workout(name: "Test workout 3"),
        Workout(name: "Test workout 4"),
    ]

    ZStack {
        Color.black
            .ignoresSafeArea()

        WorkoutSelector(
            selection: $selectedWorkout,
            options: options,
            onDeleteWorkoutTapped:  {
                options.append(Workout(name: "Test workout \(options.count + 1)"))
            }
        )
    }

}
