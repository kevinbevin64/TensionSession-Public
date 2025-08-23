import SwiftUI

struct AnalyzeDetailView: View {
    let exerciseName: String
    let workoutDataAnalyzer: WorkoutDataAnalyzer
    let dataDelegate: DataDelegate
    
    var body: some View {
        List {
            Section {
                chart
            }
            
            Section("Recent Weights") {
                weightValues
            }
            
            additionalInfo
        }
        .listStyle(.plain)
        .navigationTitle(exerciseName)
    }
    
    var chart: some View {
        WeightLineChart(
            weights: values.map { $0.value },
            width: 320,
            height: 180
        )
        .frame(height: 180)
        .padding(.top)
    }
    
    @ViewBuilder
    var weightValues: some View {
        let reversed = values.reversed()
        ForEach(Array(reversed.enumerated()), id: \.offset) { pair in
            Text(pair.element.description)
                .listRowBackground(
                    Rectangle()
                        .fill(Color(.systemGray6))
                )
                .contentShape(Rectangle())
        }
    }
    
    var values: [Weight] {
        let unit = dataDelegate.userInfo.weightPreference.weightUnit
        return (workoutDataAnalyzer.exerciseData[exerciseName] ?? [])
            .map { $0.convert(to: unitMassEquivalent(of: unit)) }
    }
    
    var additionalInfo: some View {
        Text("Weights are arranged from most to least recent.")
            .font(.caption)
            .multilineTextAlignment(.center)
            .frame(alignment: .center)
    }
}

//#Preview {
//    // Minimal preview with dummy analyzer
//    let container = try! ModelContainer(
//        for: Workout.self, Exercise.self, SyncInstruction.self, UserInfo.self, ExerciseWeightsCache.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    let context = ModelContext(container)
//    let dataDelegate = DataDelegate(context: context)
//    let analyzer = WorkoutDataAnalyzer(dataDelate: dataDelegate)
//    AnalyzeDetailView(exerciseName: "Bench Press", workoutDataAnalyzer: analyzer, dataDelegate: dataDelegate)
//}
