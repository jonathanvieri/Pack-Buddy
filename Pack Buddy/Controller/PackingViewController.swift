//
//  PackingViewController.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 07/10/24.
//

import UIKit

class PackingViewController : UIViewController {
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // Constants
    final let tableHeaderHeight: CGFloat = 120
    final let cellHeight: CGFloat = 110
    
    final let mainBackgroundColor = UIColor(named: K.MainColors.background)
    final let mainWhiteColor = UIColor(named: K.MainColors.white)
    final let mainGrayLowerColor = UIColor(named: K.MainColors.grayLower)
    final let additionalRedColor = UIColor(named: K.AdditionalColors.red)
    
    // Variables
    var addPackingBarButton: UIBarButtonItem?
    var selectedPackingView: UIView?
    var cancelButton: UIBarButtonItem!
    var editButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    private var viewModel = PackingViewModel()
}
    
//MARK: - ViewController Lifecycle
extension PackingViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Bind the viewModel
        setupBindings()
        
        // Fetch packings through ViewModel
        viewModel.fetchPackings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the table view
        setupTableView()
        
        // Setup the UI
        setupUI()
        
        // Store Add Packing right bar button
        addPackingBarButton = navigationItem.rightBarButtonItem
        
        // Create the navigation bar buttons
        setupNavBarButtons()
        
        // Add the tap gesture recognizer to the view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}
//MARK: - UITableViewDataSource & UITableViewDelegate
extension PackingViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPackings()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.packingCellIdentifier, for: indexPath) as! PackingCell
        
        if let packing = viewModel.packingAt(index: indexPath.row) {
            cell.titleLabel.text = packing.title
            
            // Set the date and nights label
            cell.dateLabel.text = viewModel.formattedDate(for: packing)
            cell.nightsLabel.text = viewModel.formattedNights(for: packing)
            
            // Update the cell's progress and set the specific color
            cell.configureProgressBar(currentValue: viewModel.totalCompletedItems(for: packing), totalValue: viewModel.totalItems(for: packing))
            
            if let packingColor = packing.color as? UIColor {
                cell.configureProgressBarColor(color: packingColor)
                cell.configureFrontSquareColor(color: packingColor)
            }
            
            // Add long press gesture recognizer for editing and deleting packings
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressPacking(_:)))
            cell.addGestureRecognizer(longPressGesture)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedPacking = viewModel.packingAt(index: indexPath.row) {
            performSegue(withIdentifier: "goToItems", sender: selectedPacking)
            restoreAddPackingBarButton()
            restorePackingColor()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

//MARK: - UISearchBarDelegate
extension PackingViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchPacking(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.searchPacking(with: "")
    }
}

//MARK: - Gesture Recognizers
extension PackingViewController {
    @objc func longPressPacking(_ gesture: UILongPressGestureRecognizer) {
        guard let cell = gesture.view as? PackingCell,
        let indexPath = tableView.indexPath(for: cell) else { return }
        
        if (gesture.state == .began) {
            
            // Store the add packing at right bar button if not stored on viewDidLoad
            if addPackingBarButton == nil {
                addPackingBarButton = navigationItem.rightBarButtonItem
            }
            
            // Store the current selected packing view
            selectedPackingView = cell.packingView
            
            // Change the color to show it's being selected
            if let selectedPackingView = selectedPackingView {
                UIView.animate(withDuration: 0.3) {
                    selectedPackingView.backgroundColor = self.mainGrayLowerColor
                }
            }
            
            // Set the button tags
            editButton.tag = indexPath.row
            deleteButton.tag = indexPath.row
            
            // Set cancel button to left navigation bar
            navigationItem.leftBarButtonItem = cancelButton
            
            // Set both edit and delete button to right navigation bar
            navigationItem.rightBarButtonItems = [deleteButton, editButton]
        }
    }
}
    
//MARK: - Navigation
extension PackingViewController {
    
    @IBAction func addPackingButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAddPacking", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToAddPacking") {
            let addPackingVC = segue.destination as! AddPackingViewController
            if let packingIndex = sender as? Int {
                addPackingVC.packingToEdit = viewModel.packingAt(index: packingIndex)
            }
            
        } else if (segue.identifier == "goToItems") {
            let itemsVC = segue.destination as! ItemsViewController
            let selectedPacking = sender as? Packing
            itemsVC.parentPacking = selectedPacking
        }
    }
}
    
//MARK: - UI Helper and Other Methods
extension PackingViewController {

    // Method for restoring the add packing button on right navigation bar
    func restoreAddPackingBarButton() {
        if let addPackingBarButton = addPackingBarButton {
            navigationItem.rightBarButtonItems = [addPackingBarButton]
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    // Method for restoring the Packing color after being selected
    func restorePackingColor() {
        if let packingView = selectedPackingView {
            UIView.animate(withDuration: 0.3) {
                packingView.backgroundColor = UIColor(named: K.MainColors.black)
            }
        }
    }
    
    // Method for cancelling editing a Packing
    @objc func cancelEditPacking() {
        restoreAddPackingBarButton()
        restorePackingColor()
    }
    
    // Method for editing a Packing
    @objc func editPacking(_ sender: UIBarButtonItem) {
        let packing = sender.tag
        performSegue(withIdentifier: "goToAddPacking", sender: packing)
        restoreAddPackingBarButton()
        restorePackingColor()
    }
    
    // Method for deleting the chosen Packing
    @objc func deletePacking(_ sender: UIBarButtonItem) {
        let row = sender.tag
        showDeletePackingDialog(row: row)
    }

    // Method for showing dialog when attempting to delete a packing
    func showDeletePackingDialog(row: Int) {
        
        let alert = UIAlertController(title: "Delete Packing", message: "Are you sure you want to delete this Packing?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.viewModel.deletePacking(at: row)
            self.restoreAddPackingBarButton()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.restoreAddPackingBarButton()
            self.restorePackingColor()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    // This method is used to bind the ViewModel to the View
    func setupBindings() {
        viewModel.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.showError = { error in
            print("Error: \(error)")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Method for setting up the navigation bar buttons
    private func setupNavBarButtons() {
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditPacking))
        
        editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editPacking(_:)))
        editButton.tintColor = mainWhiteColor
        
        deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(deletePacking(_:)))
        deleteButton.tintColor = additionalRedColor
    }
    
    // Method for setting up the Table View
    private func setupTableView() {
        // Setup Table View Data Source and Delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Setup and configure Table View Header
        let headerView = PackingsHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableHeaderHeight))
        headerView.configure(delegate: self)
        tableView.tableHeaderView = headerView
        
        // Register nibs
        tableView.register(UINib(nibName: K.packingNibName, bundle: .main), forCellReuseIdentifier: K.packingCellIdentifier)
        
    }
    
    private func setupUI() {
        // Setup colors
        view.backgroundColor = mainBackgroundColor
        navigationController?.navigationBar.tintColor = mainWhiteColor
        tableView.backgroundColor = mainBackgroundColor
    }
}
