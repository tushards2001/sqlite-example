//
//  ViewController.swift
//  sqlite-example
//
//  Created by MacBookPro on 12/15/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    var database: Connection!
    
    let userTable = Table("users")
    let id = Expression<Int>("id")
    let name = Expression<String?>("name")
    let email = Expression<String?>("email")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentsDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print("Error > \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createTable(_ sender: UIButton) {
        print("CREATE TABLE")
        
        let createTable = self.userTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.email, unique: true)
        }
        
        do {
            try self.database.run(createTable)
            print("Created Table")
        } catch {
            print("Error > \(error)")
        }
    }
    
    @IBAction func insertUser(_ sender: UIButton) {
        print("INSERT USER")
        
        let alertController = UIAlertController(title: "Insert User", message: nil, preferredStyle: .alert)
        alertController.addTextField { (tf) in
            tf.placeholder = "Name"
        }
        alertController.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        
        let alertAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let name = alertController.textFields?.first?.text,
            let email = alertController.textFields?.last?.text
                else { return }
            
            print(name)
            print(email)
            
            let insertUser = self.userTable.insert(self.name <- name, self.email <- email)
            
            do {
                try self.database.run(insertUser)
            } catch {
                print("Error > \(error)")
            }
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func listUsers(_ sender: UIButton) {
        print("LIST USERS")
        
        do {
            let users = try self.database.prepare(self.userTable)
            
            for user in users{
                print("UserID: \(user[self.id]) | Name: \(String(describing: user[self.name]!)) | Email: \(String(describing: user[self.email]!))")
            }
        } catch {
            print("Error > \(error)")
        }
    }
    
    
    @IBAction func updateUser(_ sender: UIButton) {
        print("UPDATE USER")
        
        let alertController = UIAlertController(title: "Upate User", message: nil, preferredStyle: .alert)
        alertController.addTextField { (tf) in
            tf.placeholder = "UserID"
        }
        alertController.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        
        let alertAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIdString = alertController.textFields?.first?.text,
                let userId = Int(userIdString),
                let email = alertController.textFields?.last?.text
                else { return }
            
            print(userId)
            print(email)
            
            let user = self.userTable.filter(self.id == userId)
            let updateUser = user.update(self.email <- email)
            
            do {
                try self.database.run(updateUser)
            } catch {
                print("Error > \(error)")
            }
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteUser(_ sender: UIButton) {
        print("DELETE USER")
        
        let alertController = UIAlertController(title: "Delete User", message: nil, preferredStyle: .alert)
        alertController.addTextField { (tf) in
            tf.placeholder = "UserID"
        }
        
        let alertAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIdString = alertController.textFields?.first?.text,
                let userId = Int(userIdString)
                else { return }
            
            print(userId)
            
            let user = self.userTable.filter(self.id == userId)
            let deleteUser = user.delete()
            
            do {
                try self.database.run(deleteUser)
            } catch {
                print("Error > \(error)")
            }
            
            
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}

