//
//  plescApp.swift
//  plesc
//
//  Created by Matt Ball on 27/03/2025.
//
import GoogleSignIn
import SwiftUI

@main
struct plescApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = GoogleSignInViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
