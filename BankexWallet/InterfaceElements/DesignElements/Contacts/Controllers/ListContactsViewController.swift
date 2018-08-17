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
    @IBOutlet weak var searchFooter:SearchFooter!
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView:UITableView!
    

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = searchFooter
        setupNavbar()
        setupSearchVC()
    }
    
    func addBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.setTitle("  Home", for: .normal)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        //button.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listContacts = service.getAllStoredAddresses()
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
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(transitionToAddContact)), animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: nil)
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


