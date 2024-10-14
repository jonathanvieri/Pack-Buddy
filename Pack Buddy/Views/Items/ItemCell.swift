//
//  ItemCell.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 30/09/24.
//

import UIKit

class ItemCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var checklistView: UIView!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    
    
    // Constants
    let selectedImage = UIImage(systemName: "checkmark.square.fill")
    let deselectedImage = UIImage(systemName: "square")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Do Nothing
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // Do Nothing
    }
    
    func setCheckmark(_ done: Bool) {
        let checkmark = done ? selectedImage : deselectedImage
        
        checkmarkImage.image = checkmark
    }
    
    fileprivate func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        checklistView.layer.cornerRadius = 12
        checklistView.layer.borderWidth = 0.75
        checklistView.layer.borderColor = UIColor(named: K.SecondaryColors.white)?.cgColor
        
        itemTitle.textColor = UIColor(named: K.MainColors.white)
    }
    
}
