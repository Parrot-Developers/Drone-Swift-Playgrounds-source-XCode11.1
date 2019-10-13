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
//#-code-completion(identifier, show, takeOff(), land(), wait(_:), flip(direction:), .)
//#-code-completion(identifier, show, front, back, left, right, FlipDirection)
//#-code-completion(for)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to make flips.

 1. steps: Place your drone on a flat surface with enough space around you.
 2. To make a flip, you will use the command

 `flip(direction: FlipDirection)`

 Direction can be `front`, `back`, `left` and `right`.
 
 ````
 flip(direction: FlipDirection.back)
 ````
 The example above will make the drone do a backflip.

 3. Using a ‘for’ loop, try to make a **flip** 2 times in 2 directions of your choice.
 4. When you are ready, hit **Run My Code**.
 
 **Important:**
 The drone will not flip if the battery is below 20% or if there are any accessories attached.
*/
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!\nYou made your first flip!\n\n[**Next Page**](@next)",
    comment: "Flip page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flip(direction: nil), [
        NSLocalizedString("To make a front flip, you need to use: `flip(direction: FlipDirection.front)`", comment: "flip(.front) hint")
        ])
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success:success)
//#-end-hidden-code

