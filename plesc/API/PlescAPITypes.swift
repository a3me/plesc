//
//  PlescAPITypes.swift
//  plesc
//
//  Created by Matt Ball on 05/04/2025.
//
import Foundation

public enum DateFormatterFactory {
    public static let microsecondISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

public class Chat: Decodable {
    var user_id: String
    var bot_id: String
    var id: String
    var messages: [ChatMessage]
    var bot: Bot
}

public class ChatResponse: Decodable {
    var response: String
}

public struct ChatMessage: Decodable {
    let content: String
    let role: String
    let timestamp: Date
    
    public init(content: String, role: String, timestamp: Date) {
        self.content = content
        self.role = role
        self.timestamp = timestamp
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try container.decode(String.self, forKey: .content)
        self.role = try container.decode(String.self, forKey: .role)

        let timestampString = try container.decode(
            String.self,
            forKey: .timestamp
        )

        guard
            let timestampDate = DateFormatterFactory.microsecondISO8601.date(
                from: timestampString
            )
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [CodingKeys.timestamp, CodingKeys.timestamp],
                    debugDescription:
                        "Date string did not match expected format"
                )
            )
        }
        self.timestamp = timestampDate
    }

    private enum CodingKeys: String, CodingKey {
        case content, role, timestamp
    }
}

public class Bot: Decodable {
    public var id: String
    public var name: String
    public var description: String
    public var image_url: String
    public var prompt: String
    public var created_at: Date
    public var created_by: String

    private enum CodingKeys: String, CodingKey {
        case id, name, description, image_url, prompt, created_at, created_by
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        image_url = try container.decode(String.self, forKey: .image_url)
        prompt = try container.decode(String.self, forKey: .prompt)
        created_by = try container.decode(String.self, forKey: .created_by)

        let createdAtString = try container.decode(
            String.self,
            forKey: .created_at
        )

        guard
            let createdAtDate = DateFormatterFactory.microsecondISO8601.date(
                from: createdAtString
            )
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [CodingKeys.created_at, CodingKeys.created_by],
                    debugDescription:
                        "Date string did not match expected format"
                )
            )
        }

        created_at = createdAtDate
    }
}
