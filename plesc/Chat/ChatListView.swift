//
//  ChatListView.swift
//  plesc
//
//  Created by Matt Ball on 30/03/2025.
//
import SwiftUI

struct ChatListView: View {
    @State var chats: [Chat] = []
    @State private var selectedChatId: String?

    var body: some View {
        NavigationSplitView {
            List(self.chats, id: \.id, selection: $selectedChatId) { chat in
                NavigationLink(value: chat.id) {
                    ChatListItemView(chat: chat)
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                Button("", systemImage: "plus", action: {})
            }

        } detail: {
            if let chatId = selectedChatId {
                // Pass the selected ID to ChatView
                ChatView(chatId: chatId)
            } else {
                // Show placeholder when nothing is selected
                Text("Select a chat")
            }
        }
        .onAppear {
            PlescAPI.getChats { chats in
                self.chats = chats
            }
        }
    }
}

// ChatListItemView remains the same
struct ChatListItemView: View {
    var chat: Chat

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: chat.bot.image_url)!) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading) {  // Align text nicely
                HStack {
                    Text(chat.bot.name)
                        .lineLimit(1)
                        .font(.headline)
                    Spacer()
                    // Use nil coalescing for timestamp if messages can be empty initially
                    Text(
                        (chat.messages.last?.timestamp ?? Date())
                            .formatted(date: .numeric, time: .shortened)
                    )
                    .font(.caption)  // Make timestamp smaller
                    .foregroundColor(.gray)
                }
                // Use nil coalescing for content
                Text((chat.messages.last?.content ?? "No messages yet"))
                    .lineLimit(2)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

            }
        }
    }
}
