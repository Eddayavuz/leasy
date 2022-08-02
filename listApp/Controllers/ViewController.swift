//
//  ViewController.swift
//  Shopping List
//
//  Created by Eda Yavuz on 1.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    var alertController = UIAlertController()
    
    var data = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }
    
    @IBAction func didBarButtonItemTap (_ sender:UIBarButtonItem){
        presentAddAlert()
        
    }
    
    @IBAction func didTrashButtonTap (_ sender:UIBarButtonItem){
        presentAlert(title: "Warning",
                     message: "Are you sure?",
                     cancelButtonTitle: "Cancel",
                     defaultButtonTitle: "Yes",
                     defaultButtonHandler: { _ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ListItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do{
                try managedObjectContext?.execute(deleteRequest)
            } catch let error as NSError {
                // TODO: handle the error
            }
            
            
            self.fetch()
        },isTextField: false)
    }
    
    func presentAddAlert (){
        presentAlert(title: "Add new item",
                     message: nil,
                     cancelButtonTitle:"Cancel",
                     defaultButtonTitle: "Add",
                     defaultButtonHandler:{ _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""{
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                do{
                    try managedObjectContext?.save()
                } catch let error as NSError {
                    // TODO: handle the error
                }
                
                self.fetch()
                self.tableView.reloadData()
            } else {
                self.presentWarningAlert()
            }
        }, isTextField: true)
        
    }
    
    func presentWarningAlert (){
        presentAlert(title: "Warning", message: "Cannot add null value", cancelButtonTitle: "OK", isTextField: false)
    }
    
    func presentAlert (title: String?,
                       message: String?,
                       preferredStyle: UIAlertController.Style = .alert,
                       cancelButtonTitle: String?,
                       defaultButtonTitle: String? = nil,
                       defaultButtonHandler: ((UIAlertAction) -> Void)? = nil,
                       isTextField: Bool) {
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        
        if (defaultButtonTitle != nil){
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel,
                                         handler: nil)
        if (isTextField == true){
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
        
    }
    
    func fetch (){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Delete") { _, _, _ in
            //self.data.remove(at: indexPath.row)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.data[indexPath.row])
            do{
                try managedObjectContext?.save()
            } catch let error as NSError {
                // TODO: handle the error
            }
            
            
            self.fetch()
        }
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit") { _, _, _ in
            
            self.presentAlert(title: "Edit item",
                              message: nil,
                              cancelButtonTitle:"Cancel",
                              defaultButtonTitle: "Add",
                              defaultButtonHandler:{ _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""{
                    //self.data[indexPath.row] = text!
                    
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if ((managedObjectContext?.hasChanges) != nil) {
                        do{
                            try managedObjectContext?.save()
                        } catch let error as NSError {
                            // TODO: handle the error
                        }
                        self.fetch()
                    }else {
                        self.presentWarningAlert()
                    }
                }
            }, isTextField: true)
            tableView.reloadData()
        }
        
        deleteAction.backgroundColor = .systemRed
        editAction.backgroundColor = .systemGreen
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
}
