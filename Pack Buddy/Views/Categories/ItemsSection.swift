//
//  ItemsSection.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 28/09/24.
//

import UIKit

class ItemsSection: UITableViewHeaderFooterView {

    // IBOutlets
    @IBOutlet weak var sectionSymbol: UIImageView!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var chevronSymbol: UIImageView!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var openCloseButton: UIButton!
    
    // Constants
    final let closedSymbol = UIImage(systemName: "chevron.up")
    final let openedSymbol = UIImage(systemName: "chevron.down")
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    fileprivate func setupView() {
        let nib = UINib(nibName: "ItemsSection", bundle: .main)
        let contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    func configure(title: String, currentProgress: Int, progressTotal: Int, symbol: String) {
        
        // Setup content view
        sectionView.layer.cornerRadius = 18
        sectionView.layer.borderColor = UIColor(named: K.SecondaryColors.white)?.cgColor.copy(alpha: 0.2)
        sectionView.layer.borderWidth = 1
        
        
        // Setup title
        sectionTitle.text = title
        sectionTitle.textColor = UIColor(named: K.MainColors.white)
        
        // Setup progress view
        progressView.layer.cornerRadius = 18
        
        progressLabel.text = "\(currentProgress)/\(progressTotal)"
        progressLabel.textColor = UIColor(named: K.MainColors.white)
        
        // Setup section symbol
        sectionSymbol.image = UIImage(systemName: symbol)
    }
    
    func updateChevron(isOpen: Bool) {
        let chevron = isOpen ?  openedSymbol : closedSymbol
        
        UIView.transition(with: chevronSymbol, duration: 0.1, options: .transitionCrossDissolve) {
            self.chevronSymbol.image = chevron
        }
    }
}
