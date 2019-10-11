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

/// Drone related events listener
protocol DroneViewProxyDroneDelegate: class {
    func droneViewProxyDidReceiveStatusEvent(flyingState: FlyingState, hasCannon: Bool, hasGrabber: Bool)
}

/// Motion tracker related events listener
protocol DroneViewProxyMotionTrackerDelegate: class {
    func droneViewProxyDidReceiveMotionEvent(_ event: MotionEvent)
}

/// Playground page proxy to the drone liveview
class DroneViewProxy {

    /// Commands sent from playground page to contoller
    enum Cmd {
        case getState
        case takeOff
        case land
        case turn(angle: Int)
        case move(params: MoveParams, duration: Int)
        case stopMoving
        case flip(direction: FlipDirection)
        case fireCannon
        case openGrabber
        case closeGrabber
        case takePicture
        case startMotionTracker

        func marshal() -> PlaygroundValue {
            switch self {
            case .getState:
                return .dictionary(["cmd": .string("getState")])
            case .takeOff:
                return .dictionary(["cmd": .string("takeOff")])
            case .land:
                return .dictionary(["cmd": .string("land")])
            case .turn(let angle):
                return .dictionary(["cmd": .string("turn"), "angle": .integer(angle)])
            case .move(let params, let duration):
                return .dictionary(["cmd": .string("move"),
                                    "params": .array([
                                        .integer(params.longitudinalSpeed),
                                        .integer(params.lateralSpeed),
                                        .integer(params.verticalSpeed),
                                        .integer(params.rotationSpeed)]),
                                    "duration": .integer(Int(duration)) ])
            case .stopMoving:
                return .dictionary(["cmd": .string("stopMoving")])
            case .flip(let direction):
                return .dictionary(["cmd": .string("flip"), "direction": .integer(Int(direction.rawValue))])
            case .fireCannon:
                return .dictionary(["cmd": .string("fireCannon")])
            case .openGrabber:
                return .dictionary(["cmd": .string("openGrabber")])
            case .closeGrabber:
                return .dictionary(["cmd": .string("closeGrabber")])
            case .takePicture:
                return .dictionary(["cmd": .string("takePicture")])
            case .startMotionTracker:
                return .dictionary(["cmd": .string("startMotionTracker")])

            }
        }

        init?(value: PlaygroundValue) {
            guard case let .dictionary(dict) = value else { return nil }

            var val: Cmd?
            if let cmdEntry = dict["cmd"], case let .string(cmdStr) = cmdEntry {
                switch cmdStr {
                case "getState":
                    val = .getState
                case "takeOff":
                    val = .takeOff
                case "land":
                    val = .land
                case "turn":
                    if case let .integer(angle)? = dict["angle"] {
                        val = .turn(angle: angle)
                    }
                case "move":
                    if case let .array(params)? = dict["params"], params.count == 4,
                        case let .integer(longitudinalSpeed) = params[0],
                        case let .integer(lateralSpeed) = params[1],
                        case let .integer(verticalSpeed) = params[2],
                        case let .integer(rotationSpeed) = params[3],
                        case let .integer(duration)? = dict["duration"] {
                        val = .move(params: MoveParams(
                            longitudinalSpeed: longitudinalSpeed, lateralSpeed: lateralSpeed,
                            verticalSpeed: verticalSpeed, rotationSpeed: rotationSpeed), duration: duration)
                    }
                case "stopMoving":
                    val = .stopMoving
                case "flip":
                    if case let .integer(directionValue)? = dict["direction"],
                        let direction = FlipDirection(rawValue: directionValue) {
                        val = .flip(direction: direction)
                    }
                case "fireCannon":
                    val = .fireCannon
                case "openGrabber":
                    val = .openGrabber
                case "closeGrabber":
                    val = .closeGrabber
                case "takePicture":
                    val = .takePicture
                case "startMotionTracker":
                    val = .startMotionTracker
                default:
                    break
                }
            }
            if let val = val {
                self = val
            } else {
                return nil
            }
        }
    }

    /// Events from the live view
    enum Evt {
        // drone connected/disconnected
        case connected(Bool)
        // latest command completed
        case cmdCompleted
        // status update
        case status(flyingState: FlyingState, hasCannon: Bool, hasGrabber: Bool)
        // motion tracker event
        case motionEvent(event: MotionEvent)

        func marshal() -> PlaygroundValue {
            switch self {
            case let .connected(connected):
                return .dictionary(["evt": .string("connected"),
                                    "state": .boolean(connected)])
            case .cmdCompleted:
                return .dictionary(["evt": .string("cmdCompleted")])
            case let .status(flyingState, hasCannon, hasGrabber):
                return .dictionary(["evt": .string("status"),
                                    "flyingState": .integer(flyingState.rawValue),
                                    "hasCannon": .boolean(hasCannon),
                                    "hasGrabber": .boolean(hasGrabber)])
            case let .motionEvent(motion):
                return .dictionary(["evt": .string("motion"),
                                    "motion": .integer(motion.rawValue)])
            }
        }

        init?(value: PlaygroundValue) {
            guard case let .dictionary(dict) = value else { return nil }

            var val: Evt?
            if let evtEntry = dict["evt"], case let .string(evtStr) = evtEntry {
                switch evtStr {
                case "connected":
                    if let stateEntry = dict["state"],
                        case let .boolean(connected) = stateEntry {
                        val = .connected(connected)
                    }

                case "cmdCompleted":
                    val = .cmdCompleted

                case "status":
                    if let flyinStateEntry = dict["flyingState"],
                        case let .integer(flyingStateVal) = flyinStateEntry,
                        let flyinState = FlyingState(rawValue: flyingStateVal),
                        let hasCannonEntry = dict["hasCannon"], case let .boolean(hasCannon) = hasCannonEntry,
                        let hasGrabberEntry = dict["hasGrabber"], case let .boolean(hasGrabber) = hasGrabberEntry {
                        val = .status(flyingState: flyinState, hasCannon: hasCannon, hasGrabber: hasGrabber)
                    }
                case "motion":
                    if let motionEventEntry = dict["motion"],
                        case let .integer(motionEventVal) = motionEventEntry,
                        let motionEvent = MotionEvent(rawValue: motionEventVal) {
                        val = .motionEvent(event: motionEvent)
                    }

                default: break
                }
            }

            if let val = val {
                self = val
            } else {
                return nil
            }
        }
    }

    weak var droneDelegate: DroneViewProxyDroneDelegate?
    weak var motionTrackerDelegate: DroneViewProxyMotionTrackerDelegate?

    private var connected = false
    private var done = true

    init() {
        let page = PlaygroundPage.current
        let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
        proxy?.delegate = self
    }

    func waitConnected() {
        done = false
        sendCommand(.getState)
        while !connected || !done {
            receiveEvents()
        }
    }

    func sendCommand(_ cmd: Cmd) {
        (PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy)?.send(cmd.marshal())
    }

    func processEvent(_ event: Evt) {
        switch event {
        case .connected(let connected):
            self.connected = connected
        case .cmdCompleted:
            done = true
        case .status(let flyingState, let hasCannon, let hasGrabber):
            droneDelegate?.droneViewProxyDidReceiveStatusEvent(
                flyingState: flyingState, hasCannon: hasCannon, hasGrabber: hasGrabber)
        case .motionEvent(let motionEvent):
            motionTrackerDelegate?.droneViewProxyDidReceiveMotionEvent(motionEvent)
        }
    }

    func receiveEvents(wait: Double = 0.1) {
        RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: wait))
    }

    func waitDone() {
        done = false
        while !done {
            receiveEvents()
        }
    }
}

extension DroneViewProxy: PlaygroundRemoteLiveViewProxyDelegate {

    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    }

    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        if let event = Evt(value: message) {
            processEvent(event)
        }
    }
}
