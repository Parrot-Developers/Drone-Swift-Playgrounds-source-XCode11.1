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
//#-code-completion(identifier, show, takeOff(), land(), wait(_:))
//#-code-completion(identifier, show, move(pitch:roll:gaz:yaw:duration:))
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to make complex moves.
  
 We learned the `move()` function, which allows you to move in one direction at a time.
 
 To move in multiple directions at the same time, there is another `move` function that takes all axes as parameters.
 
 Every [parameter](glossary://parameter) defines the move speed on its axis, and the rotation speed. The drone will move in all specified directions at the same time.
 
 `move(pitch:value, roll:value, gaz:value, yaw:value, duration:value)`
 
 ````
 move(pitch:20, roll:20, gaz:10, yaw:80, duration:2)
 ````
 
 1. steps: Place your drone on a flat surface with enough space around you.
 2. Try this above command first to see how the drone reacts, before making you own experiment.
 3. When you are ready, hit **Run My Code**.
 */
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!\nYou know how to use the complex move command!\n\n[**Next Page**](@next)",
    comment: "complexmove page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.complexMove(nil, duration: nil), [
        NSLocalizedString("Try the command `move(pitch:20, roll:20, gaz:10, yaw:80, duration:2)`", comment: "complex move hint")
        ]),
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
