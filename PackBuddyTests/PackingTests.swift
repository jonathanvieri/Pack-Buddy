//
//  PackingTests.swift
//  PackBuddyTests
//
//  Created by Jonathan Vieri on 11/11/24.
//

import XCTest
import CoreData

@testable import Pack_Buddy

final class PackingTests: XCTestCase {
    
    //MARK: - Setup
    
    // Setup Core Data to use in-memory
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PackBuddy")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
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
        
        // Initialize CoreDataManager with in-memory container
        coreDataManager = CoreDataManager(container: persistentContainer)
    }
    
    override func tearDown() {
        // Cleanup after each test
        coreDataManager = nil
        super.tearDown()
    }
    
    //MARK: - Positive Test Cases

    func testCreatePacking() {
        // Given: Setup attributes for a new Packing
        let title = "Trip to Bali"
        let startDate = Date()
        let location = "Bali"
        let endDate = Date().addingTimeInterval(86400 * 7)
        let color = UIColor.blue
        
        // When: Create and save new Packing
        let _ = coreDataManager.createNewPacking(
            title: title,
            location: location,
            startDate: startDate,
            endDate: endDate,
            color: color
        )
        
        // Then: Verify the data was saved correctly
        let packings = coreDataManager.fetchAllPackings()
        XCTAssertEqual(packings.count, 1, "There should be only one packing entity saved, but found \(packings.count)")
        
        if let packing = packings.first {
            XCTAssertEqual(packing.title, title, "The title of packing should be \(title)")
            XCTAssertEqual(packing.startDate, startDate, "The startDate should be \(startDate)")
            XCTAssertEqual(packing.location, location, "The location should be \(location)")
            XCTAssertEqual(packing.endDate, endDate, "The endDate should be \(endDate)")
            XCTAssertEqual(packing.color, color, "The color should be \(color)")
        } else {
            XCTFail("No packing is saved")
        }
    }

    func testFetchAllPackings() {
        // Given: Create multiple packings
        let _ = coreDataManager.createNewPacking(title: "Trip 1", location: "Location 1", startDate: Date(), endDate: Date().addingTimeInterval(86400), color: UIColor.red)
        let _ = coreDataManager.createNewPacking(title: "Trip 2", location: "Location 2", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 2), color: UIColor.green)
        let _  = coreDataManager.createNewPacking(title: "Trip 3", location: "Location 3", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 3), color: UIColor.blue)
        
        // When: Fetch all packings
        let packings = coreDataManager.fetchAllPackings()
        
        // Then: Verify correct number of packings was returned
        XCTAssertEqual(packings.count, 3, "There should only be three packing entities, but found \(packings.count)")
    }
    
    func testFetchSortedPackings() {
        // Given: Create multiple packings with different createdAt
        let packing1 = coreDataManager.createNewPacking(title: "Trip 1", location: "Location 1", startDate: Date(), endDate: Date().addingTimeInterval(86400), color: UIColor.red)
        let packing2 = coreDataManager.createNewPacking(title: "Trip 2", location: "Location 2", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 2), color: UIColor.green)
        let packing3 = coreDataManager.createNewPacking(title: "Trip 3", location: "Location 3", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 3), color: UIColor.blue)

        // Manually change the createdAt time
        packing2.createdAt = Date()
        packing1.createdAt = Date().addingTimeInterval(600)
        packing3.createdAt = Date().addingTimeInterval(601)
        
        coreDataManager.saveContext()
        
        // When: Fetch sorted packings
        let packings = coreDataManager.fetchSortedPackings()
        
        // Then: Verify sorting order
        XCTAssertEqual(packings.count, 3, "There should only be three packing entities, but found \(packings.count)")
        
        XCTAssertEqual(packings[0].title, "Trip 2", "First item should be earliest item (Trip 2)")
        XCTAssertEqual(packings[1].title, "Trip 1", "Second item should be second earliest item (Trip 1)")
        XCTAssertEqual(packings[2].title, "Trip 3", "Third item should be the latest item (Trip 3)")
    }

    //MARK: - Negative Test Cases
    
    func testCreatePackingWithMissingFields() {
        // Given: Create a Packing entity with missing required field
        let packing = Packing(context: coreDataManager.context)
        packing.title = "New Packing"
        
        // When: Attempt to save the context
        do {
            try coreDataManager.context.save()
            XCTFail("Saving should fail due to missing required fields")
        } catch {
            // Then: Verify an error is thrown
            XCTAssertNotNil(error, "Expected error due to missing required fields")
        }
    }
    
    func testFetchAllPackingsWithNoData() {
        // When: Fetch all packings with no data
        let packings = coreDataManager.fetchAllPackings()
        
        // Then: Verify result is empty
        XCTAssertTrue(packings.isEmpty, "Expected no packings, but found \(packings.count) items")
    }
    
    func testFetchSortedPackingsWithNoData() {
        // When: Fetch sorted packings with no data
        let packings = coreDataManager.fetchSortedPackings()
        
        // Then:
        XCTAssertTrue(packings.isEmpty, "Expected no packings, but found \(packings.count) items")
    }
}
