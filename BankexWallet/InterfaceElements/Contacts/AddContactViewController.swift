//
//  AddContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 26.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AddContactViewController: UITableViewController {
    
    @IBOutlet weak var firstNameTextField:UITextField?
    @IBOutlet weak var lastNameTextField:UITextField?
    @IBOutlet weak var addressTextField:UITextField?
    
    
    
    enum State {
        case noAvailable,available
    }
    
    
    var state:State = State.noAvailable {
        didSet {
            if state == .noAvailable {
                doneButton.isEnabled = false
            }else {
                doneButton.isEnabled = true
            }
        }
    }
    
    var headerView:UIView!
    
    var doneButton:UIBarButtonItem {
        return UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        state = .noAvailable
        setupNavBar()
        setupHeader()
        setupFooter()
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Title"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func setupFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
        let pasteButton = UIButton(frame: CGRect(x: 16, y: 15, width: 140.0, height: 28.0))
        pasteButton.setImage(#imageLiteral(resourceName: "Paste button"), for: .normal)
        pasteButton.addTarget(self, action: #selector(importFromBuffer(_:)), for: .touchUpInside)
        footerView.addSubview(pasteButton)
        footerView.backgroundColor = .white
        tableView.tableFooterView = footerView
    }
    
    func setupHeader() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 160.0))
        tableView.tableHeaderView = headerView
        createCircle()
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func done() {
        //TODO
    }
    
    fileprivate func createCircle() {
        guard let header = headerView else { return }
        let circlePath = UIBezierPath(arcCenter: CGPoint(x:header.bounds.midX, y: header.bounds.midY), radius: 43.0, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapelayer = CAShapeLayer()
        shapelayer.path = circlePath.cgPath
        shapelayer.fillColor = UIColor.white.cgColor
        shapelayer.lineWidth = 0.8
        shapelayer.strokeColor = UIColor.lightGray.cgColor
        let heightPhotoLabe:CGFloat = 15.0
        let textLayer = CATextLayer()
        textLayer.string = "add photo"
        textLayer.fontSize = 12.0
        textLayer.isWrapped = true
        textLayer.foregroundColor = WalletColors.blueText.color().cgColor
        textLayer.frame.origin = CGPoint(x: (shapelayer.path?.boundingBox.minX)!, y: (shapelayer.path?.boundingBox.midY)! - heightPhotoLabe/2)
        textLayer.frame.size = CGSize(width: (shapelayer.path?.boundingBox.width)! - 2, height: heightPhotoLabe)
        textLayer.alignmentMode = "center"
        headerView.layer.addSublayer(shapelayer)
        headerView.layer.addSublayer(textLayer)
    }
    
    
    @objc func importFromBuffer(_ sender:Any) {
        //TODO
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
