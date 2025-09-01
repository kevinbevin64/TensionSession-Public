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
                ForEach(viewModel.exerciseNames, id: \.self) { name in
                    NavigationLink(value: name) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                            }
                            Spacer()
                            WeightLineChart(
                                weights: viewModel.chartValues(for: name),
                                width: 120,
                                height: 60
                            )
                        }
                    }
                    .listRowInsets(exerciseAnalyzeCardEdgeInsets)
                    .roundedListItemStyle(cornerRadius: 16, backgroundColor: Color(.systemGray6))
                }
            }
            .roundedListStyle()
            .navigationTitle("Analyze")
            .navigationDestination(for: String.self) { exerciseName in
                AnalyzeDetailView(
                    exerciseName: exerciseName,
                    workoutDataAnalyzer: viewModel.workoutDataAnalyzer,
                    dataDelegate: dataDelegate
                )
            }
        }
        .onAppear { viewModel.refresh() }
        .onChange(of: dataDelegate.historicalWorkouts.map { $0.id }) { _ in viewModel.refresh() }
    }
    
    @Observable
    @MainActor final class ViewModel {
        let dataDelegate: DataDelegate
        let workoutDataAnalyzer: WorkoutDataAnalyzer
        var orderMethod: SortOrder = .forward
        
        init(dataDelegate: DataDelegate) {
            self.dataDelegate = dataDelegate
            let analyzer = WorkoutDataAnalyzer(dataDelate: dataDelegate)
            analyzer.gatherData()
            self.workoutDataAnalyzer = analyzer
        }
        
        var exerciseNames: [String] {
            workoutDataAnalyzer.exerciseData.keys.sorted(by: <)
        }
        
        func chartValues(for exerciseName: String) -> [Double] {
            guard let weights = workoutDataAnalyzer.exerciseData[exerciseName] else { return [] }
            let unit = dataDelegate.userInfo.weightPreference.weightUnit
            return weights.map { $0.converted(to: unitMassEquivalent(of: unit)).value }
        }
        
        func refresh() {
            workoutDataAnalyzer.exerciseData.removeAll()
            workoutDataAnalyzer.gatherData()
        }
        
        func toggleOrderMethod() {
            orderMethod = orderMethod == .reverse ? .forward : .reverse
        }
    }
}
