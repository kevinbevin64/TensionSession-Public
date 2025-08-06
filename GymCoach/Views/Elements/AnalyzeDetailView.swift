import SwiftUI

struct AnalyzeDetailView: View {
    let cache: ExerciseWeightsCache
    
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
        .navigationTitle(cache.name)
    }
    
    var chart: some View {
        WeightLineChart(weights: cache.weights.map { $0.value }, width: 320, height: 180)
            .frame(height: 180)
            .padding(.top)
    }
    
    @ViewBuilder
    var weightValues: some View {
        let reversedWeights = cache.weights.reversed()
        ForEach(reversedWeights.indices, id: \.self) { i in
            Text("\(reversedWeights[i])")
                .listRowBackground(
                    Rectangle()
                        .fill(Color(.systemGray6))
                )
                .contentShape(Rectangle())
        }
    }
    
    var additionalInfo: some View {
        Text("Weights are arranged from most to least recent.")
            .font(.caption)
            .multilineTextAlignment(.center)
            .frame(alignment: .center)
    }
}

#Preview {
    let cache = ExerciseWeightsCache(name: "Bench Press", weights: [Weight(10, in: .kilograms), Weight(12.5, in: .kilograms), Weight(15, in: .kilograms)])
    AnalyzeDetailView(cache: cache)
}
