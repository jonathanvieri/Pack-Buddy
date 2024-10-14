//
//  ItemsHeaderView.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 26/09/24.
//

import UIKit

class ItemsHeaderView: UIView {

    // IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var packingTitleLabel: UILabel!
    @IBOutlet weak var packingDateLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var totalItemLabel: UILabel!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    
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
    
    func setupView() {
        let nib = UINib(nibName: "ItemsHeaderView", bundle: .main)
        let contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    // Configure all UI
    func configure(packingTitle: String, packingLocation: String, packingColor: UIColor, startDate: String, endDate: String) {
        
        // Setup view
        contentView.backgroundColor = UIColor(named: K.MainColors.background)
        
        // Setup packing title
        packingTitleLabel.textColor = UIColor(named: K.MainColors.white)
        packingTitleLabel.text = packingTitle
        
        // Setup packing date
        packingDateLabel.textColor = UIColor(named: K.MainColors.white)
        packingDateLabel.text = "\(startDate) - \(endDate)"
        
        // Setup image view
        setLocationImage(location: packingLocation)
        locationImageView.layer.masksToBounds = true
        locationImageView.layer.cornerRadius = 16
        
        // Setup the progress view
        progressView.backgroundColor = UIColor(named: K.MainColors.black)
        progressView.layer.cornerRadius = 6
        
        totalItemLabel.textColor = UIColor(named: K.MainColors.white)
        
        progressBarView.progressTintColor = packingColor
        progressBarView.trackTintColor = UIColor(named: K.MainColors.white)
        
        progressPercentageLabel.textColor = UIColor(named: K.MainColors.white)
    }
    
    fileprivate func setLocationImage(location: String) {
        var availableImages: [String] = []
        
        switch location {
        case "Beach":
            availableImages = ["beach1", "beach2", "beach3"]
        case "City":
            availableImages = ["city1", "city2", "city3"]
        case "Mountain":
            availableImages = ["mountain1", "mountain2", "mountain3"]
        case "Forest":
            availableImages = ["forest1", "forest2", "forest3"]
        case "Desert":
            availableImages = ["desert1", "desert2", "desert3"]
        case "Countryside":
            availableImages = ["countryside1", "countryside2", "countryside3"]
        case "Island":
            availableImages = ["island1", "island2", "island3"]
        default:
            availableImages = ["default1", "default2", "default3"]
        }
        
        if let randomImageName = availableImages.randomElement() {
            locationImageView.image = UIImage(named: randomImageName)
        }
    }
}
