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
import CoreBluetooth
import PlaygroundBluetooth

///
/// Delegate notified of ble connection
///
protocol DroneBleDelegate: class {
    func droneBleDidConnect()
    func droneBleDidDisconnect()
}

///
/// Ble for Minidrone
///
class DroneBle: NSObject {

    /// Sender types, controller side view
    enum SenderType {
        /// commands without ack
        case cmdNoAck
        /// command with ack
        case cmdAck
        /// ack of reveiced events
        case evtAck
    }

    /// Reciver types, controller side view
    enum ReceiverType {
        /// events without ack
        case evtNoAck
        /// events ack
        case evtAck
        /// ack of sent commands
        case cmdAck
    }

    /// Sender to write on a characteristics
    class Sender {
        private let characteristic: CBCharacteristic

        init (characteristic: CBCharacteristic) {
            self.characteristic = characteristic
        }

        func write(data: Data) {
            characteristic.service.peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }

    /// Receiver on a characteristics
    class Receiver {
        private let characteristic: CBCharacteristic

        /// delegate bloc to process received data
        var processor: ((Data) -> Void)?

        init (characteristic: CBCharacteristic) {
            self.characteristic = characteristic
            characteristic.service.peripheral.setNotifyValue(true, for: self.characteristic)
        }

        func receive(data: Data) {
            processor?(data)
        }
    }

    /// Bluetooth central manager state
    enum State {
        case bluetoothOff
        case searching
        case bluetoothConnecting
        case connecting
        case connected
        case disconnecting
        case error
    }

    /// Parrot manufacturer data
    fileprivate static let parrotBleManufacturerData = Data(_: [0x43, 0x00, 0xCF, 0x19])
    /// playground bluetooth central manager
    var btManager: PlaygroundBluetoothCentralManager!
    /// delegate
    fileprivate weak var delegate: DroneBleDelegate?

    /// Managed drone bluetooth peripheral
    fileprivate (set) var peripheral: CBPeripheral?
    /// keep list of discovered devices models, by uuid
    fileprivate var models = [String: Model]()
    /// sender service
    fileprivate var sendService: CBService?
    /// receiver service
    fileprivate var recvService: CBService?
    /// All senders by type
    var senders: [SenderType:Sender] = [:]
    /// All receivers by type
    var receivers: [ReceiverType:Receiver] = [:]
    /// Current drone name (from discovery manufacturer data)
    var droneName: String? {
        return peripheral?.name
    }
    /// Current drone model (from discovery manufacturer data)
    fileprivate (set) var droneModel: Model?
    /// Current drone uuid
    var droneUuid: UUID? {
        return peripheral?.identifier
    }

    /// Constructor
    ///
    /// - Parameters:
    ///   - queue: queue to run ble drone
    ///   - delegate: delegate
    init(queue: DispatchQueue, delegate: DroneBleDelegate) {
        self.delegate = delegate
        super.init()
        btManager = PlaygroundBluetoothCentralManager(services: nil, queue: queue)
        btManager.delegate = self
    }
}

extension DroneBle: PlaygroundBluetoothCentralManagerDelegate {
    public func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {
        // Handle Bluetooth state changes.
    }

    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               withAdvertisementData advertisementData: [String : Any]?, rssi: Double) {
        // Handle peripheral discovery.
        if let advertisementData = advertisementData,
            let model = DroneBle.modelFrom(advertisementData: advertisementData) {
            models[peripheral.identifier.uuidString] = model
        }
    }

    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                               willConnectTo peripheral: CBPeripheral) {
        // Handle peripheral connection attempts (prior to connection being made).
    }

    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                               didConnectTo peripheral: CBPeripheral) {
        // Handle successful peripheral connection.
        self.peripheral = peripheral
        if let model = models[peripheral.identifier.uuidString] {
            self.droneModel = model
        } else {
            self.droneModel = myDrone?.model
        }
        peripheral.delegate = self
        peripheral.discoverServices([.sendService, .recvService])
    }

    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                               didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
        // Handle failed peripheral connection.
    }

    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager,
                               didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        // Handle peripheral disconnection.
        self.peripheral = nil
        delegate?.droneBleDidDisconnect()
    }

    func setModel(_ model: Model, forPeripheral peripheral: CBPeripheral) {
        models[peripheral.identifier.uuidString] = model
    }

    static func modelFrom(advertisementData: [String : Any]) -> Model? {
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            if manufacturerData.starts(with: parrotBleManufacturerData) &&  manufacturerData.count >= 6 {
                return Model(rawValue: manufacturerData[4])
            }
        }
        return nil
    }
}

/// Peripheral delegate
extension DroneBle: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            switch service.uuid {
            case CBUUID.sendService:
                sendService = service
                peripheral.discoverCharacteristics([.sendCmdWithAck, .sendCmdNoAck, .sendEvtAck], for: service)
                break
            case CBUUID.recvService:
                recvService = service
                peripheral.discoverCharacteristics([.recvEvtNoAck, .recvEvtWithAck, .recvCmdAck], for: service)
                break
            default:
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if sendService?.characteristics != nil && recvService?.characteristics != nil {
            // Senders
            if let characteristic = sendService?.characteristic(withUid: .sendCmdNoAck) {
                senders[.cmdNoAck] = Sender(characteristic: characteristic)
            }
            if let characteristic = sendService?.characteristic(withUid: .sendCmdWithAck) {
                senders[.cmdAck] = Sender(characteristic: characteristic)
            }
            if let characteristic = sendService?.characteristic(withUid: .sendEvtAck) {
                senders[.evtAck] = Sender(characteristic: characteristic)
            }
            // Receivers
            if let characteristic = recvService?.characteristic(withUid: .recvEvtNoAck) {
                receivers[.evtNoAck] = Receiver(characteristic: characteristic)
            }
            if let characteristic = recvService?.characteristic(withUid: .recvEvtWithAck) {
                receivers[.evtAck] = Receiver(characteristic: characteristic)
            }
            if let characteristic = recvService?.characteristic(withUid: .recvCmdAck) {
                receivers[.cmdAck] = Receiver(characteristic: characteristic)
            }

            delegate?.droneBleDidConnect()
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            switch characteristic.uuid {
            case CBUUID.recvEvtNoAck:
                receivers[.evtNoAck]?.receive(data: value)
            case CBUUID.recvEvtWithAck:
                receivers[.evtAck]?.receive(data: value)
            case CBUUID.recvCmdAck:
                receivers[.cmdAck]?.receive(data: value)
            default:
                break
            }
        }
    }
}

extension CBUUID {
    /// services
    @nonobjc static let sendService = CBUUID(string:"9A66FA00-0800-9191-11E4-012D1540CB8E")
    @nonobjc static let recvService = CBUUID(string:"9A66FB00-0800-9191-11E4-012D1540CB8E")

    /// characteristics
    @nonobjc static let sendCmdNoAck = CBUUID(string:"9A66FA0A-0800-9191-11E4-012D1540CB8E")
    @nonobjc static let sendCmdWithAck = CBUUID(string:"9A66FA0B-0800-9191-11E4-012D1540CB8E")
    @nonobjc static let sendEvtAck = CBUUID(string:"9A66FA1E-0800-9191-11E4-012D1540CB8E")
    @nonobjc static let recvEvtWithAck = CBUUID(string:"9A66FB0E-0800-9191-11E4-012D1540CB8E")
    @nonobjc static let recvEvtNoAck = CBUUID(string:"9A66FB0F-0800-9191-11E4-012D1540CB8E")
    @nonobjc static let recvCmdAck = CBUUID(string:"9A66FB1B-0800-9191-11E4-012D1540CB8E")
}

/// Extension of CBService ot find a characteristic by UUID
extension CBService {
    func characteristic(withUid uid: CBUUID) -> CBCharacteristic? {
        if let idx = characteristics?.firstIndex(where: {$0.uuid == uid}) {
            return characteristics?[idx]
        }
        return nil
    }
}
