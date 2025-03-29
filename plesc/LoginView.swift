//
//  LoginView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: GoogleSignInViewModel

    var body: some View {
        VStack {
            Text("Pleść")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Please sign in to use Pleść")
                .font(.subheadline)
                .foregroundColor(.white)
            GoogleSignInButton(action: viewModel.signIn)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
