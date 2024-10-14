//
//  PackingViewModel.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 11/10/24.
//

import Foundation
import CoreData

class PackingViewModel {
    
    // Data Properties
    private var packings: [Packing] = []
    private var filteredPackings: [Packing] = []
    var isSearching: Bool = false
    
    // Output Binding Closures for data updates
    var reloadData: (() -> Void)?
    var showError: ((Error) -> Void)?
    
    // Fetch packings from Core Data and notify the ViewController to reload the data
    func fetchPackings() {
        packings = CoreDataManager.shared.fetchSortedPackings()
        reloadData?()
    }
    
    // Get total number of Packings
    func numberOfPackings() -> Int {
        return isSearching ? filteredPackings.count : packings.count
    }
    
    // Get specific Packing
    func packingAt(index: Int) -> Packing? {
        return isSearching ? filteredPackings[index] : packings[index]
    }
    
    // Delete a Packing then reload the packings after deletion
    func deletePacking(at index: Int) {
        let packingToDelete = packings[index]
        CoreDataManager.shared.context.delete(packingToDelete)
        CoreDataManager.shared.saveContext()
        packings.remove(at: index)
        fetchPackings()
    }
    
    // Search for a Packing
    func searchPacking(with query: String) {
        if query.isEmpty {
            isSearching = false
            filteredPackings.removeAll()
        } else {
            isSearching = true
            filteredPackings = packings.filter({$0.title?.lowercased().contains(query.lowercased()) ?? false})
        }
        reloadData?()
    }
    
    // Return a formatted start and end date for Packing
    func formattedDate(for packing: Packing) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let startDate = packing.startDate ?? Date()
        let endDate = packing.endDate ?? Date()
        let startDateFormatted = dateFormatter.string(from: startDate)
        let endDateFormatted = dateFormatter.string(from: endDate)
        
        return "\(startDateFormatted) - \(endDateFormatted)"
    }
    
    // Return a string of how many nights based on start date - end date
    func formattedNights(for packing: Packing) -> String {
        let calendar = Calendar.current
        let startDate = packing.startDate ?? Date()
        let endDate = packing.endDate ?? Date()
        
        // Calculate the differences in days
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let totalNights = components.day ?? 0
        
        return "\(totalNights) Nights"
    }
    
    // Calculate the total items across all categories inside the packing
    func totalCompletedItems(for packing: Packing) -> Int {
        var totalCompletedItems = 0
        
        if let categories = packing.categories?.allObjects as? [Category] {
            for category in categories {
                let itemsArray = (category.items?.allObjects as? [Item]) ?? []
                totalCompletedItems += itemsArray.filter({$0.done}).count
            }
        }
        
        return totalCompletedItems
    }

    // Calculate the total of completed items across all categories inside the packing
    func totalItems(for packing: Packing) -> Int {
        var totalItems = 0
        
        if let categories = packing.categories?.allObjects as? [Category] {
            for category in categories {
                let itemsArray = (category.items?.allObjects as? [Item]) ?? []
                totalItems += itemsArray.count
            }
        }
        return totalItems
    }
}
