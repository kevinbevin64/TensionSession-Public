//
//  AnalyzeView.swift
//  GymCoach
//
//  Created by Kevin Chen on 7/23/25.
//

import Foundation
import SwiftUI

struct AnalyzeView: View {
    @Environment(DataDelegate.self) var dataDelegate
    
    @State var viewModel: ViewModel
    
    init(dataDelegate: DataDelegate) {
        self.viewModel = .init(dataDelegate: dataDelegate)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.exerciseWeightsCaches.sorted(by: { $0.name < $1.name }), id: \.id) { cache in
                    NavigationLink(value: cache) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(cache.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                            }
                            Spacer()
                            WeightLineChart(weights: cache.weights.map { $0.value }, width: 120, height: 60)
                        }
                    }
                    .listRowInsets(exerciseAnalyzeCardEdgeInsets)
                    .roundedListItemStyle(cornerRadius: 16, backgroundColor: Color(.systemGray6))
                }
            }
            .roundedListStyle()
            .navigationTitle("Analyze")
            .navigationDestination(for: ExerciseWeightsCache.self) { cache in 
                AnalyzeDetailView(cache: cache)
            }
        }
    }
    
    @Observable
    @MainActor final class ViewModel {
        let dataDelegate: DataDelegate
        var exerciseWeightsCaches: [ExerciseWeightsCache] { dataDelegate.exerciseWeightsCaches }
        var orderMethod: SortOrder = .forward
        
        init(dataDelegate: DataDelegate) {
            self.dataDelegate = dataDelegate
        }
        
        func toggleOrderMethod() {
            orderMethod = orderMethod == .reverse ? .forward : .reverse
        }
    }
}
