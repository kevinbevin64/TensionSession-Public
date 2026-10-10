//
//  RepDetector.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/24/26.
//

import CoreMotion

public final class RepDetector {

    private let motionManager = CMMotionManager()

    private var samples: [MotionSample] = []
    
    private let setReps: (Int) -> Void
    
    private let counter: any RepCounter

    public init?(
        counter: any RepCounter = GenericRepCounter(),
        setReps: @escaping (Int) -> Void
    ) {
        
        if !RepDetector.isSupported {
            return nil
        }
        
        self.counter = counter
        self.setReps = setReps
    }

    public func start() {

        motionManager.deviceMotionUpdateInterval = Duration.milliseconds(20).timeInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            
            if let motion {
                
                let acceleration = motion.userAcceleration
                
                self?.samples.append(
                    MotionSample(
                        timestamp: motion.timestamp,
                        x: acceleration.x,
                        y: acceleration.y,
                        z: acceleration.z
                    )
                )
            }
        }
    }

    public func stop() {
        
        motionManager.stopDeviceMotionUpdates()
        samples.removeAll()
    }

    public func endAndReset() {
        
        motionManager.stopDeviceMotionUpdates()
        let reps = counter.getRepCount(in: samples)
        setReps(reps)
        samples.removeAll()
    }
}
