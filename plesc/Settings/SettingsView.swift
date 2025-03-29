//
//  SettingsView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var selectedLanguage = "Polish"
    @ObservedObject var viewModel: GoogleSignInViewModel

    var body: some View {
        NavigationStack {
            Form {
                if let user = viewModel.user {
                    HStack {
                        Text("Czesć \(user.profile?.name ?? "User")!")

                        Spacer()

                        if let imageUrl = user.profile?.imageURL(
                            withDimension: 40)
                        {
                            AsyncImage(url: imageUrl) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        }
                    }
                }

                Toggle("Enable Notifications", isOn: $notificationsEnabled)

                Picker("App Language", selection: $selectedLanguage) {
                    Text("Polish").tag("Polish")
                    Text("English").tag("English")
                }
                .pickerStyle(.segmented)

                Button(action: { viewModel.signOut() }) {
                    Text("Sign Out").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent).padding(.bottom, 2)
            }
            .navigationTitle("Settings")
        }
    }
}
