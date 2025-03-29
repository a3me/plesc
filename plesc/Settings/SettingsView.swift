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
            VStack {
                if let user = viewModel.user {
                    VStack {
                        Text("Welcome, \(user.profile?.name ?? "User")")
                        if let imageUrl = user.profile?.imageURL(
                            withDimension: 100)
                        {
                            AsyncImage(url: imageUrl) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        }
                        Button("Sign Out") {
                            viewModel.signOut()
                        }
                        .padding()
                    }
                }
            }
            Form {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)

                Picker("App Language", selection: $selectedLanguage) {
                    Text("Polish").tag("Polish")
                    Text("English").tag("English")
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("Settings")
        }
    }
}
