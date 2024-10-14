//
//  CustomTextField.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 02/10/24.
//

import UIKit

class CustomTextField: UITextField {

    // Variables
    var customPlaceholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        // Set background color
        self.backgroundColor = UIColor(named: K.MainColors.gray)
        
        // Set corner radius
        self.layer.cornerRadius = 20
        
        // Set text color
        self.textColor = UIColor(named: K.MainColors.white)
        self.font = UIFont(name: "Plus Jakarta Sans", size: 16)
        
        // Set default placeholder text
        customPlaceholder = "Packing Name"
        
        // Add left padding for the text
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
    }
    
    // Method for customizing placeholder text
    fileprivate func updatePlaceholder() {
        if let placeholderText = customPlaceholder {
            self.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.SecondaryColors.gray) ?? .gray])
        }
    }

}
