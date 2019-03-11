//
//  ServerInputViewController.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 06.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation
import UIKit

class ServerInputViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {
    
    var container: UIStackView?
    
    var inputServerLabel: UILabel?
    
    var inputIpLabel: UILabel?
    var ipInput: UITextField?
    
    var inputPortLabel: UILabel?
    var portInput: UITextField?
    
    var connectButton: UIButton?
    
    var errorLabel: UILabel?
    
    let padding = CGFloat(20)
    let textViewHeight = CGFloat(50)
    let fontSize = CGFloat(20)
    let widthFactor: CGFloat = 0.8
    
    let inputBorderWidth: CGFloat = 0.5
    let inputCornerRadius: CGFloat = 5
    
    var requestSender: RequestSender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initViews()
    }
    
    private func initViews() {
        
        // initalizing views
        
        let container = UIStackView()
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        let inputServerLabel = UILabel()
        inputServerLabel.text = "Connect to your Server"
        inputServerLabel.textAlignment = .center
        inputServerLabel.translatesAutoresizingMaskIntoConstraints = false
        inputServerLabel.font = UIFont.systemFont(ofSize: fontSize)
        self.inputServerLabel = inputServerLabel
        container.addSubview(inputServerLabel)
        
        let inputIpLabel = UILabel()
        inputIpLabel.text = "Enter your servers ip-address"
        inputIpLabel.translatesAutoresizingMaskIntoConstraints = false
        inputIpLabel.font = UIFont.systemFont(ofSize: fontSize)
        inputIpLabel.textAlignment = .center
        self.inputIpLabel = inputIpLabel
        container.addSubview(inputIpLabel)
        
        let ipInput = UITextField()
        ipInput.text = "192.168.2.110"
        ipInput.translatesAutoresizingMaskIntoConstraints = false
        ipInput.textAlignment = .center
        ipInput.layer.borderWidth = inputBorderWidth
        ipInput.layer.cornerRadius = inputCornerRadius
        ipInput.keyboardType = .numbersAndPunctuation
        ipInput.addTarget(self, action: #selector(validateIpInputContents), for: .editingChanged)
        ipInput.delegate = self
        ipInput.returnKeyType = .done
        self.ipInput = ipInput
        container.addSubview(ipInput)
        
        let inputPortLabel = UILabel()
        inputPortLabel.text = "Enter your servers port"
        inputPortLabel.translatesAutoresizingMaskIntoConstraints = false
        inputPortLabel.font = UIFont.systemFont(ofSize: fontSize)
        inputPortLabel.textAlignment = .center
        self.inputPortLabel = inputPortLabel
        container.addSubview(inputPortLabel)
        
        
        let portInput = UITextField()
        portInput.text = "8079"
        portInput.translatesAutoresizingMaskIntoConstraints = false
        portInput.font = UIFont.systemFont(ofSize: fontSize)
        portInput.textAlignment = .center
        portInput.layer.borderWidth = inputBorderWidth
        portInput.layer.cornerRadius = inputCornerRadius
        portInput.delegate = self
        portInput.keyboardType = .numbersAndPunctuation
        portInput.addTarget(self, action: #selector(validatePortInputContents), for: .editingChanged)
        portInput.returnKeyType = .done
        self.portInput = portInput
        container.addSubview(portInput)
        
        let connectButton = UIButton(type: .roundedRect)
        connectButton.setTitle("Connect", for: .normal)
        connectButton.layer.borderWidth = inputBorderWidth
        connectButton.layer.cornerRadius = inputCornerRadius
        connectButton.backgroundColor = connectButton.titleColor(for: .normal)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(connectButton)
        self.connectButton = connectButton
        
        let errorLabel = UILabel()
        errorLabel.text = "Error message not set"
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        self.errorLabel = errorLabel
        container.addSubview(errorLabel)
        
        // applying constraints
        
        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            container.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            inputServerLabel.topAnchor.constraint(equalToSystemSpacingBelow: container.topAnchor, multiplier: 4),
            inputServerLabel.heightAnchor.constraint(equalToConstant: textViewHeight),
            inputServerLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            inputServerLabel.widthAnchor.constraint(equalTo: container.widthAnchor),
            
            inputIpLabel.topAnchor.constraint(equalToSystemSpacingBelow: inputServerLabel.bottomAnchor, multiplier: 1),
            inputIpLabel.heightAnchor.constraint(equalToConstant: textViewHeight),
            inputIpLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            ipInput.topAnchor.constraint(equalToSystemSpacingBelow: inputIpLabel.bottomAnchor, multiplier: 1),
            ipInput.heightAnchor.constraint(equalToConstant: textViewHeight),
            ipInput.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            ipInput.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: widthFactor),
            
            inputPortLabel.topAnchor.constraint(equalToSystemSpacingBelow: ipInput.bottomAnchor, multiplier: 1),
            inputPortLabel.heightAnchor.constraint(equalToConstant: textViewHeight),
            inputPortLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            portInput.topAnchor.constraint(equalToSystemSpacingBelow: inputPortLabel.bottomAnchor, multiplier: 1),
            portInput.heightAnchor.constraint(equalToConstant: textViewHeight),
            portInput.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            portInput.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: widthFactor),
            
            connectButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: widthFactor),
            connectButton.topAnchor.constraint(equalToSystemSpacingBelow: portInput.bottomAnchor, multiplier: 1),
            connectButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            connectButton.heightAnchor.constraint(equalToConstant: textViewHeight),
            
            errorLabel.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: widthFactor),
            errorLabel.heightAnchor.constraint(equalToConstant: textViewHeight),
            errorLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: padding),
            ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === ipInput {
            textField.resignFirstResponder()
            portInput?.becomeFirstResponder()
        } else if textField === portInput {
            textField.resignFirstResponder()
            connect()
        }
        return true;
    }
    
    @objc func connect() {
        guard let serverConfig = tryParseServerConfig() else {
            showErrorLabel(displaying: "error parsing ip or port")
            return
        }
        save(serverConfig: serverConfig)
        self.requestSender = RequestSender()
        requestSender?.getAllCounters(completion: {_ in })
        
    }
    
    func tryParseServerConfig() -> ServerConfig? {
        guard let ipInput = self.ipInput,
            let portInput = self.portInput,
            let ip = ipInput.text,
            let port = portInput.text,
            validate(ip: ip),
            validate(port: port) else {
                return nil
        }
        return ServerConfig(ip: ip, port: port)
    }
    
    
    func validate(ip: String) -> Bool {
        for char in ip {
            guard char.isNumber || char == "." else {
                showErrorLabel(displaying: "Ip musn't contain \"\(char)\"")
                return false
            }
        }
        hideErrorLabel()
        return true
    }
    
    @objc func validateIpInputContents() {
        guard let ipInput = self.ipInput,
            let ip = ipInput.text,
            validate(ip: ip) else {
                return
        }
    }
    
    func validate(port: String) -> Bool {
        for char in port {
            guard char.isNumber else {
                showErrorLabel(displaying: "Port musn't contain \"\(char)\"")
                return false
            }
        }
        hideErrorLabel()
        return true
    }
    
    @objc func validatePortInputContents() {
        guard let portInput = self.portInput,
            let port = portInput.text,
            validate(port: port) else {
                return
        }
    }
    
    
    func showErrorLabel(displaying message: String) {
        errorLabel?.text = message
        errorLabel?.isHidden = false
    }
    
    func hideErrorLabel() {
        errorLabel?.isHidden = true
    }
}

