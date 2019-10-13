//#-hidden-code
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
//             Jerome BOUVARD, <jerome.bouvard@parrot.com>

import UIKit
import PlaygroundSupport

waitDroneConnected()
droneSpeed = 30
startAssessor()
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), turn(direction:angle:), ., wait(_:), .)
//#-code-completion(identifier, show, TurnDirection, left, right)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to make a rotation.
 
 In the drone world, this is called the [yaw](glossary://yaw) axis.

 1. steps: Place your drone on a flat surface with enough space around you.
 2. The command to rotate in one direction is

 `turn(direction: TurnDirection, angle: value)`

 For the [yaw](glossary://yaw) axis, direction is either `left` (counterclockwise) or `right` (clockwise).
 
 ````
 turn(direction: TurnDirection.left, angle: 180)
 ````
 The example above will make the drone turn 180 degrees counterclockwise.

 3. Try to **take off**, make a **180° clockwise turn**, then a **180° counterclockwise turn**, and finally **land**.
 4. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!\nYou know how to use the yaw command!\n\n[**Next Page**](@next)",
    comment: "Rotate page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.turn(direction: .right, angle: 180), [
        NSLocalizedString("First you will turn clockwise using `turn(direction: TurnDirection.right, angle: 180)`.", comment: "turn(.right) hint1"),
        NSLocalizedString("Then you will turn counterclockwise using `turn(direction: TurnDirection.left, angle: 180`.", comment: "turn(.right) hint2")
        ]),
    (.turn(direction: .left, angle: 180), [
        NSLocalizedString("Use `turn(direction TurnDirection.left, angle: 180)` to turn counterclockwise.", comment: "turn(.left) hint")
        ]),
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
