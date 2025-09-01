//
//  ExerciseGridItem.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/28/25.
//

import SwiftUI

struct PlanGridExerciseItem: View {
    let exercise: Exercise
    
    @State var isEditing: Bool = false
    @State var editMode: EditMode = .none
    @State var isTapped: Bool = false
    let cornerRadius: CGFloat = 30
    
    let doneEditingAction: (() -> Void)?
    
    enum EditMode {
        case none
        case sets
        case reps
        case kilogramsWeight
        case poundsWeight
    }
    
    init(_ exercise: Exercise, onDoneEditing doneEditingAction: (() -> Void)? = nil) {
        self.exercise = exercise
        self.doneEditingAction = doneEditingAction
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if isEditing {
                    @Bindable var exercise = exercise
                    TextField("Name", text: $exercise.name)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fontDesign(.rounded)
                        .padding(.vertical, 2) // give some padding so the background isn’t tight
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.18)) // your background color
                        )
                        
                        
                } else {
                    if exercise.name == "" {
                        Text("blank")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(2)
                            .minimumScaleFactor(0.2)
                            .layoutPriority(1)
                            .fontDesign(.rounded)
                            .italic()
                    } else {
                        Text(exercise.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.2)
                            .layoutPriority(1)
                            .fontDesign(.rounded)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                Button {
                    // Animate shrink
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        isTapped = true
                    }
                    // Return to normal after short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                            isTapped = false
                        }
                    }
                    
                    // Your button action here
                    toggleEditing()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.blue)
                        
                        Image(systemName: isEditing ? "checkmark" : "slider.vertical.3")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 30, height: 30)
                .containerShape(.circle)
                .contentShape(.containerRelative)
                .clipShape(.circle)
                .scaleEffect(isTapped ? 0.9 : 1.0) // <-- shrink when tapped
            }
            
            Divider().background(Color.white)
            Spacer()
            
            if isEditing {
                exerciseDetailEditor
            } else {
                exerciseDetails
            }
                
        }
//        .border(.red)
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.exerciseCardBG)
        .contentShape(.containerRelative)
        .containerShape(.rect(cornerRadius: cornerRadius))
        .aspectRatio(1, contentMode: .fit)
    }
    
    @ViewBuilder
    var exerciseDetails: some View {
        let columns = [
            GridItem(.fixed(65), alignment: .trailing), // value column
            GridItem(.fixed(1)),                         // divider line
            GridItem(.flexible(), alignment: .leading)   // label column
        ]

        LazyVGrid(columns: columns, spacing: 8) {
            Text("\(exercise.setsPlanned)")
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.3))
                .frame(width: 2)
            Text("sets")
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.set)
            
            Text("\(exercise.setDetails[0].repsPlanned)")
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.3))
                .frame(width: 2)
            Text("reps")
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.rep)
            
            Text("\(exercise.setDetails[0].weightPlanned.description)")
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.3))
                .frame(width: 2)
            Text("weight")
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.weight)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
        }
        .font(.body)
        .foregroundColor(.white)
    }
    
    var exerciseDetailEditor: some View {
        HStack(alignment: .center, spacing: 0) {
            switch editMode {
            case .reps:
                Picker(
                    "Reps",
                    selection: Binding(
                        get: { exercise.setDetails[0].repsPlanned},
                        set: { newValue in
                            for i in exercise.setDetails.indices {
                                exercise.setDetails[i].repsPlanned = newValue
                            }
                        }
                    )
                ) {
                    ForEach(Array(stride(from: minRepCount, through: maxRepCount, by: 1)), id: \.self) { value in
                        Text(String(value)).tag(value).frame(width: 40)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)
                .frame(maxHeight: .infinity)
            case .sets:
                Picker(
                    "Sets",
                    selection: Binding(
                        get: { exercise.setsPlanned},
                        set: { newValue in
                            exercise.setsPlanned = newValue
                        }
                    )
                ) {
                    ForEach(Array(stride(from: minSetCount, through: maxSetCount, by: 1)), id: \.self) { value in
                        Text(String(value)).tag(value).frame(width: 40)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)
                .frame(maxHeight: .infinity)
                
            case .kilogramsWeight, .poundsWeight:
                Picker(
                    "Weight",
                    selection: Binding(
                        get: { exercise.setDetails[0].weightPlanned.value},
                        set: { newValue in
                            print("\(editMode == .kilogramsWeight ? "kg" : "lbs"): \(newValue)")
                            for i in exercise.setDetails.indices {
                                exercise.setDetails[i].weightPlanned = Weight(newValue, in: editMode == .kilogramsWeight ? .kilograms : .pounds)
                            }
                        }
                    )
                ) {
                    ForEach(Array(stride(from: minWeightValue, through: maxWeightValue, by: 0.5)), id: \.self) { value in
                        Text(value.oneDPString).tag(value).frame(width: 40)
                            .minimumScaleFactor(0.2)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)
                .frame(maxHeight: .infinity)
            case .none:
                EmptyView()
            }
            
            Picker("Mode", selection: $editMode) {
                    Text("Sets")
                        .tag(EditMode.sets)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.set)
                    Text("Reps")
                        .tag(EditMode.reps)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.rep)
                
                Text("kg")
                    .tag(EditMode.kilogramsWeight)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color.weight)
                Text("lbs")
                    .tag(EditMode.poundsWeight)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color.weight)
                
                }
            .pickerStyle(.wheel)
        }
        .frame(maxWidth: .infinity)
        .onChange(of: editMode) {
            if editMode == .kilogramsWeight {
                for i in exercise.setDetails.indices {
                    exercise.setDetails[i].weightPlanned.unit = .kilograms
                }
            } else if editMode == .poundsWeight {
                for i in exercise.setDetails.indices {
                    exercise.setDetails[i].weightPlanned.unit = .pounds
                }
            }
        }
    }
}

// MARK: - VIEW LOGIC
extension PlanGridExerciseItem {
    func toggleEditing() {
        withAnimation(.easeInOut(duration: 0.15)) {
            if isEditing {
                // Transitioning from editing to done
                isEditing = false
                doneEditingAction?()
            } else {
                // Transitioning into an editing state
                isEditing = true
                editMode = .sets
            }
        }
    }
}

#Preview {
    NavigationStack {
        let exercises = [
            Exercise(name: "Bench Press", sets: 3, reps: 12, weight: Weight(35, in: .kilograms)),
            Exercise(name: "Squat", sets: 3, reps: 10, weight: Weight(70, in: .kilograms)),
            Exercise(name: "Bicep Curl", sets: 3, reps: 14, weight: Weight(35, in: .pounds)),
            Exercise(name: "Leg Curl", sets: 3, reps: 12, weight: Weight(40, in: .kilograms)),
            Exercise(name: "Abdominal Crunch", sets: 3, reps: 12, weight: Weight(55, in: .kilograms)),
        ]
        
        let spacing = CGFloat(16)
        let columns = [
            GridItem(.flexible(), spacing: spacing), // 2 equal-width columns
            GridItem(.flexible(), spacing: spacing)
        ]
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(exercises.indices, id: \.self) { i in
                    PlanGridExerciseItem(exercises[i])
                }
                
                ZStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white, .quaternary)
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(ShrinkingCircleButtonStyle())
                    .contentShape(.containerRelative)
                    .containerShape(.circle)
                    .padding()
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.clear)
                .contentShape(.containerRelative)
                .containerShape(.rect(cornerRadius: 30))
                .aspectRatio(1, contentMode: .fit)
            }
            .padding()
        }
        .navigationTitle("Plan")
    }
    .preferredColorScheme(.dark)
}

struct ShrinkingCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0) // shrink on press
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
