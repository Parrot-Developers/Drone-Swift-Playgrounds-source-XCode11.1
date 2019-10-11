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

// Action recorder and Assessor
public class Assessor {

    // an action and array of Hint strings
    public typealias Assessment = (Action, [String])

    // Assessable action
    public enum Action {
        case takeOff
        case land
        case speed(UInt?)
        case move(direction: MoveDirection?, duration: Int?)
        case complexMove(MoveParams?, duration: UInt?)
        case turn(direction: TurnDirection?, angle: UInt?)
        case flip(direction: FlipDirection?)
        case openGrabber
        case closeGrabber
        case fireCannon
        case takePicture
        // for expected action only: a set of action present is any order
        case allAnyOrder([Action])
        // for expected action only: a list of action in a single Assessment
        case all([Action])
    }

    // Recorded actions
    private var actions = [Action]()

    /// Add an action to the recorder
    ///
    /// - Parameter action: action to add
    public func add(action: Action) {
        actions.append(action)
    }

    /// This class can be constructed from playground page
    public init() {
    }

    /// Check that expected actions have been recorded
    ///
    /// - Parameters:
    ///   - expectedActions: array of expected assessment
    ///   - success: success message
    /// - Returns: AssessmentStatus
    public func check(expected expectedActions: [Assessment], success: String?)
        -> PlaygroundPage.AssessmentStatus {
            var actionsIdx = 0
            for expectedAction in expectedActions {
                if !checkExpectedAction(expected: expectedAction.0, actionIdx: &actionsIdx) {
                    return .fail(hints: expectedAction.1, solution: nil)
                }
            }
            return .pass(message: success)
    }

    private func checkExpectedAction(expected: Action, actionIdx: inout Int) -> Bool {
        while actionIdx < actions.count {
            let actual = actions[actionIdx]
            switch expected {
            case .allAnyOrder(let anyOrderActions):
                let startIdx = actionIdx
                var endIdx = actionIdx
                for action in anyOrderActions {
                    var found = false
                    while !found && actionIdx < actions.count {
                        if checkExpectedAction(expected: action, actionIdx: &actionIdx) {
                            found = true
                            // store last valid action idx, start from start pos
                            endIdx = max(endIdx, actionIdx)
                            actionIdx = startIdx
                        } else {
                            actionIdx += 1
                        }
                    }
                }
                if actionIdx < actions.count {
                    actionIdx = endIdx
                    return true
                }
            case .all(let allAction):
                for action in allAction {
                    var found = false
                    while !found && actionIdx < actions.count {
                        if checkExpectedAction(expected: action, actionIdx: &actionIdx) {
                            found = true
                        } else {
                            actionIdx += 1
                        }
                    }
                }
                if actionIdx < actions.count {
                    return true
                }
            default:
                if checkAction(expected: expected, actual: actual) {
                    actionIdx += 1
                    return true
                }
            }
            actionIdx += 1
        }
        return false
    }

    private func checkAction(expected: Action, actual: Action) -> Bool {
        switch expected {
        case .takeOff:
            if case .takeOff = actual {
                return true
            }
        case .land:
            if case .land = actual {
                return true
            }
        case let .speed(expectedSpeed):
            if case let .speed(speed) = actual, expectedSpeed == nil || expectedSpeed == speed {
                return true
            }
        case let .move(expectedDirection, expectedDuration):
            if case let .move(direction, duration) = actual,
                (expectedDirection == nil || expectedDirection == direction) &&
                    (expectedDuration == nil || expectedDuration == duration) {
                return true
            }
        case let .complexMove(expectedParams, expectedDuration) :
            if case let .complexMove(params, duration) = actual,
                (expectedParams == nil || expectedParams == params) &&
                    (expectedDuration == nil || expectedDuration! == duration) {
                return true
            }
        case let .turn(expectedDirection, expectedAngle):
            if case let .turn(direction, angle) = actual,
                (expectedDirection == nil || expectedDirection == direction) &&
                    (expectedAngle == nil || expectedAngle == angle) {
                return true
            }
        case let .flip(expectedDirection):
            if case let .flip(direction) = actual,
                expectedDirection == nil || expectedDirection == direction {
                return true
            }
        case .openGrabber:
            if case .openGrabber = actual {
                return true
            }
        case .closeGrabber:
            if case .closeGrabber = actual {
                return true
            }
        case .fireCannon:
            if case .fireCannon = actual {
                return true
            }
        case .takePicture:
            if case .takePicture = actual {
                return true
            }
        default: break
        }
        return false
    }
}
