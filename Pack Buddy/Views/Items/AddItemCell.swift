//
//  AddItemCell.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 05/10/24.
//

import UIKit

class AddItemCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var addItemView: UIView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var addItemLabel: UILabel!
    
    // Constants
    final let plusImage = UIImage(systemName: "plus")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Do nothing
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // Do nothing
    }
    
    fileprivate func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        addItemView.layer.cornerRadius = 12
        addItemView.layer.borderWidth = 0.75
        addItemView.layer.borderColor = UIColor(named: K.SecondaryColors.white)?.cgColor
        addItemView.backgroundColor = UIColor(named: K.MainColors.grayLower)
        
        addItemLabel.textColor = UIColor(named: K.MainColors.white)
        
        addImageView.image = plusImage
    }
}
