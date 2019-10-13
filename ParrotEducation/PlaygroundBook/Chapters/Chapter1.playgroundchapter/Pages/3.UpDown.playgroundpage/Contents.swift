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
//#-code-completion(identifier, show, takeOff(), land(), move(direction:duration:), ., wait(_:), .)
//#-code-completion(identifier, show, MoveDirection, up, down)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 **Goal:** Learn how to move up and down.

 In the drone world, this is called the [gaz](glossary://gaz) command.

 1. steps: Place your drone on a flat surface with enough space around you.
 2. The command to move in one direction is

 `move(direction: MoveDirection, duration: value)`

 For the [gaz](glossary://gaz) axis, direction is either `up` or `down`.

 ````
 move(direction: MoveDirection.up, duration: 2)
 ````
 The example above will move the drone up for 2 seconds.

 3. Try to **take off**, **move up** for 1 second, **wait** 4 seconds (using the `wait()` command), **move down** for 1 second, and **land**.
 4. When you are ready, tap **Run My Code**.
*/
//#-editable-code Tap to enter code
//#-end-editable-code

//#-hidden-code
let success = NSLocalizedString(
    "### Congratulations!\nYou know how to control gaz on your drone!\n\n[**Next Page**](@next)",
    comment: "UpDown page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.move(direction: .up, duration: nil), [
        NSLocalizedString("First you will move up using `move(direction: MoveDirection.up, duration: 1)`.", comment: "move(.up) hint1"),
        NSLocalizedString("Then you will move down using `move(direction: MoveDirection.down, duration: 1)`.", comment: "move(.up) hint2")
        ]),
    (.move(direction: .down, duration: nil), [
        NSLocalizedString("Use `move(direction: MoveDirection.down, duration: 1)` to move down.", comment: "move(.down) hint")
        ]),
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
