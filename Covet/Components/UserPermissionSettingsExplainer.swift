//
//  UserPermissionSettingsExplainer.swift
//  Covet
//
//  Created by Covet on 2/3/22.
//

import SwiftUI

struct UserPermissionSettingsExplainer: View {
    
    var privateForFollowing: Bool = false
    var privateForFriending: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("See my posts in search")
                    makeChip(
                        permissionsAvailableToAll: !privateForFollowing && !privateForFollowing,
                        permissionAvailableToFollowers: true,
                        permissionsAvailableToFriends: true
                    )
                }
                makeWarnings(permissionAvailableToFollowers: true, permissionsAvailableToFriends: true)
            }
            .padding(.vertical, 4)
            HStack {
                Text("See my posts in their feed")
                makeChip(
                    permissionsAvailableToAll: false,
                    permissionAvailableToFollowers: true,
                    permissionsAvailableToFriends: true
                )
            }
            .padding(.vertical, 4)
            VStack {
                HStack {
                    Text("See my address to buy me things")
                    makeChip(
                        permissionsAvailableToAll: false,
                        permissionAvailableToFollowers: false,
                        permissionsAvailableToFriends: true
                    )
                }
                makeWarnings(permissionAvailableToFollowers: false, permissionsAvailableToFriends: true)
            }
            .padding(.vertical, 4)
        }
    }
    
    func makeAnyoneChip() -> some View {
        return Chip(preIcon: "globe", text: "Anyone", color: Color.blue)
    }

    func makeChip(permissionsAvailableToAll: Bool, permissionAvailableToFollowers: Bool, permissionsAvailableToFriends: Bool) -> some View {
        return Group {
            if permissionsAvailableToAll {
                Chip(preIcon: "globe", text: "Anyone", color: Color.blue)
            } else {
                if permissionAvailableToFollowers {
                    Chip(preIcon: "person.fill", text: "Followers", color: Color.blue)
                }
                if permissionsAvailableToFriends {
                    Chip(preIcon: "person.2.fill", text: "Friends", color: Color.blue)
                }
            }
        }
    }

    func makeWarnings(permissionAvailableToFollowers: Bool, permissionsAvailableToFriends: Bool) -> some View {
        return Group {
            if permissionAvailableToFollowers {
                if !privateForFollowing && privateForFriending {
                    Chip(preIcon: "exclamationmark.circle.fill", text: "Anyone can follow you without your approval", color: Color.yellow)
                }
                if !privateForFollowing && !privateForFriending {
                    Chip(preIcon: "exclamationmark.circle.fill", text: "Anyone can follow or friend you without your approval", color: Color.yellow)
                }
            }
            else if permissionsAvailableToFriends {
                if !privateForFriending {
                    Chip(preIcon: "exclamationmark.circle.fill", text: "Anyone can follow or friend you without your approval", color: Color.yellow)
                }
            }
        }
    }

    
}
