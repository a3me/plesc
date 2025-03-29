//
//  SplashView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Text("Pleść")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
