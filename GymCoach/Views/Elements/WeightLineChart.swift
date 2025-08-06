import SwiftUI
import Charts

struct WeightDataPoint: Identifiable {
    let id: Int
    let setIndex: Int
    let weight: Double
}

struct WeightLineChart: View {
    let weights: [Double]
    let maxY: Double
    let minY: Double
    let chartHeight: CGFloat
    let chartWidth: CGFloat
    let horizontalLineCount: Int = 4 // Number of horizontal lines (including min and max)
    
    var data: [WeightDataPoint] {
        let limitedWeights = weights.suffix(10)
        return limitedWeights.enumerated().map { WeightDataPoint(id: $0.offset, setIndex: $0.offset, weight: $0.element) }
    }
    
    init(weights: [Double], width: CGFloat, height: CGFloat) {
        // Only keep the 10 or fewer most recent values
        self.weights = Array(weights.suffix(10))
        self.maxY = self.weights.max() ?? 1
        self.minY = self.weights.min() ?? 0
        self.chartWidth = width
        self.chartHeight = height
    }
    
    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Set", point.setIndex),
                y: .value("Weight", point.weight)
            )
            .interpolationMethod(.linear)
            .foregroundStyle(.blue)
            PointMark(
                x: .value("Set", point.setIndex),
                y: .value("Weight", point.weight)
            )
            .symbol(Circle())
            .symbolSize(40)
            .foregroundStyle(.blue)
        }
        .chartYScale(domain: minY...maxY)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: horizontalLineCount)) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(width: chartWidth, height: chartHeight)
    }
}

#Preview {
    WeightLineChart(weights: [10, 20, 15, 25, 30, 28], width: 120, height: 60)
}
