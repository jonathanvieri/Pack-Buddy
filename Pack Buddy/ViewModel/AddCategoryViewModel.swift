//
//  AddCategoryViewModel.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 14/10/24.
//

import UIKit
import CoreData

class AddCategoryViewModel {
    
    // Data Properties
    var categoryName: String = ""
    var selectedSymbol: String?
    var selectedSymbolIndex: Int? = 0
    var parentPacking: Packing?
    var categoryToEdit: Category?
    
    let symbolArray: [String] = [
        "tv", "airplane", "book", "tshirt", "shoe", "comb", "backpack", "dumbbell", "basketball",
        "camera", "bag", "creditcard", "hammer", "suitcase", "puzzlepiece", "powerplug", "toilet",
        "key", "pill", "hanger", "binoculars", "car", "gamecontroller", "lightrail", "ferry",
        "truck.box", "bicycle", "house", "heart", "pill", "ear", "envelope", "umbrella"
    ]
    
    // Method for setting up the ViewModel depending on edit status
    func setup(for category: Category?, in parentPacking: Packing?) {
        if let category = category {
            self.categoryToEdit = category
            self.categoryName = category.title ?? ""
            self.selectedSymbol = category.symbol ?? symbolArray.first
        } else {
            selectedSymbol = symbolArray.first
        }
        self.selectedSymbolIndex = symbolArray.firstIndex(of: selectedSymbol ?? "")
        self.parentPacking = parentPacking
    }
    
    // Create or Update the Category
    func saveCategory() {
        guard let selectedSymbol = selectedSymbol, !categoryName.isEmpty else { return }
        
        if let category = categoryToEdit {
            // Update existing Category
            category.title = categoryName
            category.symbol = selectedSymbol
            CoreDataManager.shared.saveContext()
        } else if let parentPacking = parentPacking {
            // Create new category
            let newCategory = CoreDataManager.shared.createNewCategory(title: categoryName, symbol: selectedSymbol, packing: parentPacking)
            parentPacking.addToCategories(newCategory)
            CoreDataManager.shared.saveContext()
        }
    }
    
    // Return the index of selected symbol
    func indexOfSelectedSymbol() -> Int? {
        return symbolArray.firstIndex(of: selectedSymbol ?? "")
    }
    
    // Return the total count of symbol array
    func numberOfSymbols() -> Int {
        return symbolArray.count
    }
    
    // Return the symbol at the specified index
    func symbol(at index: Int) -> String {
        return symbolArray[index]
    }
    
    // Update the selected symbol
    func selectSymbol(index: Int) {
        selectedSymbol = symbolArray[index]
        selectedSymbolIndex = index
    }
    
    // Check if a symbol is selected at a specified index
    func isSymbolSelected(at index: Int) -> Bool {
        return index == selectedSymbolIndex
    }
    
    // Returns the IndexPath of the selected symbol
    func selectedSymbolIndexPath() -> IndexPath? {
        if let index = selectedSymbolIndex {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    // Method for validating the text length
    func validateTextLength(_ currentText: String, range: NSRange, replacementString: String, maxLength: Int) -> Bool {
        let currentString = currentText as NSString
        let newString = currentString.replacingCharacters(in: range, with: replacementString)
        return newString.count <= maxLength
    }
 }
