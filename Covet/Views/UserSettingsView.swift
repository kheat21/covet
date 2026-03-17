//
//  UserSettingsView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import AlertToast
import Firebase
import SwiftUI

enum UserSettingsViewPresentationOptions {
    case NewSignup
    case Modify
}

enum UserProfileOperationState {
    case None
    case CreatingProfile
    case CreatedProfile
    case FailedToCreateProfile
    case UpdatingProfile
    case UpdatedProfile
    case FailedToUpdateProfile
}

struct UserSettingsView: View {

    @EnvironmentObject var auth: AuthService

    var mode: UserSettingsViewPresentationOptions

    @State var actionState: UserProfileOperationState = .None
    @State var showLoadingToast: Bool = false
    @State var showProfileCreationErrorToast: Bool = false
    @State var errorToastExplanation: String? = nil
    @State var profile: CovetUser?

    @State var handle: String
    @State var name: String

    @State var shoeSize: String = ""
    @State var ringSize: String = ""
    @State var jeansSize: String = ""
    @State var dressSize: String = ""
    @State var topSize: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Avatar
                CovetC(size: 72, text: nameToInitials(str: $name.wrappedValue))
                    .padding(.top, 24)
                    .padding(.bottom, 28)

                // Profile fields
                VStack(spacing: 0) {
                    if mode == .NewSignup {
                        ProfileFieldRow(label: "Username", text: $handle,
                                        autocapitalization: .none, autocorrect: false)
                        Divider().padding(.leading, 16)
                    }
                    ProfileFieldRow(label: "Name", text: $name)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5), lineWidth: 1))
                .padding(.horizontal, 20)

                // My Sizes section
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "ruler")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.covetGreen())
                        VStack(alignment: .leading, spacing: 1) {
                            Text("My Sizes")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Helps friends find the perfect gift")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        SizeInputCell(label: "SHOES",  text: $shoeSize)
                        SizeInputCell(label: "RING",   text: $ringSize)
                        SizeInputCell(label: "JEANS",  text: $jeansSize)
                        SizeInputCell(label: "DRESS",  text: $dressSize)
                        SizeInputCell(label: "TOP",    text: $topSize)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer(minLength: 32)

                // Save button
                if actionState == .None {
                    Button(action: {
                        if self.mode == .NewSignup {
                            self.createProfile()
                        } else {
                            self.updateProfile()
                        }
                    }) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundColor(.white)
                            .background(isInputComplete() ? Color.covetGreen() : Color.covetGreen().opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isInputComplete())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear { loadSizesFromProfile() }
        .toast(isPresenting: $showLoadingToast) {
            AlertToast(type: .loading, title: getToastWorkingText(), subTitle: nil)
        }
        .toast(isPresenting: $showProfileCreationErrorToast) {
            AlertToast(type: .error(Color.red), title: "Oops!",
                       subTitle: "We weren't able to make your profile")
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Your Covet Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                self.mode == .NewSignup ? (
                    AnyView(Button(action: { auth.logout() }) {
                        Text("Logout").foregroundColor(Color.covetGreen())
                    })
                ) : AnyView(EmptyView())
            }
        }
    }

    private func loadSizesFromProfile() {
        if let user = auth.currentCovetUser {
            shoeSize  = user.shoe_size  ?? ""
            ringSize  = user.ring_size  ?? ""
            jeansSize = user.jeans_size ?? ""
            dressSize = user.dress_size ?? ""
            topSize   = user.top_size   ?? ""
        }
    }

    func getToastWorkingText() -> String {
        return self.mode == .NewSignup ? "Creating Profile" : "Updating Profile"
    }

    func isInputComplete() -> Bool {
        var complete = true
        if self.mode == .NewSignup {
            complete = complete && self.$handle.wrappedValue.count >= 3
        }
        complete = complete && self.$name.wrappedValue.count >= 1
        return complete
    }

    private func createProfile() {
        Task.detached {
            await self.updateUI(showLoadingToast: true, actionState: .CreatingProfile, profile: nil, errorToast: false)
            var usr: CovetUser? = nil
            do {
                let createdProfile = try await API.createProfile(
                    username: handle,
                    name: name,
                    bio: nil,
                    birthday: nil,
                    address: nil,
                    privateForFollowing: 0,
                    privateForFriending: 1
                )
                if createdProfile != nil { usr = createdProfile }
            } catch { print(error) }
            await self.updateUI(
                showLoadingToast: false,
                actionState: usr == nil ? .FailedToCreateProfile : .CreatedProfile,
                profile: usr,
                errorToast: usr == nil
            )
        }
    }

    private func updateProfile() {
        Task.detached {
            await self.updateUI(showLoadingToast: true, actionState: .UpdatingProfile, profile: nil, errorToast: false)
            var usr: CovetUser? = nil
            do {
                let createdProfile = try await API.updateProfile(
                    originalUser: auth.currentCovetUser!,
                    name: name,
                    bio: nil,
                    birthday: nil,
                    address: nil,
                    privateForFollowing: 0,
                    privateForFriending: 1,
                    shoeSize:  shoeSize.isEmpty  ? nil : shoeSize,
                    ringSize:  ringSize.isEmpty  ? nil : ringSize,
                    jeansSize: jeansSize.isEmpty ? nil : jeansSize,
                    dressSize: dressSize.isEmpty ? nil : dressSize,
                    topSize:   topSize.isEmpty   ? nil : topSize
                )
                if createdProfile != nil { usr = createdProfile }
            } catch { print(error) }
            await self.updateUI(
                showLoadingToast: false,
                actionState: usr == nil ? .FailedToUpdateProfile : .UpdatedProfile,
                profile: usr == nil ? (self.profile ?? nil) : usr,
                errorToast: usr == nil
            )
        }
    }

    private func updateUI(showLoadingToast: Bool, actionState: UserProfileOperationState, profile: CovetUser?, errorToast: Bool) async {
        self.showLoadingToast = showLoadingToast
        self.actionState = actionState
        self.profile = profile
        self.showProfileCreationErrorToast = errorToast
        auth.refreshUser(first: true)
    }
}

// MARK: - Subviews

struct ProfileFieldRow: View {
    let label: String
    @Binding var text: String
    var autocapitalization: UITextAutocapitalizationType = .words
    var autocorrect: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)
            TextField("", text: $text)
                .font(.system(size: 15))
                .autocapitalization(autocapitalization)
                .disableAutocorrection(!autocorrect)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct SizeInputCell: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)
            TextField("—", text: $text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .keyboardType(.default)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Helpers

func nameToInitials(str: String) -> String {
    let components = str.components(separatedBy: " ").filter { $0.count > 0 }
    if components.count == 0 { return "" }
    else if components.count == 1 { return components[0].firstCharacter().uppercased() }
    else {
        return components[0].firstCharacter().uppercased() +
               components[components.count - 1].firstCharacter().uppercased()
    }
}

func getInitials(str: String) -> String {
    let components = str.components(separatedBy: " ").filter { $0.count > 0 }
    if components.count == 0 { return "" }
    else if components.count == 1 {
        return components[0].count == 1
            ? components[0].firstCharacter().uppercased()
            : components[0].firstNCharacters(n: 2).uppercased()
    } else {
        return components[0].firstCharacter().uppercased() +
               components[components.count - 1].firstCharacter().uppercased()
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView(mode: .NewSignup, handle: "@kate", name: "Kate Heatzig")
    }
}
