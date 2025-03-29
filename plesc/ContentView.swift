import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: GoogleSignInViewModel
    @State private var showSplash = true

    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSplash = false
                    }
                }
        } else {
            if viewModel.user == nil {
                LoginView(viewModel: viewModel)
            } else {
                MainTabView(viewModel: viewModel)
            }
        }
    }
}
