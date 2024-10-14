//
//  PackingCell.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 07/10/24.
//

import UIKit

class PackingCell: UITableViewCell {

    @IBOutlet weak var packingView: UIView!
    @IBOutlet weak var frontSquareView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nightsLabel: UILabel!
    @IBOutlet weak var circularProgressBarView: CircularProgressBarView!
    
    
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
        // Set other background to clear
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Setup the packing view
        packingView.layer.cornerRadius = 16
        packingView.layer.borderWidth = 1
        packingView.layer.borderColor = UIColor(named: K.MainColors.black)?.cgColor
        
        // Setup the date text label
        dateLabel.textColor = UIColor(named: K.SecondaryColors.gray)
        
        // Setup the nights text label
        nightsLabel.textColor = UIColor(named: K.SecondaryColors.gray)
    }
    
    func configureProgressBar(currentValue: Int, totalValue: Int) {
        circularProgressBarView.currentValue = currentValue
        circularProgressBarView.totalValue = totalValue
    }
    
    func configureProgressBarColor(color: UIColor) {
        circularProgressBarView.setColor(packingColor: color)
    }
    
    func configureFrontSquareColor(color: UIColor) {
        frontSquareView.backgroundColor = color
    }
}
