//
//  ChatView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import SwiftUI

struct ChatView: View {

    let chatId: String
    @State var chat: Chat? = nil

    @State var chatMessages: [ChatMessage] = []

    @State private var newMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            if chatMessages.isEmpty {
                                Spacer()  // Keeps ScrollView tappable when empty
                            } else {
                                ForEach(chatMessages, id: \.content) {
                                    message in
                                    MessageView(
                                        message: message.content.trimmingCharacters(
                                            in: .whitespacesAndNewlines
                                        ),
                                        isCurrentUser: message.role == "user",
                                        isFirst: true
                                    )
                                    .id(message.content)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .onTapGesture {
                        dismissKeyboard()
                    }
                }

                // Message input view
                MessageInputView(newMessage: $newMessage, onSend: sendMessage)
            }
            .padding(.horizontal)
            .navigationTitle("Chat with Pleść")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadChat()
        }
    }

    private func loadChat() {
        PlescAPI.getChat(chatId: chatId) { chat in
            print(
                "Loaded chat: \(chat), messages: \(chat.messages), id: \(chatId)"
            )
            self.chat = chat
            self.chatMessages = chat.messages
        }
    }

    private func sendMessage() {
        if let chat = chat {
            let trimmedMessage = newMessage.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            guard !trimmedMessage.isEmpty else { return }

            let userChatMessage = ChatMessage(
                content: trimmedMessage,
                role: "user",
                timestamp: Date()
            )
            chatMessages.append(userChatMessage)

            newMessage = ""  // Clear input field

            PlescAPI.sendChatMessage(chatId: chatId, message: trimmedMessage) {
                messageResponse in
                let newChatMessage = ChatMessage(
                    content: messageResponse.response.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    role: "assistant",
                    timestamp: Date()
                )
                chatMessages.append(newChatMessage)
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct MessageInputView: View {
    @Binding var newMessage: String
    let onSend: () -> Void

    var body: some View {
        HStack {
            TextField("Pleść", text: $newMessage)
                .textFieldStyle(.roundedBorder)

            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)  // Disable when empty
        }
        .padding(.bottom)
    }
}

struct LoadingView: View {
    var body: some View {
        Text("Loading...")
            .font(.headline)
            .foregroundColor(.gray)
    }
}
