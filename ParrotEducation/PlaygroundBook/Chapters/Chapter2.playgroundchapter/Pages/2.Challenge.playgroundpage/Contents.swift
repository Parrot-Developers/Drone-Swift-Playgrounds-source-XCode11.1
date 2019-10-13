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
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, expected, success)
//#-code-completion(identifier, show, takeOff(), land(), wait(_:))
//#-code-completion(identifier, show, move(pitch:roll:gaz:yaw:duration:))
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Challenge:** Draw a spiral in the air.

 For the first advanced challenge, you will make the drone follow a spiral path in the air, on the vertical plane.
 A spiral consists of moving up and down while rotating at the same time. 
 You will be using only the complex move command!
 
 Create a function called `verticalTwister()`, composed of 2 subfunctions `twisterUp()` and `twisterDown()`.

*/
func twisterUp() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}

func twisterDown() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}

func verticalTwister() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}

//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.complexMove(nil, duration: nil), [
        NSLocalizedString("Try `move(pitch: 0, roll: 0, gaz: 20, yaw: 100, duration: 3)` command to move up and rotate at the same time.", comment: "Twister up hint")]),
    (.complexMove(nil, duration: nil), [
        NSLocalizedString("Try `move(pitch: 0, roll: 0, gaz: -20, yaw: 100, duration: 3)` command to move down and rotate at the same time.", comment: "Twister down hint")])
]
let success = NSLocalizedString(
    "### Congratulations!\nYou made your first advanced mission!\n\n[**Next Page**](@next)",
    comment: "complexchallenge success")
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
