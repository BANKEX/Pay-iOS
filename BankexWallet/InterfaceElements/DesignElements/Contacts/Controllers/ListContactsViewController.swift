//
//  ListContactsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 26.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ListContactsViewController: BaseViewController,UISearchResultsUpdating {
    
    enum State {
        case empty,fill,loading
    }
    
    
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
    var state:State = .loading {
        didSet {
            setFooterView()
            tableView.reloadData()
        }
    }
    @IBOutlet weak var searchFooter:SearchFooter!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var emptyView:UIView!
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView:UITableView!
    

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = searchFooter
        setupNavbar()
        setupSearchVC()
    }
    
    func setFooterView() {
        switch state {
        case .loading:
            break
        case .empty:
            emptyView.isHidden = false
        case .fill:
            emptyView.isHidden = true
        }
    }
    
    
    func chooseContact(contact:FavoriteModel) {
        var selectedRow = 0
        var selectedSection = 0
        loadViewIfNeeded()
        viewDidLoad()
        viewWillAppear(false)
        let firstLetter = String(contact.lastname.prefix(1).uppercased())
        for (section,letter) in sectionsTitles.enumerated() {
            if letter == firstLetter {
                selectedSection = section
                break
            }
        }
        guard let currentContacts = dictContacts[firstLetter] else { return }
        for (row,con) in currentContacts.enumerated() {
            if contact.address == con.address {
                selectedRow = row
                break
            }
        }
        tableView.selectRow(at: IndexPath(row: selectedRow, section: selectedSection), animated: false, scrollPosition: .none)
        tableView(tableView, didSelectRowAt: IndexPath(row: selectedRow, section: selectedSection))
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listContacts = self.service.getAllStoredAddresses()
        state = isNoContacts() ? .empty : .fill
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //MARK: - Methods
    
    func isNoContacts() -> Bool {
        guard let contacts = self.listContacts else { return true }
        return contacts.isEmpty
    }
    
    func updateArray() {
        sectionsTitles.removeAll()
        dictContacts.removeAll()
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
       searchBar.tintColor = WalletColors.mainColor
        searchBar.barTintColor = WalletColors.bgMainColor
        searchBar.backgroundImage = UIImage()
        searchBar.changeSearchBarColor(color: WalletColors.disableColor)
        searchBar.changeSearchBarTextColor(color: WalletColors.separatorColor)
        searchBar.placeholder = "Search Contact"
    }
    
    func setupNavbar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = NSLocalizedString("Contacts", comment: "")
        let addBtn:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(transitionToAddContact))
        addBtn.accessibilityLabel = "btnAddContact"
        navigationItem.setRightBarButton(addBtn, animated: false)
    }
    
    
    
    
    @objc func transitionToAddContact() {
        performSegue(withIdentifier: "addContactSegue", sender: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileContact" {
            guard let destVC = segue.destination as? ProfileContactViewController else { return }
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            if isFiltering() {
                destVC.selectedContact = filteredContacts[selectedIndexPath.row]
            }else {
                let currentTitleSection = sectionsTitles[selectedIndexPath.section]
                guard let currentContacts = dictContacts[currentTitleSection] else { return }
                destVC.selectedContact = currentContacts[selectedIndexPath.row]
            }
            let button = UIBarButtonItem()
            button.title = "Contacts"
            navigationItem.backBarButtonItem = button
        }
    }
    

}

extension ListContactsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ProfileContact", sender: nil)
    }
}

extension ListContactsViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        }else {
            return sectionsTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.establishFiltering(filteringCount: filteredContacts.count, total: listContacts?.count ?? 0)
            return filteredContacts.count
        }
        searchFooter.establishNotFiltering()
        let nameofSection = sectionsTitles[section]
        return (dictContacts[nameofSection]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:ContactCell.identifier, for: indexPath) as? ContactCell {
            if isFiltering() {
                cell.contact = filteredContacts[indexPath.row]
            }else {
                guard let currentContacts = dictContacts[sectionsTitles[indexPath.section]] else { return UITableViewCell() }
                cell.contact = currentContacts[indexPath.row]
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            return ""
        }else {
            return sectionsTitles[section]
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering() {
            return nil
        }else {
            return sectionsTitles
        }
    }
    
    
}


