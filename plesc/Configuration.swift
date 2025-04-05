//
//  Configuration.swift
//  plesc
//
//  Created by Matt Ball on 05/04/2025.
//
import Foundation

enum BuildConfiguration {
    case debug
    case release
    
    static var current: BuildConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
}

struct AppConfiguration {
    static var apiToken: String = ""
    
    static var isDebug: Bool {
        return BuildConfiguration.current == .release
    }
    
    static var apiBaseURL: URL {
        return isDebug ? URL(string: "http://localhost:8000")! : URL(string: "https://plesc.a3p.re")!
    }
}

