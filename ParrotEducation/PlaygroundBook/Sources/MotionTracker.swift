// Copyright (C) 2017 Parrot SA
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of Parrot nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.
//
//  Created by Nicolas CHRISTE, <nicolas.christe@parrot.com>

import UIKit
import CoreMotion
import PlaygroundSupport

protocol MotionTrackerDelegate: class {
    func motionUpdate(lateralAngle: Int, longitudinalAngle: Int, lastEvent: MotionEvent)
    func motionEvent(_ event: MotionEvent)
}

class MotionTracker {

    static let angleTrigLevel = 0.4
    static let angleClearLevel = 0.3
    private let accelerationDetect = 0.6
    private let accelerationTrigLevel = 0.7
    private let accelerationDuration = 0.4

    private var coreMotionManager: CMMotionManager?
    private let operationQueue = OperationQueue()

    private var state = MotionEvent.flat
    private var shakeAcceleration: Double?
    private var shakeTimeStamp: TimeInterval?

    weak var delegate: MotionTrackerDelegate?

    func start() {
        if coreMotionManager == nil {
            coreMotionManager = CMMotionManager()
            coreMotionManager!.startDeviceMotionUpdates(to: operationQueue, withHandler: { deviceMotion, _ in
                if let deviceMotion = deviceMotion {
                    let event = self.getMotionEvent(deviceMotion: deviceMotion)
                    if event != self.state {
                        self.delegate?.motionEvent(event)
                        self.state = event
                    }
                }
            })
        }
    }

    func stop() {
        if let coreMotionManager = coreMotionManager {
            coreMotionManager.stopDeviceMotionUpdates()
        }
        coreMotionManager = nil
    }

    private func getMotionEvent(deviceMotion: CMDeviceMotion) -> MotionEvent {
        var event = state
        let attitude = deviceMotion.attitude
        let acceleration = deviceMotion.userAcceleration.z
        let timestamp = deviceMotion.timestamp
        switch state {
        case .flat:
            if shakeAcceleration == nil && (abs(acceleration) > accelerationDetect) {
                shakeTimeStamp = timestamp
                shakeAcceleration = acceleration
            } else if let shakeAcceleration = shakeAcceleration, abs(acceleration) > abs(shakeAcceleration) {
                self.shakeAcceleration = acceleration
            }
            if let shakeAcceleration = shakeAcceleration {
                if shakeAcceleration  < -accelerationTrigLevel {
                    self.shakeAcceleration = nil
                    event = .shakeUp
                } else if shakeAcceleration > accelerationTrigLevel {
                    self.shakeAcceleration = nil
                    event =  .shakeDown
                } else if timestamp - shakeTimeStamp! > accelerationDuration {
                    self.shakeAcceleration = nil
                }
            } else if attitude.roll > MotionTracker.angleTrigLevel {
                event = .tiltForward
            } else if attitude.roll < -MotionTracker.angleTrigLevel {
                event = .tiltBackward
            } else if attitude.pitch > MotionTracker.angleTrigLevel {
                event = .tiltRight
            } else if attitude.pitch < -MotionTracker.angleTrigLevel {
                event = .tiltLeft
            }

        case .shakeUp: fallthrough
        case .shakeDown:
            if timestamp - shakeTimeStamp! > accelerationDuration {
                event = .flat
            }
        case .tiltForward:
            if attitude.roll < MotionTracker.angleClearLevel {
                event =  .flat
            }
        case .tiltBackward:
            if attitude.roll > -MotionTracker.angleClearLevel {
                event = .flat
            }
        case .tiltLeft:
            if attitude.pitch > -MotionTracker.angleClearLevel {
                event = .flat
            }
        case .tiltRight:
            if attitude.pitch < MotionTracker.angleClearLevel {
                event = .flat
            }
        }
        delegate?.motionUpdate(lateralAngle: Int(attitude.pitch * 180 / .pi),
                               longitudinalAngle: -Int(attitude.roll * 180 / .pi),
                               lastEvent: event)
        return event
    }
}
