//
//  LoginView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

class GoogleSignInViewModel: ObservableObject {
    @Published var user: GIDGoogleUser?

    func signIn() {
        guard
            let rootViewController = UIApplication.shared.windows.first?
                .rootViewController
        else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {
            [weak self] result, error in
            guard let result = result, error == nil else {
                print(
                    "Sign-in error: \(error?.localizedDescription ?? "Unknown error")"
                )
                return
            }

            result.user.refreshTokensIfNeeded { user, error in
                guard let user = user, error == nil, let idToken = user.idToken
                else { return }
                self?.login(accessToken: idToken.tokenString)
            }

            DispatchQueue.main.async {
                self?.user = result.user
            }
        }
    }

    func login(accessToken: String) {
        guard let authData = try? JSONEncoder().encode(["access_token": accessToken])
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

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        DispatchQueue.main.async {
            self.user = nil
        }
    }
}

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
