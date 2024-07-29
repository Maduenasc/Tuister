//
//  TuistableViewController.swift
//  Proyecto
//
//  Created by Roberto Puentes Marchal on 14/05/2020.
//  Copyright © 2020 Roberto Puentes Marchal. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class tuistTableViewController: UITableViewController {
    
    var db:Firestore!
    
    var tuistArray = [tuist]()
    
    var Id: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        let userId = Auth.auth().currentUser?.uid
        print("UID USUARIO: ", userId!)
        var Idabuscar: String?
        self.db.collection("usuarios").getDocuments() {
            querySnapshot, error in
            
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                for usuario in querySnapshot!.documents {
                    let uid = usuario.data()["uid"] as? String
                    if uid! == userId!{
                        print("Encontrado: ", uid!)
                        Idabuscar = usuario.data()["Id"] as? String
                        self.Id = Idabuscar!
                        print("EncontradoID: ", self.Id)
                    }
                }
            }
        }
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
    
    @IBAction func componerTuist(_ sender: Any) {
        
        let composeAlert = UIAlertController(title: "Nuevo Tuist", message: "Introduce el mensaje", preferredStyle: .alert)
        
        composeAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "mensaje"
        }
        
        composeAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        composeAlert.addAction(UIAlertAction(title: "Publicar", style: .default, handler: { (action:UIAlertAction) in
            
            // INTERESTING PART
            

            if  let mensaje = composeAlert.textFields?.first?.text{
                let nuevoTuist = tuist(id: self.Id,mensaje: mensaje, hora: Timestamp())
                
                var ref:DocumentReference? = nil
                ref = self.db.collection("tuists").addDocument(data: nuevoTuist.diccionario) {
                    error in
                    
                    if let error = error {
                        print("Error añadiendo el tuist: \(error.localizedDescription)")
                    }else{
                        print("Tuist añadido con ID: \(ref!.documentID)")
                    }
                }
            }
            
        }))
        
        self.present(composeAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func composeSweet(_ sender: Any) {
        
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tuistArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let tuist = tuistArray[indexPath.row]
        
        cell.textLabel?.text = "\(tuist.id): \(tuist.mensaje)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        
        cell.detailTextLabel?.text = "\(formatter.string(from: tuist.hora.dateValue()))"

        return cell
    }
    

    

}
