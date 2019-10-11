// Copyright (C) 2016-17 Parrot SA
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

/// Defines the speed at which the drone must move and turn
public struct MoveParams: Equatable {
    /// Speed on the drone longitudinal direction, in %. Positive values make the drone move forward,
    /// negative values make the drone move backward
    public let longitudinalSpeed: Int
    /// Speed on the drone lateral direction, in %. Positive values make the drone move right,
    /// negative values make the drone move left
    public let lateralSpeed: Int
    ///Vertical speed, in %. Positive values make the drone move up, negative values make the drone move down
    public let verticalSpeed: Int
    /// Rotation speed, in %. Positive values make the drone turn clockwise, negative values make the
    /// drone turn counterclockwise
    public let rotationSpeed: Int

    /// Create a `MoveParams` instance
    ///
    /// - Parameters:
    ///   - longitudinalSpeed: Speed on the drone longitudinal direction, in %.
    ///      Positive values makes the drone move forward, negative values make the drone move backward
    ///   - lateralSpeed: Speed on the drone lateral direction, in %. Positive value make the drone move right,
    ///      negative values make the drone move left
    ///   - verticalSpeed: Vertical speed, in %. Positive values make the drone move up,
    ///      negative values make the drone move down
    ///   - rotationSpeed: Rotation speed, in %. Positive values make the drone turn clockwise, negative values make
    ///      the drone turn counterclockwise
    public init(longitudinalSpeed: Int=0, lateralSpeed: Int=0, verticalSpeed: Int=0, rotationSpeed: Int=0) {
        self.longitudinalSpeed = longitudinalSpeed
        self.lateralSpeed = lateralSpeed
        self.verticalSpeed = verticalSpeed
        self.rotationSpeed = rotationSpeed
    }
}

/// Comparator
public func == (lhs: MoveParams, rhs: MoveParams) -> Bool {
    return lhs.longitudinalSpeed == rhs.longitudinalSpeed &&
        lhs.lateralSpeed == rhs.lateralSpeed &&
        lhs.verticalSpeed == rhs.verticalSpeed &&
        lhs.rotationSpeed == rhs.rotationSpeed
}
