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

/// Model for API response
struct BotResponse: Codable {
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
                        VStack(spacing: 4) {
                            ForEach(messages) { message in
                                MessageView(
                                    message: message.text,
                                    isCurrentUser: message.isCurrentUser,
                                    isFirst: message.isFirst
                                )
                                .id(message.id)  // Assign ID for scrolling
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
                }

                // Input Field & Send Button
                HStack {
                    TextField("Pleść", text: $newMessage)
                        .textFieldStyle(.roundedBorder)
                        .padding(8)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(
                        newMessage.trimmingCharacters(in: .whitespaces).isEmpty)  // Disable when empty
                }
                .padding(.horizontal)

            }
            .padding(.horizontal)
            .navigationTitle("Chat with Maciej")
        }
    }

    /// Function to send a new message
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(
            in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        let isFirstMessage = messages.last?.isCurrentUser == false  // First if last message was from the other user

        messages.append(
            Message(
                text: trimmedMessage, isCurrentUser: true,
                isFirst: isFirstMessage))
        newMessage = ""  // Clear input field
        
        fetchBotResponse(for: trimmedMessage)
    }

    /// Function to fetch bot response from API
    private func fetchBotResponse(for message: String) {
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
                let decodedResponse = try JSONDecoder().decode(BotResponse.self, from: data)
                let cleanedResponse = decodedResponse.response.trimmingCharacters(in: .whitespacesAndNewlines)
                
                DispatchQueue.main.async {
                    let isFirstBotMessage = messages.last?.isCurrentUser == true
                    messages.append(Message(text: cleanedResponse, isCurrentUser: false, isFirst: isFirstBotMessage))
                }
            } catch {
                print("Failed to decode response:", error)
            }
        }.resume()
    }
}

#Preview {
    ChatView()
}
