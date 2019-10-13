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
//#-code-completion(identifier, show, droneSpeed, takeOff(), land(), move(direction:duration:), wait(_:), ., =)
//#-code-completion(identifier, show, MoveDirection, forward, backward)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to control speed.

 1. steps: Place your drone on a flat surface with enough space around you.
 2. The command to change the speed of the drone is

 `droneSpeed = value`

 The [variable](glossary://variable) represents the percentage of the drone max speed: **50** is half speed, **100** is full speed.

 4. Try to move forward 2 seconds at 10%, then backward 2 seconds at 10%
 5. Without landing, try again, this time at 80%.
 6. Think about how you will be using that later to modify your flights.
 7. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!\nYou know how to change the speed of your drone!\n\n[**Next Page**](@next)",
    comment: "Speed page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.speed(nil), [
        NSLocalizedString("Use `droneSpeed = value<0..100>` to change the drone speed.", comment: "droneSpeed hint")
        ])
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
