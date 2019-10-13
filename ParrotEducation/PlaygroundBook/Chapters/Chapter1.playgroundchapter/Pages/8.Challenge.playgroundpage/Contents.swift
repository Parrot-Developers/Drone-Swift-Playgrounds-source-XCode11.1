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
//#-code-completion(identifier, show, takeOff(), land(), move(direction:duration:), ., wait(_:), turn(direction:angle:), for)
//#-code-completion(identifier, show, MoveDirection, TurnDirection, forward, backward, left, right)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Challenge:** Draw a square in the air. Again.

 For the second challenge, you will make the drone follow a square path in the air, but this time on the horizontal plane. You will create a [function](glossary://function) called `horizontalSquare()`, using only [pitch](glossary://pitch) and [yaw](glossary://yaw) commands. Also, you will be using a `for` [loop](glossary://loop) to simplify the code.
*/
func horizontalSquare() {
    //#-editable-code Add commands to your function
    
    //#-end-editable-code
}
//#-editable-code Tap to enter code

//#-end-editable-code
//#-hidden-code
let success = NSLocalizedString(
 "### Congratulations!\nYou achieved your second mission!\n\n[**Next Page**](@next)",
    comment: "challenge2 page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.all([
        .move(direction: nil, duration: nil),
        .turn(direction: nil, angle: nil),
        .move(direction: nil, duration: nil),
        .turn(direction: nil, angle: nil),
        .move(direction: nil, duration: nil),
        .turn(direction: nil, angle: nil),
        .move(direction: nil, duration: nil),
        ]),
     [NSLocalizedString("Try to move and turn by 90° four time", comment: "horizontal square hint1")]
    )]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
