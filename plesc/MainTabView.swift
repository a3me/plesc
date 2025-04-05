//
//  MainTabView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: GoogleSignInViewModel
    
    var body: some View {
        TabView {
            ChatListView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
