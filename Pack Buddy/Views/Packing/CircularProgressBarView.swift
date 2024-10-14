//
//  CircularProgressBarView.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 07/10/24.
//

import UIKit

class CircularProgressBarView: UIView {

    // IBOutlets
    @IBOutlet weak var totalProgressLabel: UILabel!
    
    // Variables
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    
    var color: UIColor = .red {
        didSet {
            // Updates the progress layer whenever color is set
            progressLayer.strokeColor = color.cgColor
        }
    }
    
    var currentValue: Int = 0 {
        didSet {
            updateProgress()
        }
    }
    
    var totalValue: Int = 0 {
        didSet {
            updateProgress()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView(color: color)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(color: color)
    }
    
    fileprivate func setupView(color: UIColor) {
        // Load the XIB
        let nib = UINib(nibName: "CircularProgressBarView", bundle: .main)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = self.bounds
        addSubview(view)
        
        // Ensure the label is centered programmatically - for some reason it's broken on storyboard
        totalProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalProgressLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            totalProgressLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // Set text alignment and text font
        totalProgressLabel.textAlignment = .center
        
        if let selectedFont = UIFont(name: "PlusJakartaSans-Medium", size: 12) {
            totalProgressLabel.font = selectedFont
            totalProgressLabel.textColor = UIColor(named: K.MainColors.white)
        }
        
        // Enable clipping to ensure the custom view stays inside the cell
        clipsToBounds = true
        
        // Create circular progress layer
        setupCircularLayers(progressColor: color)
    }
    
    // Method for creating the circular progress layer, for both background and progress layer
    fileprivate func setupCircularLayers(progressColor: UIColor) {
        // Create the background layer
        backgroundLayer = CAShapeLayer()
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor(named: K.MainColors.white)?.cgColor
        backgroundLayer.lineWidth = 5.0
        backgroundLayer.strokeEnd = 1.0
        layer.addSublayer(backgroundLayer)
        
        // Create the progress layer
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 5.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    // Will be called whenever the view layout changes
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure the path is updated
        backgroundLayer.path = createCircularPath().cgPath
        progressLayer.path = createCircularPath().cgPath
    }
    
    // Generates the circular path that is used for both layer to draw the progress
    func createCircularPath() -> UIBezierPath {
        let radius = (min(bounds.width, bounds.height) / 2) - 5 // Ensure this fits within the view bounds
        return UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), // Centers the circle within bound of view
            radius: radius,
            startAngle: -(.pi / 2), // Starts at the top
            endAngle: 1.5 * .pi,    // Complete circle
            clockwise: true
        )
    }
    
    // Method for updating the progress when either current or total value changes
    func updateProgress() {
        if (totalValue == 0) {
            setProgress(0.0)
        } else {
            let progress = CGFloat(currentValue) / CGFloat(totalValue)
            setProgress(progress)
        }
    }
    
    // Method for setting the progress bar and progress text
    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
        totalProgressLabel.text = "\(currentValue)/\(totalValue)"
    }
    
    func setColor(packingColor: UIColor) {
        self.color = packingColor
    }
}
