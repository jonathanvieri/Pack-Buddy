//
//  PackingCollectionViewCell.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 08/10/24.
//

import UIKit

class PackingCollectionViewCell: UICollectionViewCell {

    // IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        // Setup the content view
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(named: K.MainColors.gray)
        
        // Setup the colors
        titleLabel.textColor = UIColor(named: K.SecondaryColors.gray)
        iconImageView.tintColor = UIColor(named: K.MainColors.white)
        checkmarkImageView.tintColor = .black
    }

    // Function for configuring the cell using template
    func configure(template: TemplateModel) {
        titleLabel.text = template.title
        iconImageView.image = UIImage(systemName: template.icon)
        
        let isSelected = template.isSelected
        
        let checkmarkIcon = isSelected ? "checkmark" : "plus"
        let tintColor = isSelected ? UIColor(named: K.MainColors.white) : .black
        checkmarkImageView.image = UIImage(systemName: checkmarkIcon)
        checkmarkImageView.tintColor = tintColor
    }
}
