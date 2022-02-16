//
//  UserHelpNudge.swift
//  Covet
//
//  Created by Covet on 2/16/22.
//

import SwiftUI

class UserHelpNudgeKeys {
    
    static var nudges = [
        "LONG_PRESS_USER_FOR_OPTIONS"
    ]
    
    static var LONG_PRESS_USER_FOR_OPTIONS = nudges[0]
    
    static func shouldShow(nudge: String) -> Bool {
        return currentValue(nudge: nudge) <= currentAppCountLaunchNumber()
    }
    
    static func currentValue(nudge: String) -> Int {
        return Defaults.sharedSuite.integer(forKey: keyFor(string: nudge))
    }
    
    static func delay(string: String, amount: Int = 5) {
        Defaults.sharedSuite.set(
            currentAppCountLaunchNumber() + amount,
            forKey: keyFor(string: string)
        )
    }
    
    static func keyFor(string: String) -> String {
        return "SHOW_AT_APP_LAUNCH_NUMBER_" + string
    }
    
    static func setup() {
        if Defaults.sharedSuite.value(forKey: "APP_LAUNCH_NUMBER") == nil {
            Defaults.sharedSuite.set(0, forKey: "APP_LAUNCH_NUMBER")
        } else {
            Defaults.sharedSuite.set(
                currentAppCountLaunchNumber() + 1,
                forKey: "APP_LAUNCH_NUMBER"
            )
        }
        print("Launch number: " + String(self.currentAppCountLaunchNumber()))
    }
    
    static func resetAll() {
        Defaults.sharedSuite.set(nil, forKey: "APP_LAUNCH_NUMBER")
        for n in nudges {
            Defaults.sharedSuite.set(nil, forKey: keyFor(string: n))
        }
    }
    
    static func currentAppCountLaunchNumber() -> Int {
        return Defaults.sharedSuite.integer(forKey: "APP_LAUNCH_NUMBER")
    }

}

struct UserHelpNudge: View {
    
    var key: String
    var message: String
    
    @State var hiddenNow: Bool = false
    
    var body: some View {
        if UserHelpNudgeKeys.shouldShow(nudge: key) && !hiddenNow {
            VStack {
                HStack {
                    Spacer().frame(width: 16)
                    Image(systemName: "lightbulb")
                        .foregroundColor(Color.white)
                    Spacer().frame(width: 8)
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white)
                    Spacer()
                    Spacer().frame(width: 8)
                }
                Text("Tap to hide for a while")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white)
            }
            .frame(height: 50)
            .background(Color.covetGreen())
            .onTapGesture {
                UserHelpNudgeKeys.delay(string: key, amount: 5)
                self.hiddenNow = true
            }
        }
    }
}

struct UserLongPressHelpNudge: View {
    var body: some View {
        UserHelpNudge(
            key: UserHelpNudgeKeys.LONG_PRESS_USER_FOR_OPTIONS,
            message: "Hold down on a user's name to show options"
        )
    }
}
