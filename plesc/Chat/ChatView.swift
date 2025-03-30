//
//  ChatView.swift
//  plesc
//
//  Created by Matt Ball on 29/03/2025.
//
import SwiftUI

struct Message: Identifiable {
    let id = UUID()  // Unique identifier for each message
    let text: String
    let isCurrentUser: Bool
    let isFirst: Bool
}

struct HistoryResponse: Codable {
    struct Part: Codable {
        let text: String?
    }

    let parts: [Part]
    let role: String
}

struct SendMessageResponse: Codable {
    let response: String
}

struct ChatView: View {
    @State private var messages: [Message] = []

    @State private var newMessage = ""

    var body: some View {
        NavigationStack {
            VStack {

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            if messages.isEmpty {
                                Spacer()  // Keeps ScrollView tappable when empty
                            } else {
                                ForEach(messages) { message in
                                    MessageView(
                                        message: message.text,
                                        isCurrentUser: message.isCurrentUser,
                                        isFirst: message.isFirst
                                    )
                                    .id(message.id)  // Assign ID for scrolling
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .onChange(of: messages.count) {
                        // Scroll to the latest message when a new one is sent
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onTapGesture {
                        dismissKeyboard()
                    }
                }

                // Input Field & Send Button
                HStack {
                    TextField("Pleść", text: $newMessage)
                        .textFieldStyle(.roundedBorder)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(
                        newMessage.trimmingCharacters(in: .whitespaces).isEmpty)  // Disable when empty
                }.padding(.bottom)

            }
            .padding(.horizontal)
            .navigationTitle("Chat with Pleść")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        resetChatHistory()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }
            }
        }.onAppear {
            fetchChatHistory()
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
            for: nil)
    }

    /// Function to send a new message
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(
            in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        let isFirstMessage =
            messages.isEmpty ? true : messages.last?.isCurrentUser == false  // First if last message was from the other user

        messages.append(
            Message(
                text: trimmedMessage, isCurrentUser: true,
                isFirst: isFirstMessage))
        newMessage = ""  // Clear input field

        sendMessage(for: trimmedMessage)
    }

    /// Function to fetch bot response from API
    private func sendMessage(for message: String) {
        guard
            let encodedMessage = message.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed),
            let url = URL(
                string:
                    "https://plesc.a3p.re/chat/google?message=\(encodedMessage)"
            )
        else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(
                    "Error fetching response:",
                    error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(
                    SendMessageResponse.self, from: data)
                let cleanedResponse = decodedResponse.response
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                DispatchQueue.main.async {
                    let isFirstBotMessage = messages.last?.isCurrentUser == true
                    messages.append(
                        Message(
                            text: cleanedResponse, isCurrentUser: false,
                            isFirst: isFirstBotMessage))
                }
            } catch {
                print("Failed to decode response:", error)
            }
        }.resume()
    }
    
    private func resetChatHistory() {
        guard let url = URL(string: "https://plesc.a3p.re/chat/google/history/reset") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error resetting chat history:", error?.localizedDescription ?? "Unknown error")
                return
            }
            messages.removeAll(keepingCapacity: true)
        }.resume()
    }
    
    private func fetchChatHistory() {
        guard let url = URL(string: "https://plesc.a3p.re/chat/google/history") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching chat history:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let apiMessages = try JSONDecoder().decode([HistoryResponse].self, from: data)
                
                DispatchQueue.main.async {
                    messages = apiMessages.compactMap { apiMessage in
                        guard let messageText = apiMessage.parts.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                            return nil
                        }
                        
                        return Message(
                            text: messageText,
                            isCurrentUser: apiMessage.role == "user",
                            isFirst: false // No need to track first messages in history
                        )
                    }
                }
            } catch {
                print("Failed to decode chat history:", error)
            }
        }.resume()
    }
}

#Preview {
    TabView {
        ChatView().tabItem {
            Label("Chat", systemImage: "bubble.left.and.bubble.right")
        }
    }
}
