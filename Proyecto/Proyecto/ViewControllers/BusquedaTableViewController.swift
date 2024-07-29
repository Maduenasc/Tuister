//
//  BusquedaTableViewController.swift
//  Proyecto
//
//  Created by Roberto Puentes Marchal on 15/05/2020.
//  Copyright © 2020 Roberto Puentes Marchal. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class busquedaTableViewController: UITableViewController, UISearchBarDelegate{
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var barraDeBusqueda: UISearchBar!
    
    var db:Firestore!
    
    var tuistArray = [tuist]()
    
    var currentTuistArray = [tuist]()
    
    var Id: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        barraDeBusqueda.delegate = self
        
        cargarDatos()
        comprobarActualizaciones()
        
        
    }
    
    func cargarDatos(){
        db.collection("tuists").order(by: "hora", descending: true).getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.tuistArray = querySnapshot!.documents.compactMap({tuist(diccionario: $0.data())})
                self.currentTuistArray = self.tuistArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    func comprobarActualizaciones() {
        db.collection("tuists").whereField("hora", isGreaterThan: Timestamp())
            .addSnapshotListener {
                querySnapshot, error in
                
                guard let snapshot = querySnapshot else {return}
                
                snapshot.documentChanges.forEach {
                    diff in
                    
                    if diff.type == .added {
                        self.tuistArray.insert(tuist(diccionario: diff.document.data())!, at: 0)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                
        }
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentTuistArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let tuist = currentTuistArray[indexPath.row]
        
        cell.textLabel?.text = "\(tuist.id): \(tuist.mensaje)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        
        cell.detailTextLabel?.text = "\(formatter.string(from: tuist.hora.dateValue()))"

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        guard !searchText.isEmpty else {
            currentTuistArray = tuistArray
            tableView.reloadData()
            return
        }
        
        currentTuistArray = tuistArray.filter({ tuist -> Bool in
            return tuist.mensaje.lowercased().contains(searchText.lowercased()) || tuist.id.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }

    

}
