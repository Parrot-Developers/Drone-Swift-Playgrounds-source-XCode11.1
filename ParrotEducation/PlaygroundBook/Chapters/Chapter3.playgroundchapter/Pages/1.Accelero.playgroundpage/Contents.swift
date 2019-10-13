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
droneSpeed = 30
startAssessor()
//#-code-completion(everything, hide)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Control your drone by tilting your iPad.

 You can use your iPad’s accelerometer to create a drone remote control!
 
 First, lock your iPad in landscape mode with the home button on your right. (To do this, swipe up from the bottom of the screen to open the Control Center and tap the Orientation Lock button.) The code below was written for an iPad with this orientation.
 
 Now you’re ready to try it out!
 
 1. steps: Place your drone on a flat surface with enough space around you.
 2. Place your iPad on a flat surface as well. This will help with sensor and data calibration.
 3. When you are ready, tap **Run My Code**.
 4. Grab your iPad and tilt it forward and backward. What do you observe?
*/
takeOff()
// run forever
while true {
    let event = waitNextMotionEvent()
    
    switch event {
    case .tiltForward:
        move(direction: MoveDirection.up, duration: 1)
    case .tiltBackward:
        move(direction: MoveDirection.down, duration: 1)
    default:
        break
    }
}

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!** You managed to understand how the iPad accelerometer works! Now it is time to create a drone remote control using code!!!!!\n\n[**Next Page**](@next)",
    comment: "iPadcontroller page success")

//#-end-hidden-code
