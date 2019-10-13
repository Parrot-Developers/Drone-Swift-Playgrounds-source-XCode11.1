// Copyright (C) 2016-2017 Parrot SA
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

public class Drone {
    fileprivate let droneViewProxy: DroneViewProxy

    public var assessor: Assessor?

    /// Speed for simple moves. Speed is in % of the drone maximum speed
    public var speed = UInt(50) {
        didSet {
            assessor?.add(action: .speed(speed))
        }
    }

    /// Drone flying state
    fileprivate(set) var flyingState = FlyingState.landed
    /// Cannon accessory, nil if the drone doesn't have a cannon
    fileprivate(set) var cannon: Cannon?
    /// Grabber accessory, nil if the drone doesn't have a grabber
    fileprivate(set) var grabber: Grabber?

    /// Constructor
    init(droneViewProxy: DroneViewProxy) {
        self.droneViewProxy = droneViewProxy
        self.droneViewProxy.droneDelegate = self
    }

    /// Waits until the drone is connected
    public func waitConnected() {
        droneViewProxy.waitConnected()
    }

    /// Take off. This function make the drone fly and wait at about 1m height.
    public func takeOff() {
        droneViewProxy.receiveEvents()
        if flyingState == .landed {
            droneViewProxy.sendCommand(.takeOff)
            droneViewProxy.waitDone()
        }
        assessor?.add(action: .takeOff)
    }

    /// Land. This function make the drone land at its current position
    public func land() {
        droneViewProxy.receiveEvents()
        if flyingState == .flying {
            droneViewProxy.sendCommand(.land)
            droneViewProxy.waitDone()
        }
        assessor?.add(action: .land)
    }

    /// Move in a single direction during the specified time.
    ///
    /// - Parameters:
    ///   - direction: direction to move
    ///   - duration: duration of the move in seconds
    public func move(direction: MoveDirection, duration: Int) {
        doMove(params: MoveParams(direction: direction, speed: speed), duration: duration)
        assessor?.add(action: .move(direction: direction, duration: duration))
    }

    /// Start moving in a single direction and return immediatly
    ///
    /// - Parameters:
    ///   - direction: direction to move
    public func move(direction: MoveDirection) {
        doMove(params: MoveParams(direction: direction, speed: speed), duration: -1)
        assessor?.add(action: .move(direction: direction, duration: -1))
    }

    /// Stop current mouvement.
    public func stopMoving() {
        droneViewProxy.sendCommand(.stopMoving)
        droneViewProxy.waitDone()
    }

    /// Complex move: move in multiple directions for a specific duration
    ///
    /// - Parameters:
    ///   - params: movement description
    ///   - duration: duration of the movement
    public func move(params: MoveParams, duration: UInt) {
        doMove(params: params, duration: Int(duration))
        assessor?.add(action: .complexMove(params, duration: duration))
    }

    /// Send move request to controller
    ///
    /// - Parameters:
    ///   - params: movement description
    ///   - duration: duration of the movement
    private func doMove(params: MoveParams, duration: Int) {
        droneViewProxy.sendCommand(.move(params: params, duration: duration))
        droneViewProxy.waitDone()
    }

    /// Ask the drone to turn on itself
    ///
    /// - Parameters:
    ///   - direction: turn direction
    ///   - angle: angle to turn in degrees (0 to 180 degrees)
    public func turn(direction: TurnDirection, angle: UInt) {
        let absoluteAngle: Int
        switch direction {
        case .left:
            absoluteAngle = -Int(angle)
        case .right:
            absoluteAngle = Int(angle)
        }
        if flyingState == .flying {
            droneViewProxy.sendCommand(.turn(angle: absoluteAngle))
            droneViewProxy.waitDone()
        }
        assessor?.add(action: .turn(direction: direction, angle: angle))
    }

    /// Perform a flip
    ///
    /// - Parameter direction: flip direction
    public func flip(direction: FlipDirection) {
        droneViewProxy.receiveEvents()
        if flyingState == .flying {
            droneViewProxy.sendCommand(.flip(direction: direction))
            droneViewProxy.waitDone()
            assessor?.add(action: .flip(direction: direction))
        }
    }

    /// Take a picture
    public func takePicture() {
        droneViewProxy.receiveEvents()
        droneViewProxy.sendCommand(.takePicture)
        droneViewProxy.waitDone()
        assessor?.add(action: .takePicture)
    }

    /// Fire the drone cannon
    func fireCannon() {
        droneViewProxy.receiveEvents()
        droneViewProxy.sendCommand(.fireCannon)
        droneViewProxy.waitDone()
        assessor?.add(action: .fireCannon)
    }

    /// Open the drone grabber
    func openGrabber() {
        droneViewProxy.receiveEvents()
        droneViewProxy.sendCommand(.openGrabber)
        droneViewProxy.waitDone()
        assessor?.add(action: .openGrabber)
    }

    /// Close the drone grabber
    public func closeGrabber() {
        droneViewProxy.receiveEvents()
        droneViewProxy.sendCommand(.closeGrabber)
        droneViewProxy.waitDone()
        assessor?.add(action: .closeGrabber)
    }
}

extension Drone: DroneViewProxyDroneDelegate {
    func droneViewProxyDidReceiveStatusEvent(flyingState: FlyingState, hasCannon: Bool, hasGrabber: Bool) {
        self.flyingState = flyingState
        if hasCannon {
            if cannon == nil {
                cannon = Cannon(drone: self)
            }
        } else if !hasCannon {
            cannon = nil
        }
        if hasGrabber {
            if grabber == nil {
                grabber = Grabber(drone: self)
            }
        } else if !hasGrabber {
            grabber = nil
        }
    }
}

// Extension that add constructor from a MoveDirection
fileprivate extension MoveParams {
    init(direction: MoveDirection, speed: UInt) {
        switch direction {
        case .forward:
            self.init(longitudinalSpeed: Int(speed))
        case .backward:
            self.init(longitudinalSpeed: -Int(speed))
        case .left:
            self.init(lateralSpeed: -Int(speed))
        case .right:
            self.init(lateralSpeed: Int(speed))
        case .up:
            self.init(verticalSpeed: Int(speed))
        case .down:
            self.init(verticalSpeed: -Int(speed))
        }
    }
}
