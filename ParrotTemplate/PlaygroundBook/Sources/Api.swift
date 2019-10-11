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
import PlaygroundSupport

// Global drone view proxy
let droneViewProxy = DroneViewProxy()

// Global drone instance
let drone = Drone(droneViewProxy: droneViewProxy)

// Global motion detector
let motionDetector = MotionDetector(droneViewProxy: droneViewProxy)

// Drone Flying state
public var flyingState: FlyingState {
    return drone.flyingState
}

/// Speed for simple moves. Speed is in % of the drone maximum speed
public var droneSpeed: UInt {
    get {
        return drone.speed
    }
    set {
        drone.speed = newValue
    }
}

/// True if the cannon is attached on the drone
public var hasCanon: Bool {
    return drone.cannon != nil
}

/// True if the grabber is attached on the drone
public var hasGrabber: Bool {
    return drone.grabber != nil
}

/// Wait until the drone is connected and ready to accept commands
public func waitDroneConnected() {
    drone.waitConnected()
}

/// Take off. This function make the drone fly and wait at about 1m height.
public func takeOff() {
    drone.takeOff()
}

/// Land. This function make the drone land at its current position
public func land() {
    drone.land()
}

/// Move in a single direction during the specified time.
///
/// - Parameters:
///   - direction: direction to move
///   - duration: duration of the move in seconds
public func move(direction: MoveDirection, duration: UInt) {
    drone.move(direction: direction, duration: Int(duration))
}

/// Start moving in a single direction and return immediatly
///
/// - Parameters:
///   - direction: direction to move
public func move(direction: MoveDirection) {
    drone.move(direction: direction)
}

/// Stop current mouvement.
public func stopMoving() {
    drone.stopMoving()
}

/// Complex move: move in multiple directions for a specific duration
///
/// - Parameters:
///   - pitch: longitudinal speed in %, positive to move forward, negative to move backward.
///   - roll: lateral speed in %, positive to move right, negative to move left.
///   - gaz: vertical speed in %. positive to move up, negative to move down.
///   - yaw: rotationSpeed in %, positive to turn clockwise negative to turn counterclockwise
///   - duration: Move duration in seconds
public func move(pitch: Int, roll: Int, gaz: Int, yaw: Int, duration: UInt) {
    drone.move(params: MoveParams(longitudinalSpeed: pitch, lateralSpeed: roll,
                                  verticalSpeed: gaz, rotationSpeed: yaw), duration: duration)
}

/// Ask the drone to turn on itself
///
/// - Parameters:
///   - direction: turn direction
///   - angle: angle to turn in degrees (0 to 180 degrees)
public func turn(direction: TurnDirection, angle: UInt) {
    drone.turn(direction: direction, angle: angle)
}

/// Perform a flip
///
/// - Parameter direction: flip direction
public func flip(direction: FlipDirection) {
    drone.flip(direction: direction)
}

/// Fire the drone cannon
public func fireCannon() {
    drone.fireCannon()
}

/// Open the drone grabber
public func openGrabber() {
    drone.openGrabber()
}

/// Close the drone grabber
public func closeGrabber() {
    drone.closeGrabber()
}

/// Take a picture
public func takePicture() {
    drone.takePicture()
}

/// Wait for a fixed duration
///
/// - Parameter seconds: duration to wait, in seconds
public func wait(_ seconds: Int) {
    if seconds > 0 {
        sleep(UInt32(seconds))
    }
}

/// Wait for the next iPad motion event
///
/// - Returns: next motion event
public func waitNextMotionEvent() -> MotionEvent {
    return motionDetector.waitNextMotionEvent()
}

/// Starts collecting action to check assessment
public func startAssessor() {
    drone.assessor = Assessor()
}

/// Check if expected actions have been made
public func checkAssessment(expected expectedActions: [Assessor.Assessment], success: String?)
    -> PlaygroundPage.AssessmentStatus? {
        return drone.assessor?.check(expected: expectedActions, success: success)
}
