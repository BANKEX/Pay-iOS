//
//  ListContactsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 26.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ListContactsViewController: UIViewController,UISearchResultsUpdating {
    
    
    //MARK: - Properties
    let service = RecipientsAddressesServiceImplementation()
    var listContacts:[FavoriteModel]? {
        didSet {
            updateArray()
            self.tableView.reloadData()
        }
    }
    var filteredContacts = [FavoriteModel]()
    var dictContacts:[String:[FavoriteModel]] = [:]
    var sectionsTitles:[String] = []
    var searchViewController:UISearchController = UISearchController(searchResultsController: nil)
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView:UITableView!
    

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        setupNavbar()
        setupSearchVC()
        listContacts = service.getAllStoredAddresses()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    
    //MARK: - Methods
    
    
    
    func updateArray() {
        guard let contacts = listContacts else { return }
        for contact in contacts {
            let word = String(contact.lastname.prefix(1))
            let singleWord = word.capitalized
            if dictContacts[singleWord] == nil {
                dictContacts[singleWord] = [contact]
                sectionsTitles.append(singleWord)
            }else {
                dictContacts[singleWord]?.append(contact)
            }
        }
    }
    
    

    
    func searchBarIsEmpty() -> Bool {
        return searchViewController.searchBar.text?.isEmpty ?? true
    }
    
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty() && searchViewController.isActive
    }
    
    
    func filterContentForSearchText(_ searchText:String) {
        if let contacts = listContacts {
            filteredContacts = contacts.filter({ (contact:FavoriteModel) -> Bool in
                return contact.firstName.lowercased().contains(searchText.lowercased()) || contact.lastname.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
    }

    
    func setupSearchVC() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchViewController
            searchViewController.obscuresBackgroundDuringPresentation = false
            searchViewController.searchResultsUpdater = self
            definesPresentationContext = true
        }else {
            //TODO
        }
    }
    
    func setupNavbar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Contacts"
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(transitionToAddContact)), animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: nil)
    }
    
    
    
    
    @objc func transitionToAddContact() {
        performSegue(withIdentifier: "addContactSegue", sender: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

}


