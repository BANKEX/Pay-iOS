//
//  ListContactsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 26.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ListContactsViewController: UIViewController,UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //TODO
    }
    
    
    
    let service = RecipientsAddressesServiceImplementation()
    var listContacts:[FavoriteModel]? {
        didSet {
            updateArray()
            self.tableView.reloadData()
        }
    }
    var dictContacts:[String:[FavoriteModel]] = [:]
    var sectionsTitles:[String] = []
    
    
    @IBOutlet weak var tableView:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        setupNavbar()
        setupSearchVC()
        listContacts = service.getAllStoredAddresses()
    }
    
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
    
    func setupSearchVC() {
        let searchViewController = UISearchController(searchResultsController: nil)
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchViewController
            searchViewController.obscuresBackgroundDuringPresentation = false
            searchViewController.dimsBackgroundDuringPresentation = false
            searchViewController.searchResultsUpdater = self
            definesPresentationContext = true
        }
    }
    
    func setupNavbar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Contacts"
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(transitionToAddContact)), animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: nil)
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
    
    
    @objc func transitionToAddContact() {
        performSegue(withIdentifier: "addContactSegue", sender: self)
    }
    


}

extension ListContactsViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nameofSection = sectionsTitles[section]
        return (dictContacts[nameofSection]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:ContactCell.identifier, for: indexPath) as? ContactCell {
            guard let currentContacts = dictContacts[sectionsTitles[indexPath.section]] else { return UITableViewCell() }
            cell.contact = currentContacts[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionsTitles
    }
}
