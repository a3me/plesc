//
//  PlescAPI.swift
//  plesc
//
//  Created by Matt Ball on 05/04/2025.
//
import Foundation

enum PlescAPI: URLRequestConvertible {
    
    static let endpoint = AppConfiguration.apiBaseURL
    
    case getChats
    case getChat(chatId: String)
    case sendChatMessage(chatId: String, message: String)
    
    var path: String {
        switch self {
        case .getChats:
            return "/chat/"
        case .getChat(chatId: let chatId):
            return "/chat/\(chatId)"
        case .sendChatMessage(chatId: let chatId, message: _):
            return "/chat/\(chatId)/message"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getChats, .getChat:
            return .get
        case .sendChatMessage:
            return .post
        }
    }
    
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: PlescAPI.endpoint.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(AppConfiguration.apiToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    static func getChats(onCompletion: @escaping ([Chat]) -> ()) {
        PlescAPI.fetchData(urlRequest: PlescAPI.getChats.asURLRequest(), onCompletion: onCompletion)
    }
    
    static func getChat(chatId: String, onCompletion: @escaping (Chat) -> ()) {
        PlescAPI.fetchData(urlRequest: PlescAPI.getChat(chatId: chatId).asURLRequest(), onCompletion: onCompletion)
    }
    
    static func sendChatMessage(chatId: String, message: String, onCompletion: @escaping (ChatResponse) -> ()) {
        var request = PlescAPI.sendChatMessage(chatId: chatId, message: message).asURLRequest()
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["message": message], options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        PlescAPI.fetchData(urlRequest: request, onCompletion: onCompletion)
    }
    
    static func fetchData<T: Decodable>(urlRequest: URLRequest, onCompletion: @escaping (T) -> ()) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data, url: \(urlRequest) error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    onCompletion(decodedData)
                }
            } catch {
                print("Failed to decode requested data, url: \(urlRequest), raw data: \(String(data: data, encoding: .utf8) ?? "No data"), error:", error)
            }
        }.resume()
    }
}

protocol URLRequestConvertible {
    /// Returns a `URLRequest` or throws if an `Error` was encountered.
    ///
    /// - Returns: A `URLRequest`.
    /// - Throws:  Any error thrown while constructing the `URLRequest`.
    func asURLRequest() throws -> URLRequest
}

/// Type representing HTTP methods. Raw `String` value is stored and compared case-sensitively, so
/// `HTTPMethod.get != HTTPMethod(rawValue: "get")`.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    /// `CONNECT` method.
    public static let connect = HTTPMethod(rawValue: "CONNECT")
    /// `DELETE` method.
    public static let delete = HTTPMethod(rawValue: "DELETE")
    /// `GET` method.
    public static let get = HTTPMethod(rawValue: "GET")
    /// `HEAD` method.
    public static let head = HTTPMethod(rawValue: "HEAD")
    /// `OPTIONS` method.
    public static let options = HTTPMethod(rawValue: "OPTIONS")
    /// `PATCH` method.
    public static let patch = HTTPMethod(rawValue: "PATCH")
    /// `POST` method.
    public static let post = HTTPMethod(rawValue: "POST")
    /// `PUT` method.
    public static let put = HTTPMethod(rawValue: "PUT")
    /// `TRACE` method.
    public static let trace = HTTPMethod(rawValue: "TRACE")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
