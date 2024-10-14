//
//  ItemsViewModel.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 14/10/24.
//

import UIKit
import CoreData

class ItemsViewModel {
    
    // Data Properties
    private var categories: [Category] = []
    
    // Get total number of categories
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    // Fetch sorted categories from specified Packing
    func fetchCategories(for packing: Packing) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentPacking == %@", packing)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            self.categories = try CoreDataManager.shared.context.fetch(fetchRequest)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    // Retrieve specific category at the given index
    func categoryAt(index: Int) -> Category {
        return categories[index]
    }
    
    // Method for getting title and symbol for a category
    func getCategoryDetails(for section: Int) -> (title: String, symbol: String) {
        let category = categories[section]
        return (category.title ?? "Category", category.symbol ?? "folder")
    }
    
    // Method to delete a Category at a specific index
    func deleteCategory(at index: Int) {
        let categoryToDelete = categories[index]
        
        // Delete the category from Core Data context
        CoreDataManager.shared.context.delete(categoryToDelete)
        CoreDataManager.shared.saveContext()
        
        // Remove the category from the local array
        categories.remove(at: index)
    }
    
    // Method for checking whether the section is open or not
    func isSectionOpen(_ section: Int) -> Bool {
        return categories[section].open
    }
    
    // Method for toggling the open state of a section
    func toggleSectionOpen(_ section: Int) {
        categories[section].open.toggle()
    }
    
    // Fetch sorted item for specific category
    func fetchItems(for category: Category) -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentCategory == %@", category)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            return try CoreDataManager.shared.context.fetch(fetchRequest)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    // Method to add a new Item to the specified category
    func addItem(to section: Int, title: String) {
        let category = categories[section]
        let newItem = Item(context: CoreDataManager.shared.context)
        newItem.title = title
        newItem.done = false
        newItem.createdAt = Date()
        
        // Add to specified category
        category.addToItems(newItem)
        
        CoreDataManager.shared.saveContext()
    }
    
    // Fetch the item for specific section
    func itemsForSection(_ section: Int) -> [Item] {
        let category = categories[section]
        return fetchItems(for: category)
    }
    
    // Return the total number of items in all categories
    func totalItems() -> Int {
        return categories.reduce(0) { (result, category) -> Int in
            return result + (category.items?.count ?? 0)}
    }
    
    // Returns the total number of items in a category and the number of completed item
    func getItemCounts(for section: Int) -> (totalItems: Int, doneItemCount: Int) {
        let category = categories[section]
        let items = fetchItems(for: category)
        let doneItemCount = items.filter {$0.done}.count
        return (items.count, doneItemCount)
    }
    
    // Returns the total number of items and completed items across all categories
    func itemCompletionStats() -> (totalItems: Int, completedItems: Int) {
        let totalItems = categories.flatMap { ($0.items?.allObjects as? [Item]) ?? [] }
        let completedItems = totalItems.filter{ $0.done }.count
        return (totalItems.count, completedItems)
    }
    
    // Retrieve specific item at a specific row in a section
    func itemAt(indexPath: IndexPath) -> Item? {
        let category = categories[indexPath.section]
        let items = fetchItems(for: category)
        
        // Return nil if it's the Add Item row
        return indexPath.row < items.count ? items[indexPath.row] : nil
    }
    
    // Method for toggling the item's done state
    func toggleItemDoneState(at indexPath: IndexPath) {
        if let item = itemAt(indexPath: indexPath) {
            item.done.toggle()
            CoreDataManager.shared.saveContext()
        }
    }
    
    // Method for deleting Item inside a Category
    func deleteItem(at indexPath: IndexPath) {
        if let item = itemAt(indexPath: indexPath) {
            CoreDataManager.shared.context.delete(item)
            CoreDataManager.shared.saveContext()
        }
    }
    
    // Method to get the new Item index path for scrolling purposes
    func newItemIndexPath(for section: Int) -> IndexPath? {
        let itemCount = categories[section].items?.count ?? 0
        return IndexPath(row: itemCount, section: section)
    }
    
    // Method to update the title of an item
    func updateItemTitle(at indexPath: IndexPath, with newTitle: String) {
        let category = categories[indexPath.section]
        let items = fetchItems(for: category)
        
        // Ensure the row exists within the items array
        guard indexPath.row < items.count else { return }
        
        let item = items[indexPath.row]
        item.title = newTitle
        
        CoreDataManager.shared.saveContext()
    }
}
