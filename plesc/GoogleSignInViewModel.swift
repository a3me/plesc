//
//  GoogleSignInViewModel.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

class GoogleSignInViewModel: ObservableObject {
    @Published var user: GIDGoogleUser? = nil

    init() {
        restorePreviousSignIn()
    }

    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn {
            [weak self] user, error in
            if let error = error {
                print("Restore sign-in failed: \(error.localizedDescription)")
            } else {
                self?.user = user
                self?.getJWT(
                    googleAccessToken: user?.idToken?.tokenString ?? "")
            }
        }
    }

    func signIn() {
        guard
            let rootViewController = UIApplication.shared.windows.first?
                .rootViewController
        else {
            print("No root view controller found")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {
            [weak self] signInResult, error in
            if let error = error {
                print("Sign-in failed: \(error.localizedDescription)")
            } else {
                self?.user = signInResult?.user
                self?.getJWT(
                    googleAccessToken: signInResult?.user.idToken?.tokenString
                        ?? "")
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        user = nil
    }

    func getJWT(googleAccessToken: String) {
        guard !googleAccessToken.isEmpty else { return }
        guard
            let authData = try? JSONEncoder().encode([
                "access_token": googleAccessToken
            ])
        else { return }
        let url = URL(string: "https://plesc.a3p.re/auth/login/google")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: authData) {
            data, response, error in
            print(
                "AUTH | auth_login_google | \(String(data: data ?? Data(), encoding: .utf8) ?? "No data")"
            )
        }
        task.resume()
    }
}
