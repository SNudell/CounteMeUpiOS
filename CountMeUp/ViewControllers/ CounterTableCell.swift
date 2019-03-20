//
//   CounterTableCell.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 14.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation
import UIKit

class CounterTableCell: UITableViewCell {
    
    public var counter: Counter? {
        didSet {
            nameLabel.text = counter?.name
            guard let value = counter?.value else {
                return
            }
            valueLabel.text = "\(value)"
        }
    }
    
    var nameLabel: UILabel
    
    var valueLabel: UILabel
    
    var incrementButton: UIButton
    
    var decrementButton: UIButton
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel()
        nameLabel.textColor = .black
        nameLabel.text = counter?.name
        nameLabel.textAlignment = .left
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel = UILabel()
        valueLabel.textColor = .black
        valueLabel.text = "\(String(describing: counter?.value))"
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        incrementButton = UIButton(type: .custom)
        let plusImage = UIImage(named: "IncrementButton")?.withRenderingMode(.alwaysTemplate)
        incrementButton.setImage(plusImage, for: .normal)
        incrementButton.imageView?.contentMode = .scaleAspectFit
        incrementButton.imageView?.tintColor = .black
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        
        decrementButton = UIButton(type: .custom)
        let minusImage = UIImage(named: "DecrementButton")?.withRenderingMode(.alwaysTemplate)
        decrementButton.setImage(minusImage, for: .normal)
        decrementButton.imageView?.tintColor = .black
        decrementButton.imageView?.contentMode = .scaleAspectFit
        decrementButton.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
    }
    
    func makeConstraints() {
        addSubview(nameLabel)
        addSubview(valueLabel)
        addSubview(incrementButton)
        addSubview(decrementButton)
        
        let stackView = UIStackView(arrangedSubviews: [decrementButton, valueLabel, incrementButton])
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalToSystemSpacingAfter: self.leftAnchor, multiplier: 1),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            nameLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),
            nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 2/3),
            
            stackView.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
            ])
        
        
        incrementButton.addTarget(self, action: #selector(incrementCounter), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementCounter), for: .touchUpInside)
        
    }
    
    @objc func incrementCounter() {
        guard let currentCounter = self.counter else {
            return
        }
        requestSender.requestIncrement(of: currentCounter, by: 1, completion: { newCounter in
            if let counter = newCounter {
                self.counter = counter
            }
        })
    }
    
    @objc func decrementCounter() {
        guard let currentCounter = self.counter else {
            return
        }
        requestSender.requestDecrement(of: currentCounter, by: 1, completion: { newCounter in
            if let counter = newCounter {
                self.counter = counter
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
