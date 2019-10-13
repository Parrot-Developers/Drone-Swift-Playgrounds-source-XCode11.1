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
//#-code-completion(identifier, show, takeOff(), land(), wait(_:), .)
//#-code-completion(identifier, show, turn(direction:angle:), TurnDirection, left, right)
//#-code-completion(identifier, show, move(pitch:roll:gaz:yaw:duration:), move(direction:duration:), move(direction:), stopMoving(), MoveDirection, forward, backward, left, right, up, down)
//#-code-completion(identifier, show, flip(direction:), FlipDirection, front, back, left, right)
//#-code-completion(identifier, show, openGrabber(), closeGrabber())
//#-code-completion(identifier, show, takePicture())
//#-code-completion(identifier, show, if, for, while, let, func)

//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Challenge:** Create your own flight plan.
 
 Now it’s time to put it all together and navigate your drone just like a pilot.
 First select a destination. Then create two different flight plans to get there.
 
 The first one should be the fatest and most direct way to get from point A to point B where your drone can fly at top speed most of the way.
 
 The second should be a path where your drone would be the least detected, so it may need to adjust speed or do extra flips to avoid detection.
 
 Between your two flight plans, make sure you:
 1) Include at least 3 different simple moves and 1 complex move.
 2) Experiment with different speeds.
 3) Be sure to include functions and loops in your code.
*/
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!\nYou created your first complex flight plan!\n\n[**Next Page**](@next)",
    comment: "advancedflightplan page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.allAnyOrder([
        .all([.move(direction: nil, duration: nil), .move(direction: nil, duration: nil), .move(direction: nil, duration: nil)]),
        .complexMove(nil, duration: nil),
        .speed(nil)
        ]), [NSLocalizedString("Be sure to include 3 simple moves and 1 complex move.", comment: "last challenge hint")])
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
