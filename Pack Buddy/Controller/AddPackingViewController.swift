//
//  AddPackingViewController.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 07/10/24.
//

import UIKit

class AddPackingViewController : UIViewController {
    
    // IBOutlets
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var packingNameTextField: CustomTextField!
    @IBOutlet weak var locationTextField: CustomTextField!
    @IBOutlet weak var startDateTextField: CustomTextField!
    @IBOutlet weak var endDateTextField: CustomTextField!
    @IBOutlet weak var addTemplatesLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Constants
    final let mainWhite = UIColor(named: K.MainColors.white)
    final let mainBackground = UIColor(named: K.MainColors.background)
    
    // Variables
    private var viewModel = AddPackingViewModel()
    var packingToEdit: Packing? 
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    
    // Pickers Variable
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let locationPicker = UIPickerView()
}

//MARK: - ViewController LifeCycle
extension AddPackingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AddPackingViewModel(packing: packingToEdit)
        
        // Setup the UI (Colors, Delegate and Placeholders)
        setupUI()
        
        // Setup the location and date pickers
        setupLocationPicker()
        setupDatePickers()
        
        // Setup the collection view
        setupCollectionView()
        
        // Configure the add button
        configureAddButton()
        
        // Bind the view model - setup if editing a category
        bindViewModel()
        
        // Add gesture recognizer to dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension AddPackingViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfTemplates()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.addPackingCellIdentifier, for: indexPath) as! PackingCollectionViewCell
        
        if let template = viewModel.templateAt(index: indexPath.row) {
            cell.configure(template: template)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Toggle the selected value
        viewModel.toggleTemplateSelection(at: indexPath.row)
        
        if let template = viewModel.templateAt(index: indexPath.row),
           let cell = collectionView.cellForItem(at: indexPath) as? PackingCollectionViewCell {
            
            UIView.transition(with: cell.checkmarkImageView, duration: 0.3, options: .transitionCrossDissolve) {
                let isSelected = template.isSelected
                
                let checkmarkIcon = isSelected ? "checkmark" : "plus"
                let tintColor = isSelected ? UIColor(named: K.MainColors.white) : .black
                cell.checkmarkImageView.image = UIImage(systemName: checkmarkIcon)
                cell.checkmarkImageView.tintColor = tintColor
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

//MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension AddPackingViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfLocations()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.locationAt(index: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectLocation(at: row)
        locationTextField.text = viewModel.packingLocation
    }
}

//MARK: - UITextFieldDelegate
extension AddPackingViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Disable typing for location and date textfields
        if (textField == locationTextField || textField == startDateTextField || textField == endDateTextField) {
            return false
        }
        
        let maxLength = 20
        return viewModel.validateTextLength(textField.text ?? "", range: range, replacementString: string, maxLength: maxLength)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when the return key is pressed
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Navigation
extension AddPackingViewController {
    
    @IBAction func addButtonpressed(_ sender: UIButton) {
        
        // Assign the values from text fields
        viewModel.packingTitle = packingNameTextField.text ?? ""
        viewModel.packingLocation = locationTextField.text ?? ""
        viewModel.startDate = selectedStartDate
        viewModel.endDate = selectedEndDate
        
        // Save the packing
        viewModel.savePacking()
        
        // Pop to previous view
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UI Helpers and Other Methods
extension AddPackingViewController {
    
    // Setting up the date pickers
    func setupDatePickers() {
        // Set the mode to Date only
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
        
        // Set the preferred style
        startDatePicker.preferredDatePickerStyle = .inline
        endDatePicker.preferredDatePickerStyle = .inline
        
        // Set the minimum date and set it as default value
        let today = Date()
        startDatePicker.minimumDate = today
        
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) {
            endDatePicker.minimumDate = tomorrow
        }
        
        // Assign the date pickers as input to the textfields
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
        
        // Create a toolbar with "Done" button to dismiss the picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        
        // Assign toolbar to the textfields
        startDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputAccessoryView = toolbar
        
        // Add target to update the date textfields when date is selected
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        
        // Add target to all textfields to detect changes
        packingNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        locationTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        startDatePicker.addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
    }
    
    // Setting up the location picker
    func setupLocationPicker() {
        
        // Set the delegate
        locationPicker.delegate = self
        locationPicker.dataSource = self
        
        // Set location picker as the inputView for location text field
        locationTextField.inputView = locationPicker
        
        // Create a toolbar with "Done" button to dismiss the picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        
        // Attach the toolbar as an accessory view for the text field
        locationTextField.inputAccessoryView = toolbar
        
    }
    
    // Closes the date picker view when done button is pressed
    @objc func doneButtonPressed() {
        view.endEditing(true)
    }
    
    // Updates the start date text field when date is selected
    @objc func startDateChanged() {
        
        let chosenDate = startDatePicker.date
        startDateTextField.text = viewModel.formatDate(chosenDate)
        
        // Update the startDate in the ViewModel
        viewModel.updateStartDate(chosenDate)
        selectedStartDate = chosenDate
        
        // Set the minimum date for end date to be minimum at start date
        endDatePicker.minimumDate = viewModel.startDate
        
        // Clear the end date if it already has value and less than starting date
        if !viewModel.isEndDateValid() {
            print("End date is not valid")
            endDateTextField.text = ""
            selectedEndDate = nil
            viewModel.endDate = nil
        }
        
        textFieldDidChange()
    }
    
    // This method is called when the end date is changed
    @objc func endDateChanged() {
        let chosenDate = endDatePicker.date
        endDateTextField.text = viewModel.formatDate(chosenDate)
        selectedEndDate = chosenDate
        
        if !viewModel.updateEndDate(chosenDate) {
            endDateTextField.text = ""
        }
        
        textFieldDidChange()
    }
    
    // Method that is called when any one of the textfield is called
    @objc func textFieldDidChange() {
        guard let packingtitle = packingNameTextField.text, let packingLocation = locationTextField.text else { return }
        
        // Update the value in ViewModel
        viewModel.packingTitle = packingtitle
        viewModel.packingLocation = packingLocation
        
        addButton.isEnabled = viewModel.validateFields()
    }
    
    // Method for configuring the Add button
    private func configureAddButton() {
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.tintColor = mainWhite
        
        // Use custom font for the button
        if let attrFont = UIFont(name: "PlusJakartaSans-Bold", size: 24) {
            var stringValue = "Add"
            if (packingToEdit != nil) {
                stringValue = "Edit"
            }
            
            let attrTitle = NSAttributedString(string: stringValue, attributes: [NSAttributedString.Key.font: attrFont])
            addButton.setAttributedTitle(attrTitle, for: .normal)
        }
        
        // Disable the Add Button initially
        addButton.isEnabled = false
    }
    
    // Method for setting up the UI Colors, Placeholder and Delegates
    private func setupUI() {
        
        // Setup basic colors
        view.backgroundColor = mainBackground
        navigationController?.navigationBar.tintColor = mainWhite
        mainTitleLabel.textColor = mainWhite
        addTemplatesLabel.textColor = mainWhite
        
        // Setup placeholder for the text labels
        packingNameTextField.customPlaceholder = "Packing Name"
        locationTextField.customPlaceholder = "Location"
        startDateTextField.customPlaceholder = "Start Date"
        endDateTextField.customPlaceholder = "End Date"
        
        // Setup delegate for the text field
        packingNameTextField.delegate = self
        locationTextField.delegate = self
        startDateTextField.delegate = self
        endDateTextField.delegate = self
    }
    
    // Method for setting up the CollectionView
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: K.addPackingNibName, bundle: .main), forCellWithReuseIdentifier: K.addPackingCellIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
    
    // Method for binding the ViewModel and setup if editing a Packing
    func bindViewModel() {
        if viewModel.isEditing {
            mainTitleLabel.text = "Edit Packing"
            packingNameTextField.text = viewModel.packingTitle
            locationTextField.text = viewModel.packingLocation
            
            // Setup the start and end date
            if let startDate = viewModel.startDate, let endDate = viewModel.endDate {
                startDateTextField.text = viewModel.formatDate(startDate)
                endDateTextField.text = viewModel.formatDate(endDate)
            }
            
            selectedStartDate = viewModel.startDate
            selectedEndDate = viewModel.endDate
            
            // Disable the template selection
            addTemplatesLabel.isHidden = true
            collectionView.isHidden = true
                
            // Enable add button since all value should be filled
            addButton.isEnabled = true
        }
    }
    
    // Method to dismiss keyboard when pressing anywhere on the view
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
