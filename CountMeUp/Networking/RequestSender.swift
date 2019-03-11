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
    
//    var urlSession: URLSession
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
    
    func getAllCounters (completion: @escaping ((String?) -> ())) {
        
        let url = serverConfig.counterEndpoint
        

       self.afManager.request(url,
                   method: .get)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching remote rooms: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [[String: Any]] else {
                    print("couldn't convert answer to json")
                    return
                }
                print(value)
        }
    }

}
