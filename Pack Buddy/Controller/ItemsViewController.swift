//
//  ItemsViewController.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 26/09/24.
//

import UIKit

class ItemsViewController : UIViewController {
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // Constants
    final let tableHeaderHeight: CGFloat = 240
    final let sectionHeaderHeight: CGFloat = 70
    final let cellHeight: CGFloat = 60
    
    // Variables
    var addCategoryBarButton: UIBarButtonItem?
    var selectedCategoryView: UIView?
    private var viewModel = ItemsViewModel()
    
    // Parent packing from PackingViewController and the categories variable set from it
    var parentPacking: Packing?
}

//MARK: - ViewController Lifecycle
extension ItemsViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch the updated list of Categories from Core Data using ViewModel
        if let packing = parentPacking {
            viewModel.fetchCategories(for: packing)
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the categories for the selected packing from Core Data
        if let packing = self.parentPacking{
            viewModel.fetchCategories(for: packing)
        }
        
        // Setup the table view
        setupTableView()
        
        // Setup colors and store the right bar button item
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the observer for text changes
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
}

//MARK: -  UITableViewDataSource, UITableViewDelegate
extension ItemsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = viewModel.categoryAt(index: section)
        return category.open ? viewModel.fetchItems(for: category).count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let item = viewModel.itemAt(indexPath: indexPath) {
            // Normal item cell
            let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellIdentifier, for: indexPath) as! ItemCell
            cell.itemTitle.text = item.title
            cell.setCheckmark(item.done)
            
            // Add long press gesture for editing value
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(editItem(_:)))
            cell.addGestureRecognizer(longPressGesture)
            
            return cell
        } else {
            // Handling for the Add Item row
            let cell = tableView.dequeueReusableCell(withIdentifier: K.addItemCellIdentifier, for: indexPath) as! AddItemCell
            cell.addItemLabel.text = "Add Item"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Fetch category details from the ViewModel
        let categoryDetails = viewModel.getCategoryDetails(for: section)
        let itemCounts = viewModel.getItemCounts(for: section)
        let isOpen = viewModel.isSectionOpen(section)
        
        // Setup section header view
        let sectionHeaderView = ItemsSection(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: sectionHeaderHeight))
        
        // Configure the header view using data from ViewModel
        sectionHeaderView.configure(
            title: categoryDetails.title,
            currentProgress: itemCounts.doneItemCount,
            progressTotal: itemCounts.totalItems,
            symbol: categoryDetails.symbol
        )
        
        // Update chevron image based on section's open or closed state
        sectionHeaderView.updateChevron(isOpen: isOpen)
        
        // Handle opening and closing the section
        sectionHeaderView.openCloseButton.tag = section
        sectionHeaderView.openCloseButton.addTarget(self, action: #selector(self.openSection), for: .touchUpInside)
        
        // Add long press gesture recognizer for editing & deleting
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressSection(_:)))
        sectionHeaderView.openCloseButton.addGestureRecognizer(longPressGesture)
        
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Fetch the relevant category and item data from the ViewModel
        if let item = viewModel.itemAt(indexPath: indexPath) {
            // Toggle the done state
            viewModel.toggleItemDoneState(at: indexPath)
            
            // Reload the section and header view
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            updateHeaderView(animated: true)
        } else {
            // When Add Item cell is pressed, show alert for adding item
            showAddItemDialog(for: indexPath.section)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Fetch the relevant category and item data from the ViewModel
        if let item = viewModel.itemAt(indexPath: indexPath) {
            
            // If it's not Add Item row, show swipe actions
            let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { UIContextualAction, view, completionHandler in
                
                // Delete the item through ViewModel
                self.viewModel.deleteItem(at: indexPath)
                
                // Reload the section and header view
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                self.updateHeaderView(animated: true)
                
                // Indicate the action has been hadnled
                completionHandler(true)
            }
            deleteItem.title = "Delete"
            
            let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])
            return swipeActions
        }
        
        // Return nil if add item row
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

//MARK: - Navigation
extension ItemsViewController {
    
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAddCategory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToAddCategory") {
            let addCategoryVC = segue.destination as! AddCategoryViewController
            
            // Check if sender is Int, which means we're editing an existing category
            if let section = sender as? Int {
                // Fetch the category details from the ViewModel
                let categoryDetails = viewModel.categoryAt(index: section)
                addCategoryVC.categoryToEdit = categoryDetails
            } else {
                // Adding new category
                addCategoryVC.parentPacking = self.parentPacking
            }
        }
    }
}

//MARK: - UI Helpers and Other Methods
extension ItemsViewController {
    
    @objc func openSection(button: UIButton) {
        let section = button.tag
        
        // Use the ViewModel for the number of items in the section
        let itemsArray = viewModel.itemsForSection(section)
        var indexPaths = [IndexPath]()
        
        // Collect index paths for each row in the section
        for row in 0...itemsArray.count {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        // Check if the current section is open or not
        let isOpen = viewModel.isSectionOpen(section)
        viewModel.toggleSectionOpen(section)
        
        tableView.beginUpdates()
        if isOpen {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        tableView.endUpdates()
        
        // Update chevron in the header view
        if let sectionHeader = tableView.headerView(forSection: section) as? ItemsSection {
            sectionHeader.updateChevron(isOpen: !isOpen)
        }
        
        // Scroll to the section header after the updates
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: NSNotFound, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func longPressSection(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let button = gesture.view as? UIButton, let categoryView = button.superview else { return }
        
        let section = button.tag
        
        // Store the add category bar button if not stored on viewDidLoad
        if addCategoryBarButton == nil {
            addCategoryBarButton = navigationItem.rightBarButtonItem
        }
        
        // Store the current selected view
        selectedCategoryView = categoryView
        
        // Change the color to show it's being selected
        UIView.animate(withDuration: 0.3) {
            categoryView.backgroundColor = UIColor(named: K.MainColors.grayLower)
        }
        
        // Create the cancel button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditSection))
        
        // Create the edit button
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editSection(_:)))
        editButton.tag = section
        editButton.tintColor = UIColor(named: K.MainColors.white)
            
        // Create the delete button
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(deleteSection(_:)))
        deleteButton.tag = section
        deleteButton.tintColor = UIColor(named: K.AdditionalColors.red)
        
        // Set cancel button to left navigation bar
        navigationItem.leftBarButtonItem = cancelButton
        
        // Set both edit and delete button to right navigation bar
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
    }
    
    @objc func editSection(_ sender: UIBarButtonItem) {
        let section = sender.tag
        performSegue(withIdentifier: "goToAddCategory", sender: section)
        restoreAddCategoryBarButton()
        restoreSectionColor()
    }
    
    @objc func editItem(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        guard let cell = gesture.view as? ItemCell,
        let indexPath = tableView.indexPath(for: cell) else { return }
        
        if let item = viewModel.itemAt(indexPath: indexPath) {
            showEditItemDialog(for: indexPath.section, row: indexPath.row)
        }
    }
                                             
    @objc func deleteSection(_ sender: UIBarButtonItem) {
        let section = sender.tag
        showDeleteSectionDialog(section: section)
        updateHeaderView(animated: true)
    }
    
    @objc func cancelEditSection() {
        restoreAddCategoryBarButton()
        restoreSectionColor()
    }
    
    // Method for updating the values inside header view (Total Item, Progress Bar & Percentage)
    func updateHeaderView(animated: Bool) {
        guard let headerView = tableView.tableHeaderView as? ItemsHeaderView else { return }
        
        // Get the total and completed items from the ViewModel
        let itemStats = viewModel.itemCompletionStats()
        
        // Update the total item label
        headerView.totalItemLabel.text = "\(itemStats.totalItems) Items"
        
        // Update the progress bar
        let percentage = itemStats.totalItems == 0 ? 0 : Float(itemStats.completedItems) / Float(itemStats.totalItems)
        headerView.progressBarView.setProgress(percentage, animated: animated)
        
        // Update the percentage label
        let percentageIntFormat = Int(percentage * 100)
        headerView.progressPercentageLabel.text = "\(percentageIntFormat)%"
    }
    
    // Method for updating the header color
    func configureHeaderView() {
        guard let headerView = tableView.tableHeaderView as? ItemsHeaderView else { return }
        guard let packing = parentPacking else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        if let startDate = packing.startDate, let endDate = packing.endDate {
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            let title = packing.title ?? "Untitled Packing"
            let color = packing.color as! UIColor
            let location = packing.location ?? "location"
            
            headerView.configure(packingTitle: title, packingLocation: location, packingColor: color, startDate: startDateString, endDate: endDateString)
        }
    }
    
    // Method for deleting a category, it will show an alert asking for user confirmation
    func showDeleteSectionDialog(section: Int) {
        
        let alert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete this category?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // Delegate category deletion to the ViewModel
            self.viewModel.deleteCategory(at: section)
            
            // Reload the table after deletion
            self.tableView.reloadData()
            self.updateHeaderView(animated: true)
            self.restoreAddCategoryBarButton()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.restoreAddCategoryBarButton()
            self.restoreSectionColor()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // Method for restoring the add category button on navigation bar
    func restoreAddCategoryBarButton() {
        if let addCategoryButton = addCategoryBarButton {
            navigationItem.rightBarButtonItems = [addCategoryButton]
            navigationItem.leftBarButtonItem = nil
        }
    }
    
   // Method for restoring the selected category into original color
    func restoreSectionColor() {
        if let categoryView = selectedCategoryView {
            UIView.animate(withDuration: 0.3) {
                categoryView.backgroundColor = UIColor(named: K.MainColors.background)
            }
        }
    }
    
    // Method for adding a new item
    func showAddItemDialog(for section: Int) {
        
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        var alertTextfield = UITextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let newItemTitle = alertTextfield.text, !newItemTitle.isEmpty else { return }
            
            // Add a new item to the Category
            self.viewModel.addItem(to: section, title: newItemTitle)
            
            // Reload to reflect the new Item
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
            self.updateHeaderView(animated: true)

            // Scroll to the new item
            if let newIndexPath = self.viewModel.newItemIndexPath(for: section) {
                self.tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
            }
        }
        addAction.isEnabled = false // Disable until user enters a value
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { textfield in
            textfield.placeholder = "Add a new item"
            alertTextfield = textfield
            
            // Observe the textfield
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textfield, queue: .main) { _ in
                let isTextEmpty = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
                addAction.isEnabled = !isTextEmpty
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Method for editing an existing item
    func showEditItemDialog(for section: Int, row: Int) {
        
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
        var alertTextField = UITextField()
        
        // Fetch the Item from ViewModel
        guard let item = viewModel.itemAt(indexPath: IndexPath(row: row, section: section)) else { return }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            guard let newItemTitle = alertTextField.text, !newItemTitle.isEmpty else { return }
            
            // Update the item title via ViewModel
            self.viewModel.updateItemTitle(at: IndexPath(row: row, section: section), with: newItemTitle)
   
            // Reload the row where item was edited
            let indexPath = IndexPath(row: row, section: section)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { textfield in
            textfield.text = item.title
            textfield.placeholder = "Enter a new value"
            alertTextField = textfield
            
            // Observe the textfield
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textfield, queue: .main) { _ in
                let isTextEmpty = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
                editAction.isEnabled = !isTextEmpty
            }
        }
        
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Method for setting up table view related data and configurations
    private func setupTableView() {
        // Setup the data source and delegate for the table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Setup table header view
        let headerView = ItemsHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableHeaderHeight))
        tableView.tableHeaderView = headerView
        
        // Configure the header view
        configureHeaderView()
        updateHeaderView(animated: false)
        
        // Register nibs
        tableView.register(UINib(nibName: K.itemNibName, bundle: .main), forCellReuseIdentifier: K.itemCellIdentifier)
        tableView.register(UINib(nibName: K.addItemNibName, bundle: .main), forCellReuseIdentifier: K.addItemCellIdentifier)
    }
    
    // Method for setting up the UI
    private func setupUI() {
        // Setup the basic colors
        view.backgroundColor = UIColor(named: K.MainColors.background)
        navigationController?.navigationBar.tintColor = UIColor(named: K.MainColors.white)
        tableView.backgroundColor = UIColor(named: K.MainColors.background)
        
        // Store the right bar button item
        addCategoryBarButton = navigationItem.rightBarButtonItem
    }
}
