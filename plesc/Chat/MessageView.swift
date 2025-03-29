//
//  MessageView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import SwiftUI
import Translation

struct MessageView: View {
    var message: String
    var isCurrentUser: Bool
    var isFirst: Bool

    @State private var showTranslation: Bool = false

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }  // Push user messages to the right

            Text(message)
                .foregroundColor(isCurrentUser ? .white : .primary)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    isCurrentUser
                        ? .blue : Color(uiColor: .secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .background(
                    alignment: isCurrentUser ? .bottomTrailing : .bottomLeading

                ) {
                    isFirst
                        ? Image(isCurrentUser ? "outgoingTail" : "incomingTail")
                            .renderingMode(.template)
                            .foregroundStyle(
                                isCurrentUser
                                    ? .blue
                                    : Color(uiColor: .secondarySystemBackground)
                            )
                            .offset(x: isCurrentUser ? -3 : 3, y: 0)
                        : nil
                }
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = message
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    Button(action: {
                        showTranslation = true
                    }) {
                        Label("Translate", systemImage: "globe")
                    }
                }

            if !isCurrentUser { Spacer() }  // Push bot messages to left
        }.translationPresentation(isPresented: $showTranslation, text: message)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(
            message: "This is a test message", isCurrentUser: false,
            isFirst: true
        )
        .previewLayout(.fixed(width: 400, height: 140))
        MessageView(
            message:
                "Can we already say how long their space will take? (Not in it anymore)",
            isCurrentUser: true, isFirst: true
        )
        .previewLayout(.fixed(width: 400, height: 140))
        MessageView(
            message: "This is a test message", isCurrentUser: false,
            isFirst: true
        )
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 400, height: 140))
        MessageView(
            message: "This is a test message", isCurrentUser: true,
            isFirst: true
        )
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 400, height: 140))
    }
}
