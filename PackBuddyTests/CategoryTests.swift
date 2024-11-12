//
//  CategoryTests.swift
//  PackBuddyTests
//
//  Created by Jonathan Vieri on 12/11/24.
//

import XCTest
import CoreData

@testable import Pack_Buddy

final class CategoryTests: XCTestCase {

    //MARK: - Setup
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PackBuddy")
        
        let descriptor = NSPersistentStoreDescription()
        descriptor.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [descriptor]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to load in-memory Core Data store: \(error.localizedDescription)")
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
    func testCreateCategoryForPacking() {
        // Given: Create a new packing entity
        let newPacking = coreDataManager.createNewPacking(
            title: "Trip to Georgia",
            location: "City",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.red
        )
        
        // When: Create a Category associated with the newly created packing
        let title = "Documents"
        let symbol = "folder"
        
        let category = coreDataManager.createNewCategory(
            title: title,
            symbol: symbol,
            packing: newPacking
        )
        
        // Then: Verify that the category was created and associated correctly
        XCTAssertEqual(category.title, title, "Category title is incorrect")
        XCTAssertEqual(category.symbol, symbol, "Category symbol is incorrect")
        XCTAssertEqual(category.parentPacking, newPacking, "Category should be linked to the newly created Packing")
        
        XCTAssertEqual(newPacking.categories?.count, 1, "Packing should contain one category")
    }
    
    func testFetchCategoriesForPacking() {
        // Given: Create a new Packing with some Categories
        let newPacking = coreDataManager.createNewPacking(
            title: "Trip to Alaska",
            location: "Mountain",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.blue
        )
        
        let firstCategory = coreDataManager.createNewCategory(
            title: "Documents",
            symbol: "folder",
            packing: newPacking
        )
        
        let secondCategory = coreDataManager.createNewCategory(
            title: "Basketball Gears",
            symbol: "basketball",
            packing: newPacking
        )
        
        // When: Fetch all categories related with the created Packing
        let categories = newPacking.categories?.allObjects as? [Pack_Buddy.Category]
        
        // Then: Verify that correct Categories are fetche
        XCTAssertEqual(categories?.count, 2, "There should only be two Categories for the newly created Packing")
        XCTAssertTrue(categories?.contains(firstCategory) ?? false, "First category should be in fetched categories")
        XCTAssertTrue(categories?.contains(secondCategory) ?? false, "Second category should be in fetched categories")
    }
    
    //MARK: - Negative Test Cases
    func testCreateCategoryWithMissingFields() {
        // Given: Create a new Packing
        let newPacking = coreDataManager.createNewPacking(
            title: "Hiking Mt Semeru",
            location: "Mountain",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.blue
        )
        
        // When: Create new Category with missing fields
        let category = Category(context: coreDataManager.context)
        category.title = nil
        category.symbol = nil
        category.parentPacking = newPacking
        
        // Then: Try saving Category with missing fields
        do {
            try coreDataManager.context.save()
            XCTFail("Saving category with missing fields should have failed")
        } catch {
            XCTAssertNotNil(error, "Expected an error due to missing fields during Category creation")
        }
    }
    
    func testFetchCategoryWithInvalidPredicate() {
        // Given: Create a Packing and a Category associated to it
        let newPacking = coreDataManager.createNewPacking(
            title: "Swimming in Bahamas",
            location: "Beach",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            color: UIColor.blue
        )
        
        let _ = coreDataManager.createNewCategory(
            title: "Sport Stuff",
            symbol: "basketball",
            packing: newPacking
        )
        
        // When: Fetch Categories with predicate that won't match any existing Categories
        let fetchRequest: NSFetchRequest<Pack_Buddy.Category> =  Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", "Unknown Category")
        
        // Then: Fetch should return empty collection and not throw any errors
        do {
            let results = try coreDataManager.context.fetch(fetchRequest)
            XCTAssertTrue(results.isEmpty, "Expected no results for invalid predicate")
        } catch {
            XCTFail("Fetching with invalid predicate should not throw an error")
        }
    }
}
