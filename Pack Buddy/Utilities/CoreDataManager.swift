//
//  CoreDataManager.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 10/10/24.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    // Context to interact with Core Data
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Default initializer
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "PackBuddy")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    // Custom initializer for testing, allowing injection of different NSPersistentContainer
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Packing Methods
    
    // Creates a new packing entity in the Core Data context, then calls saveContext() to persist the changes
    func createNewPacking(title: String, location: String, startDate: Date, endDate: Date, color: UIColor) -> Packing {
        let packing = Packing(context: context)
        packing.title = title
        packing.location = location
        packing.startDate = startDate
        packing.endDate = endDate
        packing.color = color
        packing.createdAt = Date()
        
        saveContext()
        return packing
    }

    // Uses the context to fetch all Packing objects
    func fetchAllPackings() -> [Packing] {
        let request: NSFetchRequest<Packing> = Packing.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch packings: \(error)")
            return []
        }
    }
    
    func fetchSortedPackings() -> [Packing] {
        let fetchRequest: NSFetchRequest<Packing> = Packing.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let sortedPackings = try context.fetch(fetchRequest)
            return sortedPackings
        } catch {
            print("Error fetching packings: \(error)")
            return []
        }
    }
    
    
    //MARK: - Category Methods
    
    // Creates a new category entity in the Core Data context, then calls saveContext to persist the changes
    func createNewCategory(title: String, symbol: String, packing: Packing) -> Category {
        let category = Category(context: context)
        category.title = title
        category.symbol = symbol
        category.parentPacking = packing
        category.createdAt = Date()
        
        saveContext()
        return category
    }

    
    //MARK: - Items Methods
    
    func createItemsFromSelectedTemplates(selectedTemplate: TemplateModel) -> [Item] {
        var items = [Item]()
        
        switch selectedTemplate.title {
        case "Clothing":
            items = createItemsFromTitles(["Shirts", "Pants", "Shorts", "Underwear", "Sweater", "Socks", "Sleepwear", "Hat", "Shoes", "Sandals"])
        case "Documents":
            items = createItemsFromTitles(["Passport", "Boarding Pass", "Flight Ticket", "Visa", "Travel Insurance", "Hotel Reservation", "Driver's License", "ID"])
        case "Toiletries":
            items = createItemsFromTitles(["Toothbrush", "Toothpaste", "Shampoo", "Conditioner", "Body Wash", "Deodorant", "Face Wash", "Perfume", "Sunscreen", "Comb"])
        case "Tech & Gadgets":
            items = createItemsFromTitles(["Smartphone", "Laptop", "Tablet", "Chargers", "Power Bank", "Headphones", "Camera", "Travel Adapter", "Portable Speaker", "Smartwatch"])
        case "Health & Safety":
            items = createItemsFromTitles(["First Aid Kit", "Prescription Medication", "Face Masks", "Hand Sanitizer", "Insect Repellent", "Antibacterial Wipes", "Band-Aids", "Pain Relievers"])
        default:
            print("Template not found!")
        }
        
        return items
    }
    
    //
    func createItemsFromTitles(_ titles: [String]) -> [Item] {
        var items = [Item]()
        
        for title in titles {
            let newItem = Item(context: CoreDataManager.shared.context)
            newItem.title = title
            newItem.done = false
            newItem.createdAt = Date()
            items.append(newItem)
        }
        
        return items
    }
}
