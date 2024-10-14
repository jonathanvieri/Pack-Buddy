//
//  AddPackingViewModel.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 13/10/24.
//

import UIKit
import CoreData

class AddPackingViewModel {
    
    // Data Properties and Variables
    var packingToEdit: Packing?
    var selectedColor: UIColor?
    var templates: [TemplateModel] = []
    var selectedTemplates: [TemplateModel] = []
    var predefinedLocations: [String] = []
    
    var packingTitle: String = ""
    var packingLocation: String = ""
    var startDate: Date?
    var endDate: Date?
    
    var isEditing: Bool {
        return packingToEdit != nil
    }
    
    // Constants
    final let availableColors = [
        UIColor(named: K.AdditionalColors.red),
        UIColor(named: K.AdditionalColors.orange),
        UIColor(named: K.AdditionalColors.yellow),
        UIColor(named: K.AdditionalColors.green),
        UIColor(named: K.AdditionalColors.blue),
        UIColor(named: K.AdditionalColors.purple),
        UIColor(named: K.AdditionalColors.pink)
    ]
    
    // Initialize with a Packing if editing
    init(packing: Packing? = nil) {
        packingToEdit = packing
        templates = getDefaultTemplates()
        predefinedLocations = getDefaultLocations()
        selectedColor = getRandomColor()
        
        if let packingToEdit = packingToEdit {
            packingTitle = packingToEdit.title ?? ""
            packingLocation = packingToEdit.location ?? ""
            startDate = packingToEdit.startDate
            endDate = packingToEdit.endDate
        }
    }
    
    // Method for getting the count of template
    func numberOfTemplates() -> Int {
        return templates.count
    }
    
    // Method for providing default value to templates variable
    func getDefaultTemplates() -> [TemplateModel] {
        return [
            TemplateModel(title: "Clothing", icon: "tshirt", isSelected: false),
            TemplateModel(title: "Documents", icon: "doc", isSelected: false),
            TemplateModel(title: "Toiletries", icon: "toilet", isSelected: false),
            TemplateModel(title: "Tech & Gadgets", icon: "smartphone", isSelected: false),
            TemplateModel(title: "Health & Safety", icon: "pill", isSelected: false)
        ]
    }
    
    // Get specific template
    func templateAt(index: Int) -> TemplateModel? {
        return templates[index]
    }
    
    // Method for toggling template when selected
    func toggleTemplateSelection(at index: Int) {
        templates[index].isSelected.toggle()
        
        if templates[index].isSelected {
            selectedTemplates.append(templates[index])
        } else {
            selectedTemplates.removeAll(where: {$0.title == templates[index].title})
        }
    }
    
    // Method for providing default location values
    private func getDefaultLocations() -> [String] {
        return [
            "Beach", "City", "Mountain", "Forest", "Desert", "Countryside", "Island"
        ]
    }
    
    // Method to get number of locations
    func numberOfLocations() -> Int {
        return predefinedLocations.count
    }
    
    // Get specific location
    func locationAt(index: Int) -> String {
        return predefinedLocations[index]
    }
    
    // Method for selecting a location
    func selectLocation(at index: Int) {
        packingLocation = predefinedLocations[index]
    }
    
    // Method for validating text length
    func validateTextLength(_ currentText: String, range: NSRange, replacementString: String, maxLength: Int) -> Bool {
        let currentString: NSString = currentText as NSString
        let newString = currentString.replacingCharacters(in: range, with: replacementString)
        return newString.count <= maxLength
    }
    
    // Method for formatting Date to a specific style
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    // Method for validating if all fields are filled
    func validateFields() -> Bool {
        return !packingTitle.isEmpty &&
        !packingLocation.isEmpty &&
        startDate != nil &&
        endDate != nil
    }
    
    // Method for adding a new Packing and modifying existing Packing
    func savePacking() {
        
        guard validateFields() else {
            return print("Please fill all fields")
        }
        
        if let packing = packingToEdit {
            // Modify existing Packing
            packing.title = packingTitle
            packing.location = packingLocation
            packing.startDate = startDate
            packing.endDate = endDate
            CoreDataManager.shared.saveContext()
        } else {
            // Create new Packing
            let newPacking = CoreDataManager.shared.createNewPacking(
                title: packingTitle,
                location: packingLocation,
                startDate: startDate!,
                endDate: endDate!,
                color: selectedColor ?? .additionalOrange
            )
            
            // Add selected templates
            let selectedTemplates = self.templates.filter({ $0.isSelected })
            for template in selectedTemplates {
                
                // Create new Category
                let newCategory = CoreDataManager.shared.createNewCategory(
                    title: template.title,
                    symbol: template.icon,
                    packing: newPacking
                )
                newCategory.open = false
                
                // Create item and add it to categories
                let selectedItems = CoreDataManager.shared.createItemsFromSelectedTemplates(selectedTemplate: template)
                
                newCategory.addToItems(NSSet(array: selectedItems))
                
                // Add the category with item to the Packing
                newPacking.addToCategories(newCategory)
            }
            
            CoreDataManager.shared.saveContext()
        }
    }
    
    // Method for updating the start date
    func updateStartDate(_ date: Date) {
        startDate = date
    }
    
    // Method for updating the end date and validate that it's after the start date
    func updateEndDate(_ date: Date) -> Bool {
        guard let startDate = startDate else { return false }
        
        if date > startDate {
            endDate = date
            return true
        } else {
            endDate = nil
            return false
        }
    }
    
    // Method for verifying if the end date is after the start date
    func isEndDateValid() -> Bool {
        guard let startDate = startDate, let endDate = endDate else { return false }
        return endDate >= startDate
    }
    
    // Method for getting a random color for packing's color
    func getRandomColor() -> UIColor? {
        return availableColors.randomElement() ?? .additionalOrange
    }
    
}
