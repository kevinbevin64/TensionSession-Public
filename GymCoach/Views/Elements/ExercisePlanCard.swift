//
//  ExercisePlanCard.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/29/25.
//

import SwiftUI

struct ExercisePlanCard: View {
    let exercise: Exercise
    let weightPreference: UserInfo.WeightPreference
    @State var editedValue: EditedValue = .absent
    
    init(_ exercise: Exercise, weightPreference: UserInfo.WeightPreference) {
        self.exercise = exercise
        self.weightPreference = weightPreference
    }
    
    var body: some View {
        VStack {
            exerciseName
            
            HStack(alignment: .bottom) {
                Spacer()
                setDisplay
                Spacer()
                repDisplay
                Spacer()
                weightDisplay
                Spacer()
            }
        }
    }
    
    var exerciseName: some View {
        @Bindable var exercise = exercise
        return TextField("Exercise name", text: $exercise.name)
            .font(.largeTitle)
            .fontWeight(.semibold)
    }
    
    enum EditedValue {
        case set
        case rep
        case weight
        case absent
    }
    
    var setDisplay: some View {
        VStack(spacing: textPickerSpacing) {
            Text("Sets")
            
            if editedValue == .set {
                // Editing the set count
                Picker("Sets", selection: Binding(
                        get: { exercise.setsPlanned },
                        set: { exercise.setsPlanned = $0 }
                )) {
                    ForEach(minSetCount...maxSetCount, id: \.self) { setCount in
                        Text("\(setCount)").tag(setCount)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: pickerWidth, height: pickerHeight)
            } else {
                // Not editing the set count
                TitledRoundedRectangle(title: "\(exercise.setsPlanned)", cornerRadius: 14)
                    .frame(width: pickerWidth, height: pickerHeight)
            }
        }
        .onTapGesture {
            print("Toggling the visibility of the setDisplay")
            if editedValue == .set {
                editedValue = .absent
            } else {
                editedValue = .set
            }
        }
    }
    
    var repDisplay: some View {
        VStack(spacing: textPickerSpacing) {
            Text("Reps")
            
            if editedValue == .rep {
                // Editing the rep count
                Picker("Reps", selection: Binding(
                        get: { exercise.setDetails[0].repsPlanned },
                        set: { exercise.setDetails[0].repsPlanned = $0 }
                )) {
                    ForEach(minRepCount...maxRepCount, id: \.self) { repCount in
                        Text("\(repCount)").tag(repCount)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: pickerWidth, height: pickerHeight)
            } else {
                // Not editing the set count
                TitledRoundedRectangle(title: "\(exercise.setDetails[0].repsPlanned)", cornerRadius: 14)
                    .frame(width: pickerWidth, height: pickerHeight)
            }
        }
        .onTapGesture {
            print("Toggling the visibility of the repDisplay")
            if editedValue == .rep {
                editedValue = .absent
            } else {
                editedValue = .rep
            }
        }
    }
    
    var weightDisplay: some View {
        VStack(spacing: textPickerSpacing) {
            Text("Weight")
            
            if editedValue == .weight {
                // Editing the rep count
                Picker("Weight", selection: Binding(
                        get: { exercise.setDetails[0].weightPlanned.value },
                        set: { exercise.setDetails[0].weightPlanned.value = $0 }
                )) {
                    ForEach(Array(stride(from: minWeightValue, to: maxWeightValue, by: 0.5)), id: \.self) { weightValue in
                        Text(weightValue.oneDPString).tag(weightValue)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: pickerWidth, height: pickerHeight)
            } else {
                // Not editing the set count
                TitledRoundedRectangle(title: exercise.setDetails[0].weightPlanned.value.oneDPString, cornerRadius: 14)
                    .frame(width: pickerWidth, height: pickerHeight)
            }
        }
        .onTapGesture {
            print("Toggling the visibility of the weightDisplay")
            if editedValue == .weight {
                editedValue = .absent
            } else {
                editedValue = .weight
            }
        }
    }
}
