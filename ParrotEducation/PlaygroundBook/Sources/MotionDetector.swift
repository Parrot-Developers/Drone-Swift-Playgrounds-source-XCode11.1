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

import Foundation

/// Events trigger when on iPad motion. See `waitNextMotionEvent()`
public enum MotionEvent: Int {
    /// iPad is hold flat
    case flat
    /// iPad is tilted forward
    case tiltForward
    /// iPad is tilted backward
    case tiltBackward
    /// iPad is tilted on the left
    case tiltLeft
    /// iPad is tilted on the right
    case tiltRight
    /// iPad is shaked up
    case shakeUp
    /// iPad is shaked down
    case shakeDown
}

/// Detect iPad motions.
/// This is the playground page side of MotionTracker
public class MotionDetector {

    fileprivate let droneViewProxy: DroneViewProxy
    fileprivate var state = MotionEvent.flat
    fileprivate var event: MotionEvent?
    private var started = false

    /// Constructor
    init(droneViewProxy: DroneViewProxy) {
        self.droneViewProxy = droneViewProxy
        self.droneViewProxy.motionTrackerDelegate = self
    }

    /// Waits until the drone is connected
    public func waitNextMotionEvent() -> MotionEvent {
        if !started {
            started = true
            droneViewProxy.sendCommand(.startMotionTracker)
        }
        while event != state {
            droneViewProxy.receiveEvents(wait: 0.01)
            if let event = event {
                state = event
            }
        }
        self.event = nil
        return state
    }
}

extension MotionDetector: DroneViewProxyMotionTrackerDelegate {
    func droneViewProxyDidReceiveMotionEvent(_ event: MotionEvent) {
        self.event = event
    }
}
