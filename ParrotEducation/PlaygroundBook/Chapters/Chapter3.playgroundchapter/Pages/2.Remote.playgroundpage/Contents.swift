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
//#-code-completion(identifier, show, waitNextMotionEvent())
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Challenge:** Control the drone using your iPad as a controller.
 
 For this ultimate challenge, you'll write code to transform your iPad into a remote control!
 
 On the previous page, you saw how to move your drone up and down by tilting your iPad forward and backward. Now you can add many more actions and decide how your drone responds to them!
 
 The different states available to control the drone are:
 ````
MotionEvent {
 case flat
 case tiltForward
 case tiltBackward
 case tiltLeft
 case tiltRight
 case shakeUp
 case shakeDown
 }
 ````
 The function `waitNextMotionEvent()` returns one of those states.
 
 Following the example on the previous page, write code using a while loop and a switch statement that moves the drone in a direction according to the motion of your iPad. You can even use the shake detection to initiate a flip!
 */
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!** You created a drone controller using code!!!!!\n\n",
    comment: "iPadcontroller page success")

//#-end-hidden-code
