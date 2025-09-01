//
//  ExerciseRecordGridItem.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/28/25.
//

import SwiftUI

struct RecordGridExerciseItem: View {
    let exercise: Exercise
    
    let cornerRadius: CGFloat = 30
    
    
    init(_ exercise: Exercise) {
        self.exercise = exercise
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(exercise.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.2)
                    .layoutPriority(1)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Completion ring
                LabeledCircularProgressView(value: exercise.setsDone, total: exercise.setsPlanned) {
                    if exercise.setsDone < exercise.setsPlanned {
                        Text("\(exercise.setsDone)")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    } else {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
            }
            
            Divider().background(Color.white)
            Spacer()
            
            exerciseDetails
                
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
}


//#Preview {
//    NavigationStack {
//        let exercises = [
//            Exercise(name: "Bench Press", sets: 3, reps: 12, weight: Weight(35, in: .kilograms)),
//            Exercise(name: "Squat", sets: 3, reps: 10, weight: Weight(70, in: .kilograms)),
//            Exercise(name: "Bicep Curl", sets: 3, reps: 14, weight: Weight(35, in: .pounds)),
//            Exercise(name: "Leg Curl", sets: 3, reps: 12, weight: Weight(40, in: .kilograms)),
//            Exercise(name: "Abdominal Crunch", sets: 3, reps: 12, weight: Weight(55, in: .kilograms)),
//        ]
//        
//        let spacing = CGFloat(16)
//        let columns = [
//            GridItem(.flexible(), spacing: spacing), // 2 equal-width columns
//            GridItem(.flexible(), spacing: spacing)
//        ]
//        
//        ScrollView {
//            LazyVGrid(columns: columns, spacing: 16) {
//                ForEach(exercises.indices, id: \.self) { i in
//                    PlanGridExerciseItem(exercises[i])
//                }
//                
//                ZStack {
//                    Button {
//                        
//                    } label: {
//                        Image(systemName: "plus.circle.fill")
//                            .resizable()
//                            .symbolRenderingMode(.hierarchical)
//                            .foregroundStyle(.white, .quaternary)
//                            .scaledToFit()
//                            .frame(width: 50, height: 50)
//                    }
//                    .buttonStyle(ShrinkingCircleButtonStyle())
//                    .contentShape(.containerRelative)
//                    .containerShape(.circle)
//                    .padding()
//                }
//                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                .background(.clear)
//                .contentShape(.containerRelative)
//                .containerShape(.rect(cornerRadius: 30))
//                .aspectRatio(1, contentMode: .fit)
//            }
//            .padding()
//        }
//        .navigationTitle("Plan")
//    }
//    .preferredColorScheme(.dark)
//}

//struct ShrinkingCircleButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.8 : 1.0) // shrink on press
//            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
//    }
//}
