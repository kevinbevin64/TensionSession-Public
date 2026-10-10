//
//  GenericRepCounter2.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/25/26.
//

import Foundation

public extension RepDetector {

    struct GenericRepCounter2: RepCounter {

        private struct Peak {
            let time: TimeInterval
            let value: Double
        }

        // Frequencies are in hertz. Durations are in seconds.
        // Amplitudes are fractions of the set's own motion.
        private enum Repetition {
            static let highPass = 0.25
            static let lowPass = 5.0
            static let minimumInterval: TimeInterval = 0.40
            static let amplitudeFloor = 0.10
            static let amplitudeFraction = 0.40
            static let amplitudePercentile = 0.75
            static let scalePercentile = 0.95
        }

        public init() {}

        public func getRepCount(in samples: [MotionSample]) -> Int {

            guard samples.count > 2, let sampleRate = sampleRate(of: samples) else {
                return 0
            }

            // 1. Keep the axis that actually moved.
            let axis = dominantAxis(of: samples)

            // 2. Band-pass the acceleration. Reps sit between a slow drift and sensor shake.
            let filtered = bandPass(axis, sampleRate: sampleRate)

            // 3. Integrate to velocity. The push at the start of a rep and the stop
            //    on the way back are two acceleration peaks, but one rise and fall of speed.
            let velocity = highPass(
                integrate(filtered, sampleRate: sampleRate),
                sampleRate: sampleRate
            )

            // 4. Point the signal so each rep is a positive peak, scaled to this set.
            let oriented = unitScaled(orientedUpward(velocity))

            // 5. Keep peaks that clear an adaptive height, one per rep.
            let peaks = localMaxima(in: oriented, times: samples.map(\.timestamp))
            let threshold = amplitudeThreshold(for: peaks.map(\.value))
            let tallEnough = peaks.filter { $0.value >= threshold }

            return separatedPeaks(tallEnough, minimumInterval: Repetition.minimumInterval).count
        }

        private func sampleRate(of samples: [MotionSample]) -> Double? {

            let intervals = zip(samples, samples.dropFirst()).compactMap { previous, next in
                let interval = next.timestamp - previous.timestamp
                return interval > 0 ? interval : nil
            }

            guard intervals.isEmpty == false else { return nil }

            let median = intervals.sorted()[intervals.count / 2]
            let rate = 1 / median
            guard rate > 5, rate < 200 else { return nil }
            return rate
        }

        private func dominantAxis(of samples: [MotionSample]) -> [Double] {

            let axes = [
                samples.map(\.x),
                samples.map(\.y),
                samples.map(\.z)
            ]

            return axes.max { variance(of: $0) < variance(of: $1) } ?? axes[0]
        }

        private func variance(of values: [Double]) -> Double {

            guard values.isEmpty == false else { return 0 }

            let mean = values.reduce(0, +) / Double(values.count)
            let squareSum = values.reduce(0) { sum, value in
                let delta = value - mean
                return sum + delta * delta
            }
            return squareSum / Double(values.count)
        }

        private func integrate(_ values: [Double], sampleRate: Double) -> [Double] {

            let step = 1 / sampleRate
            var sum = 0.0

            return values.map { value in
                sum += value * step
                return sum
            }
        }

        private func highPass(_ values: [Double], sampleRate: Double) -> [Double] {

            var forward = applyHighPass(values, sampleRate: sampleRate)
            forward.reverse()
            var backward = applyHighPass(forward, sampleRate: sampleRate)
            backward.reverse()
            return backward
        }

        private func applyHighPass(_ values: [Double], sampleRate: Double) -> [Double] {

            var filter = Biquad.highPass(
                cutoff: Repetition.highPass,
                sampleRate: sampleRate
            )

            var output: [Double] = []
            output.reserveCapacity(values.count)

            for value in values {
                output.append(filter.process(value))
            }

            return output
        }

        private func bandPass(_ values: [Double], sampleRate: Double) -> [Double] {

            var forward = butterworth(values, sampleRate: sampleRate)
            forward.reverse()
            var backward = butterworth(forward, sampleRate: sampleRate)
            backward.reverse()
            return backward
        }

        private func butterworth(_ values: [Double], sampleRate: Double) -> [Double] {

            var highPass = Biquad.highPass(
                cutoff: Repetition.highPass,
                sampleRate: sampleRate
            )
            var lowPass = Biquad.lowPass(
                cutoff: Repetition.lowPass,
                sampleRate: sampleRate
            )

            var output: [Double] = []
            output.reserveCapacity(values.count)

            for value in values {
                output.append(lowPass.process(highPass.process(value)))
            }

            return output
        }

        private func unitScaled(_ values: [Double]) -> [Double] {

            let magnitudes = values.map(abs).sorted()
            guard magnitudes.isEmpty == false else { return values }

            let index = Int(Repetition.scalePercentile * Double(magnitudes.count - 1))
            let scale = magnitudes[index]
            guard scale > 0 else { return values }

            return values.map { $0 / scale }
        }

        private func orientedUpward(_ values: [Double]) -> [Double] {

            guard let peak = values.max(), let trough = values.min() else {
                return values
            }

            if abs(trough) > abs(peak) {
                return values.map { -$0 }
            }
            return values
        }

        private func localMaxima(in values: [Double], times: [TimeInterval]) -> [Peak] {

            guard values.count > 2 else { return [] }

            var peaks: [Peak] = []

            for index in 1..<(values.count - 1) {
                let value = values[index]
                if value > values[index - 1], value >= values[index + 1] {
                    peaks.append(Peak(time: times[index], value: value))
                }
            }

            return peaks
        }

        private func amplitudeThreshold(for peakValues: [Double]) -> Double {

            guard peakValues.isEmpty == false else { return Repetition.amplitudeFloor }

            let sorted = peakValues.sorted()
            let position = Repetition.amplitudePercentile * Double(sorted.count - 1)
            let lower = Int(position)
            let upper = min(lower + 1, sorted.count - 1)
            let weight = position - Double(lower)
            let percentile = sorted[lower] * (1 - weight) + sorted[upper] * weight

            return max(Repetition.amplitudeFloor, Repetition.amplitudeFraction * percentile)
        }

        private func separatedPeaks(_ peaks: [Peak], minimumInterval: TimeInterval) -> [Peak] {

            var accepted: [Peak] = []

            for peak in peaks {
                guard let last = accepted.last else {
                    accepted.append(peak)
                    continue
                }

                if peak.time - last.time >= minimumInterval {
                    accepted.append(peak)
                } else if peak.value > last.value {
                    accepted[accepted.count - 1] = peak
                }
            }

            return accepted
        }
    }
}

private struct Biquad {

    private let b0: Double
    private let b1: Double
    private let b2: Double
    private let a1: Double
    private let a2: Double

    private var z1 = 0.0
    private var z2 = 0.0

    static func lowPass(cutoff: Double, sampleRate: Double) -> Biquad {
        coefficients(cutoff: cutoff, sampleRate: sampleRate, lowPass: true)
    }

    static func highPass(cutoff: Double, sampleRate: Double) -> Biquad {
        coefficients(cutoff: cutoff, sampleRate: sampleRate, lowPass: false)
    }

    private static func coefficients(
        cutoff: Double,
        sampleRate: Double,
        lowPass: Bool
    ) -> Biquad {

        let angular = 2 * Double.pi * cutoff / sampleRate
        let cosine = cos(angular)
        let sine = sin(angular)
        let alpha = sine / (2 * (1 / sqrt(2)))
        let a0 = 1 + alpha

        let b0: Double
        let b1: Double
        let b2: Double

        if lowPass {
            b0 = (1 - cosine) / 2
            b1 = 1 - cosine
            b2 = (1 - cosine) / 2
        } else {
            b0 = (1 + cosine) / 2
            b1 = -(1 + cosine)
            b2 = (1 + cosine) / 2
        }

        return Biquad(
            b0: b0 / a0,
            b1: b1 / a0,
            b2: b2 / a0,
            a1: (-2 * cosine) / a0,
            a2: (1 - alpha) / a0
        )
    }

    private init(b0: Double, b1: Double, b2: Double, a1: Double, a2: Double) {
        self.b0 = b0
        self.b1 = b1
        self.b2 = b2
        self.a1 = a1
        self.a2 = a2
    }

    mutating func process(_ input: Double) -> Double {

        let output = b0 * input + z1
        z1 = b1 * input - a1 * output + z2
        z2 = b2 * input - a2 * output
        return output
    }
}
