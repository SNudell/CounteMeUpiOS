//
//  RequestSender.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 06.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation
import Alamofire


class RequestSender {
    
    let isSSLPinningEnabled = true
    
    var serverTrustPolicy: ServerTrustPolicy
    var serverTrustPolicies: [String: ServerTrustPolicy]
    
    var serverConfig: ServerConfig
    
    var afManager: SessionManager
    
    init() {
        serverConfig = loadServerConfig() ?? ServerConfig(ip: "localhost", port: "8080")
        
        let pathToCert = Bundle.main.path(forResource: nil, ofType: "der")
        let localCertificate:NSData = NSData(contentsOfFile: pathToCert!)!
        
        self.serverTrustPolicy = ServerTrustPolicy.pinCertificates(
            certificates: [SecCertificateCreateWithData(nil, localCertificate)!],
            validateCertificateChain: false,
            validateHost: false
        )
        
        self.serverTrustPolicies = [
            serverConfig.serverAddress: self.serverTrustPolicy
        ]
        
        self.afManager = SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: self.serverTrustPolicies)
        )
    }
    
    func getAllCounters (completion: @escaping (([Counter]?) -> ())) {
        
        let url = serverConfig.counterEndpoint
        
        self.afManager.request(url,
                               method: .get)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching remote counters: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [[String: Any]] else {
                    print("couldn't convert answer to json")
                    return
                }
                let counters = parseAll(counters: value)
                completion(counters)
        }
    }
    
    func updateServerConfig() {
        if let config = loadServerConfig() {
            self.serverConfig = config
        }
    }
    
    func requestIncrement(of counter: Counter, by delta: Int64, completion: @escaping (Counter?) ->()) {
        let url = serverConfig.incrementEndpoint
        
        self.afManager.request(url, method: .put, parameters: ["name": counter.name, "increment": delta], encoding: JSONEncoding.default , headers: [:]).validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while trying to increment counters: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                    let counter = Counter(json: value) else {
                    print("couldn't convert answer to counter")
                    return
                }
                completion(counter)
        }
    }
    
    func requestDecrement(of counter: Counter, by delta: Int64, completion: @escaping (Counter?) -> ()) {
        let url = serverConfig.decrementEndpoint
        
        self.afManager.request(url, method: .put, parameters: ["name": counter.name, "decrement":delta], encoding: JSONEncoding.default, headers: [:]).validate()
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while trying to decrement counters: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                    let counter = Counter(json: value) else {
                        print("couldn't convert answer to counter")
                        return
                }
                completion(counter)
        }
    }
    
    func create(counter name: String, withStartingValue startingValue: Int64, completion: @escaping (Counter?) -> ()) {
        let url = serverConfig.counterEndpoint
        
        self.afManager.request(url, method: .post, parameters: ["name": name, "value":startingValue], encoding: JSONEncoding.default, headers: [:]).validate()
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    print("Error while trying to create counters: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                    let counter = Counter(json: value) else {
                        print("couldn't convert answer to counter")
                        return
                }
                completion(counter)
        }
    }
    
    func delete(_ counter: Counter, completion: @escaping () -> ()) {
        let url = serverConfig.counterEndpoint.appendingPathComponent(counter.name)
        
        self.afManager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .response {_ in
                completion()
        }
    }
}

func parseAll(counters: [[String: Any]]) -> [Counter] {
    var parsedCounters = [Counter]()
    for counterJson in counters {
        if let counter = Counter(json: counterJson) {
            parsedCounters.append(counter)
        }
    }
    return parsedCounters
}


extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
