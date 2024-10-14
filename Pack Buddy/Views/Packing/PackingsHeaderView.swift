//
//  PackingsHeaderView.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 07/10/24.
//

import UIKit

class PackingsHeaderView: UIView {

    // IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    fileprivate func setupView() {
        let nib = UINib(nibName: "PackingsHeaderView", bundle: .main)
        let contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    func configure(delegate: UISearchBarDelegate) {
        // Set the delegate
        searchBar.delegate = delegate
        
        // Configure the search bar font
        if let selectedFont = UIFont(name: "PlusJakartaSans-Medium", size: 16) {
            searchBar.searchTextField.font = selectedFont
            searchBar.searchTextField.textColor = UIColor(named: K.MainColors.white)
        }
        
        // Change the search bar text field
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            
            searchTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
            
            // Configure the placeholder
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Packing", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.SecondaryColors.gray) ?? .gray])
            
            // Customize the icons color
            searchTextField.leftView?.tintColor = UIColor(named: K.MainColors.white)
            
            if let clearButton = searchTextField.value(forKey: "clearButton") as? UIButton {
                let clearImage = UIImage(systemName: "xmark.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                clearButton.setImage(clearImage, for: .normal)
            }
        }
        
        // Remove the background
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
}
