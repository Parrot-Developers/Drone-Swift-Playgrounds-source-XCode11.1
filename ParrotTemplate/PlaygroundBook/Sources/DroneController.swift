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

protocol DroneControllerDelegate: class {
    func opTerminated(error: DroneController.OpError?)
    func droneControllerDidFindDrone(droneModel: DroneModel)
    func droneControllerDidStop()
    func droneFirmwareOutOfDate()
    func droneControllerConnectionStateDidChange(_ connectionState: DroneController.ConnectionState)
    func droneControllerStateDidChange()
}

class DroneController {

    public enum ConnectionState {
        case searching, connecting, connected, disconnected
    }

    public enum BatteryLevel {
        case unknown, level(percent: Int, low: Bool)
    }

    public enum OpError {
        /// battery level to low to perform a flip
        case flipLowBat
        /// fire cannon but cannon is not attached
        case noCannon
        /// open/close grabber but grabber to attached
        case noGrabber
    }

    /// range to bound angle
    private let angleRange = -180...180
    /// range to bound commnands in %
    private let percentRange = 0...100
    /// range to bound commands in +/- %
    private let signedPercentRange = -100...100

    /// Ble instance
    public var ble: DroneBle!
    /// Queue running drone protocol and ble
    fileprivate let protocolQueue = DispatchQueue(label:"DroneProtocol")
    /// Protocol instance
    fileprivate var droneProtocol: DroneProtocol?

    /// Delegate
    weak var delegate: DroneControllerDelegate?

    /// Current operation. Set while waiting for operation completion event
    fileprivate (set) var currentOp: Operation? {
        didSet {
            delegate?.droneControllerStateDidChange()
        }
    }

    /// Drone Model
    fileprivate (set) var droneModel: DroneModel? {
        didSet {
            if let droneModel = droneModel {
                delegate?.droneControllerDidFindDrone(droneModel: droneModel)
            }
        }
    }

    /// Flying state
    fileprivate (set) var flyingState = FlyingState.landed {
        didSet {
            delegate?.droneControllerStateDidChange()
        }
    }

    /// connection state
    fileprivate (set) var connectionState = ConnectionState.disconnected {
        didSet {
            delegate?.droneControllerConnectionStateDidChange(connectionState)
        }
    }

    /// battery level
    fileprivate (set) var batteryLevel = BatteryLevel.unknown {
        didSet {
            delegate?.droneControllerStateDidChange()
        }
    }

    var droneName: String {
        return ble.peripheral?.name ?? ""
    }

    fileprivate var cannonAccessoryId: UInt8? {
        didSet {
            myCannonAccessoryId = cannonAccessoryId
            delegate?.droneControllerStateDidChange()
        }
    }
    var cannonPlugged: Bool { return cannonAccessoryId != nil }

    fileprivate var grabberAccessoryId: UInt8? {
        didSet {
            myGrabberAccessoryId = grabberAccessoryId
            delegate?.droneControllerStateDidChange()
        }
    }
    var grabberPlugged: Bool { return grabberAccessoryId != nil }

    /// Operations
    public enum Operation {
        case takeOff
        case land
        case move(params: MoveParams, duration: Int)
        case stopMoving
        case turn(angle: Int)
        case flip(direction: FlipDirection)
        case setLights(state: LightState, id: UInt8?)
        case fireCannon
        case openGrabber
        case closeGrabber
        case takePicture
    }

    init() {
        self.cannonAccessoryId = myCannonAccessoryId
        self.grabberAccessoryId = myGrabberAccessoryId
        ble = DroneBle(queue: protocolQueue, delegate: self)
        self.droneModel = myDrone
    }

    public func execute(op: Operation) {
        currentOp = op
        switch op {

        // take off, complete when the flying state is flying
        case .takeOff:
            droneProtocol?.takeOff()

        // land, complete when the flying state is landed
        case .land:
            droneProtocol?.land()

        // turn, complete after a fixed delay
        case .turn(let angle):
            droneProtocol?.cap(angle: Int16(angle.clamped(into: angleRange)))
            // there is no event for the end of cap cmd, just wait....
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.currentOpTerminated()
            }

        // move, complete after duration
        case .move(let params, let duration):
            droneProtocol?.pcmd((
                roll: Int8(params.lateralSpeed.clamped(into: signedPercentRange)),
                pitch: Int8(params.longitudinalSpeed.clamped(into: signedPercentRange)),
                yaw: Int8(params.rotationSpeed.clamped(into: signedPercentRange)),
                gaz: Int8(params.verticalSpeed.clamped(into: signedPercentRange))),
                                duration: duration)

        // stop moving, complete after duration stop duration
        case .stopMoving:
            droneProtocol?.clearPcmd()

        // turn, complete after a fixed delay
        case .flip(let direction):
            if case .level(let percent, _) = batteryLevel, percent >= 10 {
                droneProtocol?.flip(direction: direction)
                // there is no event for the end of flip, just wait....
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.currentOpTerminated()
                }
            } else {
                DispatchQueue.main.async {
                    self.currentOpTerminated(error: .flipLowBat)
                }
            }

        case .fireCannon:
            if let cannonAccessoryId = cannonAccessoryId {
                droneProtocol?.accessoryCannonFire(id: cannonAccessoryId)
            } else {
                currentOpTerminated(error: .noCannon)
            }

        case .openGrabber:
            if let grabberAccessoryId = grabberAccessoryId {
                droneProtocol?.accessoryGrabberOpen(id: grabberAccessoryId)
            } else {
                currentOpTerminated(error: .noGrabber)
            }

        case .closeGrabber:
            if let grabberAccessoryId = grabberAccessoryId {
                droneProtocol?.accessoryGrabberClose(id: grabberAccessoryId)
            } else {
                currentOpTerminated(error: .noGrabber)
            }

        case .takePicture:
            droneProtocol?.takePicture()

        case .setLights: break
        }
    }

    fileprivate func currentOpTerminated(error: OpError? = nil) {
        currentOp = nil
        delegate?.opTerminated(error: error)
    }
}

/// DroneBleDelegate implementation. All func are called in the protocol queue
extension DroneController: DroneBleDelegate {

    func droneBleDidConnect() {
        connectionState = .connecting
        DispatchQueue.main.sync {
            droneProtocol = DroneProtocol(droneBle: ble, queue: protocolQueue, delegate: self)
        }
        // connect protocol after a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak droneProtocol] in
            droneProtocol?.connect()
        }
    }

    func droneBleDidDisconnect() {
        droneProtocol = nil
        batteryLevel = .unknown
        flyingState = .landed
        connectionState = .disconnected
        DispatchQueue.main.async {
            self.delegate?.droneControllerDidStop()
        }
    }
}

/// DroneProtocolDelegate implementation. All func are called in the protocol queue
extension DroneController: DroneProtocolDelegate {

    func protocolConnecting(name: String, uuid: UUID, model: Model, subModel: SubModel) {
        let newDroneModel = DroneModel(model: model, subModel: subModel)
        myDrone = newDroneModel
        droneModel = newDroneModel
    }

    func protocolDidConnect() {
        connectionState = .connected
    }

    func protocolDidDisconnect() {
        connectionState = .disconnected
    }

    func firmwareOutOfDate() {
        delegate?.droneFirmwareOutOfDate()
    }

    func flyingStateDidChange(_ state: FlyingState) {
        flyingState = state
        if let currentOp = currentOp {
            switch currentOp {
            case .takeOff:
                if state == .flying {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.currentOpTerminated()
                    }
                }
            case .land:
                if state == .landed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.currentOpTerminated()
                    }
                }
            default:
                break
            }
        }
    }

    func pcmdTerminated() {
        if let currentOp = currentOp {
            switch currentOp {
            case .move: fallthrough
            case .stopMoving:
                currentOpTerminated()
            default: break
            }
        }
    }

    func batteryLevelDidChange(_ percent: Int?, low: Bool) {
        if let percent = percent {
            batteryLevel = .level(percent: percent, low: low)
        } else {
            batteryLevel = .unknown
        }
    }

    func pictureStateDidChange(ready: Bool) {
        if let currentOp = currentOp, case .takePicture = currentOp, ready {
            currentOpTerminated()
        }
    }

    func headlightAvailable() {
    }

    func accessoryLight(available: Bool, id: UInt8, state: LightState) {
    }

    func accessoryGrabber(available: Bool, id: UInt8, opened: Bool ) {
        if available {
            if grabberAccessoryId == nil {
                grabberAccessoryId = id
            } else {
                if let currentOp = currentOp {
                    switch currentOp {
                    case .openGrabber:
                        if opened {
                            currentOpTerminated()
                        }
                    case .closeGrabber:
                        if !opened {
                            currentOpTerminated()
                        }
                    default:
                        break
                    }
                }
            }
        } else {
            grabberAccessoryId = nil
        }
    }

    func accessoryCannon(available: Bool, id: UInt8, ready: Bool) {
        if available {
            if cannonAccessoryId == nil {
                cannonAccessoryId = id
            } else {
                if let currentOp = currentOp, case .fireCannon = currentOp, ready {
                    currentOpTerminated()
                }
            }
        } else {
            cannonAccessoryId = nil
        }
    }
}

extension Int {
    func clamped(into range: CountableClosedRange<Int>) -> Int {
        return self < range.lowerBound ? range.lowerBound :
            self > range.upperBound ? range.upperBound :
        self
    }
}
