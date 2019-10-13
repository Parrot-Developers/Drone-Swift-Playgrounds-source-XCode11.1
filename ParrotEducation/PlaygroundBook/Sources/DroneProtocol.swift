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

/// Delegate. All function are called in the DroneProtocol dispatch queue
protocol DroneProtocolDelegate: class {
    func protocolConnecting(name: String, uuid: UUID, model: Model, subModel: SubModel)
    func protocolDidConnect()
    func protocolDidDisconnect()
    func firmwareOutOfDate()
    func flyingStateDidChange(_ state: FlyingState)
    func pcmdTerminated()
    func batteryLevelDidChange(_ percent: Int?, low: Bool)
    func pictureStateDidChange(ready: Bool)
    // evo lights
    func headlightAvailable()
    // mambo
    func accessoryLight(available: Bool, id: UInt8, state: LightState)
    func accessoryGrabber(available: Bool, id: UInt8, opened: Bool)
    func accessoryCannon(available: Bool, id: UInt8, ready: Bool)
}

///
/// Drone ble protocol implementation
///
/// Contains a subset of available commands,  see https://github.com/Parrot-Developers/arsdk-xml/tree/master/xml for
/// commands definitions.
///
class DroneProtocol {

    /// Delegate
    private weak var delegate: DroneProtocolDelegate?
    /// Ble instance
    private let droneBle: DroneBle
    /// Queue running drone protocol
    private let dispatchQueue: DispatchQueue
    /// Channel for ACK'ed commands
    private var commandChannel: CommandChannel!
    /// Channel for non ack commands
    private var controlChannel: ControlChannel!
    /// Channel receiving ACK'ed events
    private var eventChannel: EventChannel!
    /// Channel receiving non ack events
    private var eventChannelNoAck: EventChannel!
    /// Timer to send pcmd
    private var pcmdTimer: DispatchSourceTimer?
    /// pcmd value
    private var pcmd = (roll:Int8(0), pitch:Int8(0), yaw:Int8(0), gaz:Int8(0))
    /// countdonw numer of pcmd to send before reseting it to 0
    private var pcmdCnt = 0
    /// true if lowBattery alert has been received
    private var lowBattery = false
    /// current battery level, nil if not received
    private var batteryLevel: Int?
    /// True when protocol is connected
    private var connected = false
    /// True if drone is still initializing itself
    private var initializing = true

    // delay before completing pcmd with duration. This is to let the drone stop before continuing
    private static let pcmdStopDelay = 5

    // Min version required
    private static let mamboMinVersion = (2, 6, 6)
    private static let cargoMinVersion = (2, 1, 70)
    private static let nightMinVersion = (2, 1, 70)
    private static let rsMinVersion = (1, 99, 2)

    /// Cosntructor
    ///
    /// - Parameters:
    ///   - droneBle: ble transport instance
    ///   - queue: queue to run protocol. Delegate func are called in this queue
    ///   - delegate: delegate
    init(droneBle: DroneBle, queue: DispatchQueue, delegate: DroneProtocolDelegate) {
        self.delegate = delegate
        self.dispatchQueue = queue
        self.droneBle = droneBle
        self.commandChannel = CommandChannel(sender: droneBle.senders[.cmdAck]!, ack: droneBle.receivers[.cmdAck]!)
        self.controlChannel = ControlChannel(sender: droneBle.senders[.cmdNoAck]!)
        self.eventChannel = EventChannel(
        receiver: droneBle.receivers[.evtAck]!, ack: droneBle.senders[.evtAck]!) { [unowned self] event in
            self.didReceiveEvent(event)
        }
        self.eventChannelNoAck = EventChannel(
        receiver: droneBle.receivers[.evtNoAck]!, ack: nil) { [unowned self] event in
            self.didReceiveEvent(event)
        }
    }

    deinit {
        pcmdTimer = nil
    }

    /// Connect the protocol
    func connect() {
        dispatchQueue.sync {
            pcmd = (roll: 0, pitch: 0, yaw: 0, gaz: 0)
            lowBattery = false
            batteryLevel = nil
            // execute basic connection steps
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            let now = Date()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            commandChannel.send(command: .setDate(dateFormatter.string(from: now)))
            dateFormatter.dateFormat = "'T'HHmmssZZZ"
            commandChannel.send(command: .setTime(dateFormatter.string(from: now)))
            // get all settings to start connection
            commandChannel.send(command: .getAllSettings)

            // mambo and original rs doesn't have sub model, notify now
            if let name = droneBle.droneName, let uuid = droneBle.droneUuid, let model = droneBle.droneModel {
                if model == .mambo ||  model == .rollingSpider {
                    delegate?.protocolConnecting(name: name, uuid: uuid, model: model, subModel: .none)
                }
            }
        }
    }

    /// send take off command
    func takeOff() {
        dispatchQueue.sync {
            commandChannel.send(command: .takeOff)
        }
    }

    /// send land command
    func land() {
        dispatchQueue.sync {
            commandChannel.send(command: .land)
        }
    }

    /// Set the pcmd value to send
    ///
    /// - Parameters:
    ///   - pcmd: pcmd value
    ///   - duration: duration, in seconds. pcmd is cleared and delegate pcmdTerminated after this duration
    func pcmd(_ pcmd: (roll: Int8, pitch: Int8, yaw: Int8, gaz: Int8), duration: Int) {
        dispatchQueue.sync {
            if duration >= 0 {
                self.pcmdCnt = duration * 10 + DroneProtocol.pcmdStopDelay
            } else {
                self.pcmdCnt = -1
                self.dispatchQueue.async {
                    self.delegate?.pcmdTerminated()
                }
            }
            self.pcmd = pcmd
        }
    }

    /// Clear current pcmd. delegate pcmdTerminated is called after pcmdStopDelay
    func clearPcmd() {
        dispatchQueue.sync {
            self.pcmdCnt = DroneProtocol.pcmdStopDelay
            self.pcmd = (0, 0, 0, 0)
        }
    }

    func cap(angle: Int16) {
        dispatchQueue.sync {
            commandChannel.send(command: .cap(angle: angle))
        }
    }

    func flip(direction: FlipDirection) {
        dispatchQueue.sync {
            commandChannel.send(command: .flip(direction: UInt32(direction.rawValue)))
        }
    }

    func takePicture() {
        dispatchQueue.sync {
            commandChannel.send(command: .takePicture)
        }
    }

    /// Delos EVO lights
    func headlights(left: UInt8, right: UInt8) {
        dispatchQueue.sync {
            commandChannel.send(command: .headlights(left: left, right: right))
        }
    }

    func headlightsBlink() {
        dispatchQueue.sync {
            commandChannel.send(command: .startAnimation(id: 1))
        }
    }

    func headlightsOscillate() {
        dispatchQueue.sync {
            commandChannel.send(command: .startAnimation(id: 2))
        }
    }

    func accessoryCannonFire(id: UInt8) {
        dispatchQueue.sync {
            commandChannel.send(command: .usbCannonControl(id: id, action: 0))
        }
    }

    func accessoryGrabberOpen(id: UInt8) {
        dispatchQueue.sync {
            commandChannel.send(command: .usbGrabberControl(id: id, action: 0))
        }
    }

    func accessoryGrabberClose(id: UInt8) {
        dispatchQueue.sync {
            commandChannel.send(command: .usbGrabberControl(id: id, action: 1))
        }
    }

    func accessoryLightSet(id: UInt8, state: LightState) {
        dispatchQueue.sync {
            switch state {
            case .off:
                commandChannel.send(command: .usbLightControl(id: id, mode: 0, intensity: 0))
            case .on(let intensity):
                commandChannel.send(command: .usbLightControl(id: id, mode: 0, intensity: UInt8(intensity)))
            case .blink:
                commandChannel.send(command: .usbLightControl(id: id, mode: 1, intensity: 0))
            case .oscillate:
                commandChannel.send(command: .usbLightControl(id: id, mode: 2, intensity: 0))
            }
        }
    }

    private func didReceiveEvent(_ event: Event) {
        switch event {
        case .allSettingsSent:
            commandChannel.send(command: .getAllStates)
        case .allStateSent:
            // set hull/wheels
            if let model = droneBle.droneModel, model == .rollingSpider {
                commandChannel.send(command: .hasWheels(true))
            } else {
                commandChannel.send(command: .hasHull(true))
            }
            // enable cutout mode
            commandChannel.send(command: .cutOutMode(1))
            // set max speed
            commandChannel.send(command: .setMaxTilt(15))
            commandChannel.send(command: .setMaxVerticalSpeed(2.0))
            commandChannel.send(command: .setMaxRotationSpeed(90))
            // start pcmd loop
            pcmdTimer = DispatchSource.makeTimerSource(queue: dispatchQueue)
            pcmdTimer?.setEventHandler { [unowned self] in
                if self.pcmdCnt > 0 {
                    if self.pcmdCnt == DroneProtocol.pcmdStopDelay {
                        self.pcmd = (0, 0, 0, 0)

                    }
                    self.pcmdCnt -= 1
                    if self.pcmdCnt == 0 {
                        self.dispatchQueue.async {
                            self.delegate?.pcmdTerminated()
                        }
                    }
                }
                let flag = self.pcmd.pitch != 0 || self.pcmd.roll != 0
                self.controlChannel.send(command:
                    .pcmd(flag: flag, roll: self.pcmd.roll, pitch: self.pcmd.pitch,
                          yaw: self.pcmd.yaw, gaz: self.pcmd.gaz))
            }
            pcmdTimer?.schedule(deadline: DispatchTime.now(), repeating: .milliseconds(100))
            pcmdTimer?.resume()
            // connected !
            connected = true
            if !initializing {
                delegate?.protocolDidConnect()
            }
        case .productModel(let submodel):
            if let name = droneBle.droneName, let uuid = droneBle.droneUuid, let model = droneBle.droneModel,
                let subModel = SubModel(rawValue: submodel) {
                delegate?.protocolConnecting(name: name, uuid: uuid, model: model, subModel: subModel)
            }
        case .flyingStateChanged(let state):
            if initializing {
                initializing = FlyingState.initializing(value: state)
                if connected && !initializing {
                    delegate?.protocolDidConnect()
                }
            }
            delegate?.flyingStateDidChange(FlyingState.from(value: state))
        case .headlightsState(_, _):
            // notify drone has lights
            delegate?.headlightAvailable()
        case .alertStateChanged(let alert):
            if alert == 3 || alert == 4 {
                lowBattery = true
                delegate?.batteryLevelDidChange(batteryLevel, low: lowBattery)
            }
        case .batteryStateChanged(let level):
            batteryLevel = Int(level)
            delegate?.batteryLevelDidChange(batteryLevel, low: lowBattery)
        case .accessoryLightState(let id, let state, let intensity, let listFlags):
            // only handle 1 accessory
            if listFlags & 0x02 == 0x02 {
                let lightState: LightState
                switch state {
                case 0:
                    if intensity == 0 {
                        lightState = .off
                    } else {
                        lightState = .on(UInt(intensity))
                    }
                case 1:
                    lightState = .blink
                case 2:
                    lightState = .oscillate
                default:
                    lightState = .off
                }
                delegate?.accessoryLight(available: true, id: id, state: lightState)
            } else {
                delegate?.accessoryLight(available: false, id: id, state: .off)
            }

        case .accessoryGrabberState(let id, let state, let listFlags):
            // only handle 1 accessory
            if listFlags & 0x02 == 0x02 {
                // considere grabber open if state is opened or closing
                delegate?.accessoryGrabber(available: true, id: id, opened: state==0 || state==3)
            } else {
                delegate?.accessoryGrabber(available: false, id: id, opened: false)
            }

        case .accessoryCannonState(let id, let state, let listFlags):
            // only handle 1 accessory
            if listFlags & 0x02 == 0x02 {
                delegate?.accessoryCannon(available: true, id: id, ready: state==0)
            } else {
                delegate?.accessoryCannon(available: false, id: id, ready: false)
            }

        case .pictureStateChanged(let state):
            delegate?.pictureStateDidChange(ready: state == 0)

        case .softwareVersion(let version):
            if !checkFirmwareUpToDate(versionString: version) {
                delegate?.firmwareOutOfDate()
            }
        default:
            break
        }
    }

    private func checkFirmwareUpToDate(versionString: String) -> Bool {
        let versionComp = versionString.components(separatedBy: ".")
        if let model = droneBle.droneModel, versionComp.count >= 3,
            let major = Int(versionComp[0]), let minor = Int(versionComp[1]), let bugfix = Int(versionComp[2]) {
            if major == 0 {
                return true
            }
            let version = (major, minor, bugfix)
            switch model {
            case .mambo: return version >= DroneProtocol.mamboMinVersion
            case .cargo: return version >= DroneProtocol.cargoMinVersion
            case .night: return version >= DroneProtocol.nightMinVersion
            case .rollingSpider: return version >= DroneProtocol.rsMinVersion
            }
        }
        return true
    }

    /// Commands that can be sent to the drone
    private enum Command {
        case setDate(String)
        case setTime(String)
        case getAllSettings
        case getAllStates
        case takeOff
        case land
        case pcmd(flag: Bool, roll: Int8, pitch: Int8, yaw: Int8, gaz: Int8)
        case cap(angle: Int16)
        case flip(direction: UInt32)
        case setMaxTilt(Float)
        case setMaxVerticalSpeed(Float)
        case setMaxRotationSpeed(Float)
        case cutOutMode(UInt8)
        case takePicture
        // delos
        case hasWheels(Bool)
        // delos evo
        case hasHull(Bool)
        case headlights(left: UInt8, right: UInt8)
        case startAnimation(id: UInt32)
        // delos v3
        case usbLightControl(id: UInt8, mode: UInt32, intensity: UInt8)
        case usbGrabberControl(id: UInt8, action: UInt32)
        case usbCannonControl(id: UInt8, action: UInt32)

        var data: Data {
            switch self {
            case .setDate(let date):
                var data = Data(forCommand:(0, 4, 1))
                data.append(cmdString: date)
                return data
            case .setTime(let time):
                var data = Data(forCommand:(0, 4, 2))
                data.append(cmdString: time)
                return data
            case .getAllSettings:
                return Data(forCommand: (0, 2, 0))
            case .getAllStates:
                return Data(forCommand: (0, 4, 0))
            case .takeOff:
                return Data(forCommand: (2, 0, 1))
            case .land:
                return Data(forCommand: (2, 0, 3))
            case .pcmd(let flag, let roll, let pitch, let yaw, let gaz):
                var data = Data(forCommand: (2, 0, 2))
                data.append(data: flag ? Int8(1) : Int8(0))
                data.append(data: roll)
                data.append(data: pitch)
                data.append(data: yaw)
                data.append(data: gaz)
                data.append(data: UInt32(0))
                return data
            case .cap(let angle):
                var data = Data(forCommand: (2, 4, 1))
                data.append(data: angle)
                return data
            case .flip(let direction):
                var data = Data(forCommand: (2, 4, 0))
                data.append(data: direction)
                return data
            case .setMaxTilt(let max):
                var data = Data(forCommand: (2, 8, 1))
                data.append(data: max)
                return data
            case .setMaxVerticalSpeed(let max):
                var data = Data(forCommand: (2, 1, 0))
                data.append(data: max)
                return data
            case .setMaxRotationSpeed(let max):
                var data = Data(forCommand: (2, 1, 1))
                data.append(data: max)
                return data
            case .takePicture:
                return Data(forCommand: (2, 6, 1))
            case .hasWheels(let value):
                var data = Data(forCommand: (2, 1, 2))
                data.append(data: UInt8(value ? 1 : 0))
                return data
            case .hasHull(let value):
                var data = Data(forCommand: (0, 26, 0))
                data.append(data: UInt32(value ? 3 : 0))
                return data
            case .cutOutMode(let state):
                var data = Data(forCommand: (2, 10, 0))
                data.append(data: state)
                return data
            case .headlights(let left, let right):
                var data = Data(forCommand: (0, 22, 0))
                data.append(data: left)
                data.append(data: right)
                return data
            case .startAnimation(let id):
                var data = Data(forCommand: (0, 24, 0))
                data.append(data: id)
                return data
            case .usbLightControl(let id, let mode, let intensity):
                var data = Data(forCommand: (2, 16, 0))
                data.append(data: id)
                data.append(data: mode)
                data.append(data: intensity)
                return data
            case .usbGrabberControl(let id, let action):
                var data = Data(forCommand: (2, 16, 1))
                data.append(data: id)
                data.append(data: action)
                return data
            case .usbCannonControl(let id, let action):
                var data = Data(forCommand: (2, 16, 2))
                data.append(data: id)
                data.append(data: action)
                return data
            }
        }
    }

    /// Events received from the drone
    private enum Event {
        case allSettingsSent
        case allStateSent
        case productModel(model: UInt8)
        case maxTiltChanged(value: Float, min: Float, max: Float)
        case maxVerticalSpeedChanged(value: Float, min: Float, max: Float)
        case maxRotationSpeedChanged(value: Float, min: Float, max: Float)
        case flyingStateChanged(state: UInt8)
        case batteryStateChanged(level: UInt8)
        case alertStateChanged(alert: UInt8)
        case pictureStateChanged(state: UInt8)
        case softwareVersion(version: String)
        // delos evo
        case headlightsState(left: UInt8, right: UInt8)
        // delos v3
        case accessoryLightState(id: UInt8, state: UInt8, intensity: UInt8, listFlags: UInt8)
        case accessoryGrabberState(id: UInt8, state: UInt8, listFlags: UInt8)
        case accessoryCannonState(id: UInt8, state: UInt8, listFlags: UInt8)

        static func from(data: Data) -> Event? {
            switch (data[2], data[3], data[4]) {
            case (0, 3, 0):
                return .allSettingsSent
            case (0, 5, 0):
                return .allStateSent
            case (0, 5, 1):
                return .batteryStateChanged(level: data[6])
            case (0, 5, 9):
                return .productModel(model: data[6])
            case (0, 23, 0):
                return .headlightsState(left: data[6], right: data[7])
            case (2, 9, 1):
                return .maxTiltChanged(value: data.readFloat(at: 6),
                                       min: data.readFloat(at: 10), max: data.readFloat(at: 14))
            case (2, 5, 0):
                return .maxVerticalSpeedChanged(value: data.readFloat(at: 6),
                                                min: data.readFloat(at: 10), max: data.readFloat(at: 14))
            case (2, 5, 1):
                return .maxRotationSpeedChanged(value: data.readFloat(at: 6),
                                                min: data.readFloat(at: 10), max: data.readFloat(at: 14))
            case (2, 3, 1):
                return .flyingStateChanged(state: data[6])
            case (2, 3, 2):
                return .alertStateChanged(alert: data[6])
            case (2, 7, 1):
                return .pictureStateChanged(state: data[6])
            case (2, 15, 0):
                return .accessoryLightState(id: data[6], state: data[7], intensity: data[11], listFlags: data[12])
            case (2, 15, 1):
                return .accessoryGrabberState(id: data[6], state: data[7], listFlags: data[11])
            case (2, 15, 2):
                return .accessoryCannonState(id: data[6], state: data[7], listFlags: data[11])
            case (0, 3, 3):
                return .softwareVersion(version: data.readString(at: 6))

            default:
                return nil
            }
        }
    }

    ///  Channel to send command with ack
    private class CommandChannel {
        private let sender: DroneBle.Sender
        private let ack: DroneBle.Receiver
        private var seqNr: UInt8 = 0

        init (sender: DroneBle.Sender, ack: DroneBle.Receiver) {
            self.sender = sender
            self.ack = ack
            ack.processor = {
                [weak self] data in
                self?.didReceive(data: data)
            }
        }

        func send(command: Command) {
            seqNr = seqNr &+ 1
            var data = command.data
            data[1] = seqNr
            sender.write(data: data)
        }

        private func didReceive (data: Data) {
            // ignore ack
        }
    }

    ///  Control channel to send piloting commands
    private class ControlChannel {
        private let sender: DroneBle.Sender
        private var seqNr: UInt8 = 0
        init (sender: DroneBle.Sender) {
            self.sender = sender
        }

        func send(command: Command) {
            seqNr = seqNr &+ 1
            var data = command.data
            data[1] = seqNr
            sender.write(data: data)
        }
    }

    /// Channel to receive events
    private class EventChannel {
        private let receiver: DroneBle.Receiver
        private let ack: DroneBle.Sender?
        private let handler: (Event) -> Void
        private var seqNr: UInt8 = 0

        init (receiver: DroneBle.Receiver, ack: DroneBle.Sender?, handler: @escaping (Event) -> Void) {
            self.receiver = receiver
            self.ack = ack
            self.handler = handler
            receiver.processor  = {
                [weak self] data in
                self?.didReceive(data: data)
            }
        }

        private func didReceive (data: Data) {
            // acknolege all received events
            if let ack = ack {
                seqNr = seqNr &+ 1
                ack.write(data: Data(ackOf: data, withSeqNr: seqNr))
            }
            if let event = Event.from(data: data) {
                handler(event)
            }
        }
    }
}

/// Extension to create data of a commands and write zero terminated string
extension Data {
    init(forCommand cmd:(prj: UInt8, cls: UInt8, id: UInt8)) {
        self.init(_:[4, 0, cmd.prj, cmd.cls, cmd.id, 0])
    }

    init(ackOf data: Data, withSeqNr seqNr: UInt8) {
        self.init(_:[1, seqNr, data[1]])
    }

    mutating func append(cmdString string: String) {
        self.append(Data(_:Array(string.utf8)))
        self.append(Data(_: [UInt8(0)]))
    }

    mutating func append(data: UInt8) {
        self.append(Data(bytes: UnsafePointer<UInt8>([data]), count: MemoryLayout<UInt8>.size))
    }

    mutating func append(data: Int8) {
        UnsafePointer([data]).withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int8>.size) {
            self.append($0, count: MemoryLayout<Int8>.size)
        }
    }

    mutating func append(data: Int16) {
        UnsafePointer([data]).withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int16>.size) {
            self.append($0, count: MemoryLayout<Int16>.size)
        }
    }

    mutating func append(data: UInt32) {
        UnsafePointer([data]).withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt32>.size) {
            self.append($0, count: MemoryLayout<UInt32>.size)
        }
    }

    mutating func append(data: Float) {
        UnsafePointer([data]).withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Float>.size) {
            self.append($0, count: MemoryLayout<Float>.size)
        }
    }

    func readFloat(at index: Index) -> Float {
        return self.subdata(
            in: index..<index+MemoryLayout<Float>.size).withUnsafeBytes { (values: UnsafePointer<Float>) -> Float in
                return values.pointee
        }
    }

    func readString(at index: Index) -> String {
        return self.subdata(
            in: index..<self.count).withUnsafeBytes { (values: UnsafePointer<UInt8>) -> String in
                return String(cString: values)
        }
    }
}

extension FlyingState {
    static func from(value: UInt8) -> FlyingState {
        switch value {
        case 0: return .landed
        case 1: return .takingOff
        case 2...3: return .flying
        case 4: return .landing
        case 5: return .emergency
        default: return .landed
        }
    }

    static func initializing(value: UInt8) -> Bool {
        return value == 7
    }
}
