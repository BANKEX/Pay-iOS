//
//  FavoritesHelperViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 28.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class FavoritesHelperViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var allFavorites: [FavoriteModel]?
    weak var delegate: CellSelectedProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    
    @IBAction func dismissView(_ sender: UIGestureRecognizer) {
        self.performSegue(withIdentifier: "unwindToSend", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let number = allFavorites?.count else { return 0 }
        return number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favCell") as? FavoritesHelperTableViewCell else { return UITableViewCell() }
        guard let model = allFavorites?[indexPath.row] else { return UITableViewCell() }
        cell.configure(fav: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = allFavorites?[indexPath.row] else { return }
        delegate?.didSelectCell(model: model)
        self.performSegue(withIdentifier: "unwindToSend", sender: nil)
    }
    

}

protocol CellSelectedProtocol: class {
    func didSelectCell(model: FavoriteModel)
}
