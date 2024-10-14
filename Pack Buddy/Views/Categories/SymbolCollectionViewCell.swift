//
//  SymbolCollectionViewCell.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 03/10/24.
//

import UIKit

class SymbolCollectionViewCell: UICollectionViewCell {

    // IBOutlets
    @IBOutlet weak var symbolImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    fileprivate func setupUI() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor(named: K.AlternativeColors.gray)?.cgColor
        contentView.layer.borderWidth = 2
        
        symbolImageView.tintColor = UIColor(named: K.MainColors.white)
    }
    
    func configureSelected(_ isSelected: Bool) {
        if (isSelected) {
            contentView.backgroundColor = UIColor(named: K.AlternativeColors.gray)
        } else {
            contentView.backgroundColor = UIColor(named: K.MainColors.background)
        }
    }
}
