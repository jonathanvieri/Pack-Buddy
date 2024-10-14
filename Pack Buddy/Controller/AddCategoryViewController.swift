//
//  AddCategoryViewController.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 01/10/24.
//

import UIKit
import CoreData

class AddCategoryViewController : UIViewController {
    
    // IBOutlets
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var nameTextField: CustomTextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectIconLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Variables
    var parentPacking: Packing?
    var categoryToEdit: Category?
    private var viewModel = AddCategoryViewModel()
}

//MARK: - ViewController Lifecycle
extension AddCategoryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup colors
        setupUIColors()
       
        // Setup the textfield
        nameTextField.delegate = self
        nameTextField.customPlaceholder = "Category Name"
        
        // Setup the Collection View
        setupCollectionView()
        
        // Setup the Add Button
        setupAddButton()
        
        // Setup the ViewModel based on editing status
        viewModel.setup(for: categoryToEdit, in: parentPacking)
        
        // Setup the UI based on editing status
        if let category = categoryToEdit {
            configureForEditing(category)
        }
        
        // Setup tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension AddCategoryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSymbols()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.symbolCellIdentifier, for: indexPath) as! SymbolCollectionViewCell
        
        // Get the symbol from ViewModel
        let symbol = viewModel.symbol(at: indexPath.item)
        cell.symbolImageView.image = UIImage(systemName: symbol)
   
        // Configure the cell tint for selection
        let isSelected = viewModel.isSymbolSelected(at: indexPath.item)
        cell.configureSelected(isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectSymbol(index: indexPath.item)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}

//MARK: - UITextFieldDelegate
extension AddCategoryViewController : UITextFieldDelegate  {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewModel.validateTextLength(textField.text ?? "", range: range, replacementString: string, maxLength: 25)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Navigation
extension AddCategoryViewController {
    
    // Return to previous view, with value of new category
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        // Handle empty Category name
        guard let title = nameTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Show alert to the user to enter a category name value
            let alert = UIAlertController(title: "Error", message: "Please enter a category name", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
            
        // Assign the updated category name to the ViewModel
        viewModel.categoryName = title
        
        // Save the Category via the ViewModel
        viewModel.saveCategory()
        
        // Navigate back to previous view
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UI Helpers and Other Methods
extension AddCategoryViewController {
    
    // This method is for setting up the collection view
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: K.symbolNibName, bundle: .main), forCellWithReuseIdentifier: K.symbolCellIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
    
    // Method for setting up UI Colors
    private func setupUIColors() {
        view.backgroundColor = UIColor(named: K.MainColors.background)
        collectionView.backgroundColor = UIColor(named: K.MainColors.background)
        navigationController?.navigationBar.tintColor = UIColor(named: K.MainColors.white)
        mainTitleLabel.textColor = UIColor(named: K.MainColors.white)
        selectIconLabel.textColor = UIColor(named: K.MainColors.white)
    }
    
    // Method for setting up the Add Button
    private func setupAddButton() {
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.tintColor = UIColor(named: K.MainColors.white)
        
        // Use custom font for the button
        if let attrFont = UIFont(name: "PlusJakartaSans-Bold", size: 24) {
            var stringValue = "Add"
            if (categoryToEdit != nil) {
                stringValue = "Edit"
            }
            
            let attrTitle = NSAttributedString(string: stringValue, attributes: [NSAttributedString.Key.font: attrFont])
            addButton.setAttributedTitle(attrTitle, for: .normal)
        } else {
            print("Error! Font not found!")
        }
    }
    
    private func configureForEditing(_ category: Category) {
        mainTitleLabel.text = "Edit Category"
        nameTextField.text = viewModel.categoryName
        
        // Update the UI based on the selected symbol from the ViewModel
        if let symbolIndexPath = viewModel.selectedSymbolIndexPath() {
            collectionView.scrollToItem(at: symbolIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
