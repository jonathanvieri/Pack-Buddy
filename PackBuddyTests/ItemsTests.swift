//
//  ItemsTests.swift
//  PackBuddyTests
//
//  Created by Jonathan Vieri on 12/11/24.
//

import XCTest
import CoreData

@testable import Pack_Buddy

final class ItemsTests: XCTestCase {

    //MARK: - Setup
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PackBuddy")
        
        let descriptor = NSPersistentStoreDescription()
        descriptor.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [descriptor]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to load in-memory Core Data store with error: \(error.localizedDescription)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager(container: persistentContainer)
    }
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }
    
    //MARK: - Positive Test Cases
    
    func testCreateItemInCategory() {
        // Given: Create a Packing and Category
        let packing = coreDataManager.createNewPacking(
            title: "Swimming in Bondi",
            location: "Beach",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.red
        )
        
        let category = coreDataManager.createNewCategory(
            title: "Swimming Stuff",
            symbol: "ferry",
            packing: packing
        )
        
        // When: Create a item associated with the Category
        let title = "Swimming Suit"
        
        let item = Item(context: coreDataManager.context)
        item.title = title
        item.done = false
        item.createdAt = Date()
        item.parentCategory = category
        
        coreDataManager.saveContext()
        
        // Then: Verify the item was created and associated correctly
        XCTAssertEqual(category.items?.count, 1, "Category should only contain one item")
        
        XCTAssertEqual(item.title, title, "Incorrect title for Item")
        XCTAssertEqual(item.done, false, "Incorrect done status for Item")
        XCTAssertEqual(item.parentCategory, category, "Item should be linked to the newly created Category")
    }
    
    func testFetchItemsInCategory() {
        // Given: Create a new Packing, Category and multiple associated Items
        let packing = coreDataManager.createNewPacking(
            title: "Swimming in Bondi",
            location: "Beach",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.red
        )
        
        let category = coreDataManager.createNewCategory(
            title: "Swimming Stuff",
            symbol: "ferry",
            packing: packing
        )
        
        let firstItem = Item(context: coreDataManager.context)
        firstItem.title = "Beach Ball"
        firstItem.done = false
        firstItem.createdAt = Date()
        firstItem.parentCategory = category
        
        let secondItem = Item(context: coreDataManager.context)
        secondItem.title = "Sunscreen"
        secondItem.done = false
        secondItem.createdAt = Date()
        secondItem.parentCategory = category
        
        coreDataManager.saveContext()
        
        // When: Fetch items related to the Category
        let items = category.items?.allObjects as? [Item]
        
        // Then: Verify correct Items are fetched
        XCTAssertEqual(items?.count, 2, "There should only be 2 items in the category")
        XCTAssertTrue(items?.contains(firstItem) ?? false, "First items hould be in the fetched items")
        XCTAssertTrue(items?.contains(secondItem) ?? false, "Second item should be in the fetched Items")
    }
    
    func testMarkItemAsDone() {
        // Given: Create a new Packing, Category, and Item
        let packing = coreDataManager.createNewPacking(
            title: "Food hunting in Rome",
            location: "City",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.red
        )
        
        let category = coreDataManager.createNewCategory(
            title: "Supplies",
            symbol: "house",
            packing: packing
        )
        
        let firstItem = Item(context: coreDataManager.context)
        firstItem.title = "Travel Bag"
        firstItem.done = false
        firstItem.createdAt = Date()
        firstItem.parentCategory = category
        
        let secondItem = Item(context: coreDataManager.context)
        secondItem.title = "Wallet"
        secondItem.done = true
        secondItem.createdAt = Date()
        secondItem.parentCategory = category
        
        coreDataManager.saveContext()
        
        // When: Mark the item as Done
        firstItem.done = true
        secondItem.done = false
        coreDataManager.saveContext()
        
        // Then: Verify that the Item is marked as Done
        XCTAssertTrue(firstItem.done, "First item should be marked as done.")
        XCTAssertFalse(secondItem.done, "Second item should be marked as not done")
    }
    
    //MARK: - Negative Test Cases
    func testCreateItemWithMissingFields() {
        // Given: Create a new Packing and Category
        let packing = coreDataManager.createNewPacking(
            title: "Food hunting in Rome",
            location: "City",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.red
        )
        
        let category = coreDataManager.createNewCategory(
            title: "Supplies",
            symbol: "house",
            packing: packing
        )
        
        // When: Create an Item associated with the category with nil values
        let item = Item(context: coreDataManager.context)
        item.title = nil
        item.done = false
        item.parentCategory = category
        
        // Then: Save the Item with missing fields
        do {
            try coreDataManager.context.save()
            XCTFail("Saving an Item with missing fields should have failed")
        } catch {
            XCTAssertNotNil(error, "Expected error due to existing missing required fields")
        }
    }
    
    func testFetchItemWithInvalidPredicate() {
        // Given: Create a new Packing, Category, and Item
        let packing = coreDataManager.createNewPacking(
            title: "Sightseeing at Melbourne",
            location: "Countryside",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.blue
        )
        
        let category = coreDataManager.createNewCategory(
            title: "Roadtrip Stuff",
            symbol: "sunset",
            packing: packing
        )
        
        let item = Item(context: coreDataManager.context)
        item.title = "Power Bank"
        item.done = false
        item.createdAt = Date()
        item.parentCategory = category
        
        coreDataManager.saveContext()
        
        // When: Attempt to fetch Items with predicate that won't match any entity
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", "Jungle Book")
        
        // Then: Verify no errors are thrown and empty result is returned
        do {
            let result = try coreDataManager.context.fetch(fetchRequest)
            XCTAssertTrue(result.isEmpty, "Expected no result for invalid predicate")
        } catch {
            XCTFail("No errors should be thrown when fetching with invalid predicate")
        }
    }
}
