//
//  ServerConfig.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 06.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation

let KEY_FOR_SERVER_IP = "serverIp"
let KEY_FOR_SERVER_PORT = "serverPort"

class ServerConfig {
    
    let serverIp: String
    let port: String
    
    var serverAddress: String {
        get {
            return "http://\(serverIp):\(port)"
        }
    }
    
    var counterEndpoint: URL {
        get{
            return URL(string:"\(serverAddress)/counter")!
        }
    }
    
    var incrementEndpoint: URL {
        get{
            return URL(string:"\(counterEndpoint)/increment")!
        }
    }
    
    var decrementEndpoint: URL {
        get{
            return URL(string:"\(counterEndpoint)/decrement")!
        }
    }
    
    init (ip: String, port: String) {
        self.serverIp = ip
        self.port = port
    }
    
}

func save(serverConfig: ServerConfig) {
    UserDefaults.standard.set(serverConfig.serverIp, forKey: KEY_FOR_SERVER_IP)
    UserDefaults.standard.set(serverConfig.port, forKey: KEY_FOR_SERVER_PORT)
    requestSender.updateServerConfig()
}

func loadServerConfig() -> ServerConfig? {
    let serverIp = UserDefaults.standard.string(forKey: KEY_FOR_SERVER_IP)
    let serverPort = UserDefaults.standard.string(forKey: KEY_FOR_SERVER_PORT)
    guard let ip = serverIp,
        let port = serverPort else {
            return nil
    }
    return ServerConfig(ip: ip, port: port)
}
