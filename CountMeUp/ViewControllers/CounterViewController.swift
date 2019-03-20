//
//  CounterViewController.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 17.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation
import UIKit

class CounterViewController : UIViewController {
    
    var counter: Counter {
        didSet {
            valueDisplay?.text = String(describing: counter.value)
        }
    }
    
    var valueDisplay: UILabel?
    
    var lowerContainer: UIStackView?
    var incrementButton: UIButton?
    var decrementButton: UIButton?
    var deltaDisplay: UITextField?
    
    var updater: Timer?
    
    var bottomConstraint: NSLayoutConstraint?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, counter: Counter) {
        self.counter = counter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        styleHeader()
        initViews()
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        startUpdater()
    }
    
    func startUpdater() {
        updater = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(requestRefresh), userInfo: nil, repeats: true)
    }
    
    @objc func requestRefresh() {
        requestSender.request(counter: counter.name, completion: {response in
            guard let newCounter = response else {
                return
            }
            self.counter = newCounter
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updater?.invalidate()
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            guard let constraint = bottomConstraint,
                let bottomContainer = lowerContainer else {
                    return
            }
            constraint.isActive = false
            let newConstraint = bottomContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -1 * keyboardSize.height)
            newConstraint.isActive = true
            self.bottomConstraint = newConstraint
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let constraint = bottomConstraint,
            let bottomContainer = lowerContainer else {
                return
        }
        constraint.isActive = false
        let newConstraint = bottomContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        newConstraint.isActive = true
        self.bottomConstraint = newConstraint
    }
    
    func styleHeader() {
        self.navigationItem.title = counter.name
    }
    
    func initViews() {
        let valueDisplay = UILabel()
        valueDisplay.numberOfLines = 1
        valueDisplay.lineBreakMode = .byTruncatingTail
        valueDisplay.translatesAutoresizingMaskIntoConstraints = false
        valueDisplay.textAlignment = .center
        valueDisplay.adjustsFontSizeToFitWidth = true
        valueDisplay.baselineAdjustment = .alignCenters
        // make it enourmous and it will downscale automatically
        valueDisplay.font = UIFont.systemFont(ofSize: 400)
        valueDisplay.text = String(describing: counter.value)
        self.valueDisplay = valueDisplay
        self.view.addSubview(valueDisplay)
        
        let incrementButton = UIButton(type: .custom)
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        incrementButton.imageView?.contentMode = .scaleAspectFit
        incrementButton.setImage(UIImage(named: "plus"), for: .normal)
        incrementButton.addTarget(self, action: #selector(increment), for: .touchUpInside)
        self.incrementButton = incrementButton
        
        let decrementButton = UIButton(type: .custom)
        decrementButton.translatesAutoresizingMaskIntoConstraints = false
        decrementButton.imageView?.contentMode = .scaleAspectFit
        decrementButton.setImage(UIImage(named: "minus"), for: .normal)
        decrementButton.addTarget(self, action: #selector(decrement), for: .touchUpInside)
        self.decrementButton = decrementButton
        
        let deltaDisplay = UITextField()
        deltaDisplay.translatesAutoresizingMaskIntoConstraints = false
        deltaDisplay.text = "1"
        deltaDisplay.font = UIFont.systemFont(ofSize: 40)
        deltaDisplay.adjustsFontSizeToFitWidth = true
        deltaDisplay.translatesAutoresizingMaskIntoConstraints = false
        deltaDisplay.textAlignment = .center
        deltaDisplay.keyboardType = .numberPad
        deltaDisplay.returnKeyType = .done
        self.deltaDisplay = deltaDisplay
        self.addLineToView(view: deltaDisplay, position: .LINE_POSITION_BOTTOM, color: .gray, width: 1.0)
        
        
        let lowerContainer = UIStackView()
        lowerContainer.translatesAutoresizingMaskIntoConstraints = false
        lowerContainer.addSubview(incrementButton)
        lowerContainer.addSubview(decrementButton)
        lowerContainer.addSubview(deltaDisplay)
        self.lowerContainer = lowerContainer
        self.view.addSubview(lowerContainer)
        
        bottomConstraint = lowerContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            valueDisplay.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            valueDisplay.widthAnchor.constraint(equalTo: valueDisplay.heightAnchor, multiplier: 1),
            valueDisplay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            valueDisplay.bottomAnchor.constraint(equalTo: lowerContainer.topAnchor),
            
            lowerContainer.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 2/3),
            lowerContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            lowerContainer.heightAnchor.constraint(equalTo: valueDisplay.heightAnchor),
            bottomConstraint!,
            
            incrementButton.rightAnchor.constraint(equalTo: lowerContainer.centerXAnchor),
            incrementButton.heightAnchor.constraint(equalTo: incrementButton.widthAnchor, multiplier: 1),
            incrementButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            incrementButton.topAnchor.constraint(equalToSystemSpacingBelow: lowerContainer.topAnchor, multiplier: 1),
            
            decrementButton.leftAnchor.constraint(equalToSystemSpacingAfter:  incrementButton.rightAnchor, multiplier: 1),
            decrementButton.heightAnchor.constraint(equalTo: incrementButton.heightAnchor),
            decrementButton.widthAnchor.constraint(equalTo: incrementButton.widthAnchor),
            decrementButton.topAnchor.constraint(equalToSystemSpacingBelow: lowerContainer.topAnchor, multiplier: 1),
            
            deltaDisplay.topAnchor.constraint(equalToSystemSpacingBelow: incrementButton.bottomAnchor, multiplier: 1),
            deltaDisplay.leftAnchor.constraint(equalTo: lowerContainer.leftAnchor),
            deltaDisplay.rightAnchor.constraint(equalTo: lowerContainer.rightAnchor),
            ])
    }
    
    enum LINE_POSITION {
        case LINE_POSITION_TOP
        case LINE_POSITION_BOTTOM
    }
    
    func addLineToView(view : UIView, position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
    
    @objc func increment() {
        guard let deltaText = deltaDisplay?.text,
            let deltaValue = Int64(deltaText) else {
                return
        }
        
        requestSender.requestIncrement(of: counter, by: deltaValue, completion: { response in
            guard let newCounter = response else {
                return
            }
            self.counter = newCounter
        })
    }
    
    @objc func decrement() {
        guard let deltaText = deltaDisplay?.text,
            let deltaValue = Int64(deltaText) else {
                return
        }
        
        requestSender.requestDecrement(of: counter, by: deltaValue, completion: { response in
            guard let newCounter = response else {
                return
            }
            self.counter = newCounter
        })
    }
    
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
