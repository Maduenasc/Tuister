//
//  PerfilUsuarioTableViewController.swift
//  Proyecto
//
//  Created by Roberto Puentes Marchal on 15/05/2020.
//  Copyright © 2020 Roberto Puentes Marchal. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class perfilUsuarioTableViewController: UITableViewController {
    
    @IBOutlet weak var IdLabel: UILabel!
    var db:Firestore!
    
    var tuistArray = [tuist]()
    
    var Id: String = ""
    
    func encontrarIdYCargarDatos(){
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

                        self.cargarDatos()
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        encontrarIdYCargarDatos()

        comprobarActualizaciones()
        
        
       
    }
    
    @IBAction func cerrarSesion(_ sender: Any) {
        do{
        try Auth.auth().signOut()
        }catch {}
            
        let login = storyboard?.instantiateViewController(identifier: Constantes.Storyboard.loginVC) as? Login
        view.window?.rootViewController = login
        view.window?.makeKeyAndVisible()
    }
    
    
    
    func cargarDatos(){
        self.IdLabel.text = self.Id
        db.collection("tuists").order(by: "hora", descending: true).getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.tuistArray = querySnapshot!.documents.compactMap({tuist(diccionario: $0.data())})
                self.tuistArray = self.tuistArray.filter({ tuist -> Bool in
                    
                    return tuist.id.contains(self.Id)
                })
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
                        self.tuistArray = self.tuistArray.filter({ tuist -> Bool in
                            return tuist.id.contains(self.Id)
                        })
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                
        }
    }

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
    
    @IBAction func botonCambiarCorreo(_ sender: Any) {
        let composeAlert = UIAlertController(title: "Cambiar correo", message: "Introduce el nuevo correo", preferredStyle: .alert)
        
        composeAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "nuevo correo electrónico"
        }
        
        composeAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        composeAlert.addAction(UIAlertAction(title: "Cambiar", style: .default, handler: { (action:UIAlertAction) in
            
            // INTERESTING PART
            

            if  let mensaje = composeAlert.textFields?.first?.text{
                Auth.auth().currentUser?.updateEmail(to: mensaje, completion: { error in
                    if error != nil{
                        let correoErroneo = UIAlertController(title: "Correo erroneo", message: "Error el correo es erroneo", preferredStyle: .alert)
                        
                        correoErroneo.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
                        self.present(correoErroneo, animated: true, completion: nil)
                    }else{
                        let correoValido = UIAlertController(title: "Correo cambiado", message: "se ha cambiado el correo correctamente", preferredStyle: .alert)
                        
                        correoValido.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
                        self.present(correoValido, animated: true, completion: nil)
                    }
                })
            }
            
        }))
        
        self.present(composeAlert, animated: true, completion: nil)
    }
    
    @IBAction func botonCambiarContraseña(_ sender: Any) {
        
        let composeAlert = UIAlertController(title: "Cambiar contraseña", message: "Introduce la nueva contraseña", preferredStyle: .alert)
        
        composeAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "nueva contraseña"
        }
        
        composeAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        composeAlert.addAction(UIAlertAction(title: "Cambiar", style: .default, handler: { (action:UIAlertAction) in
            
            // INTERESTING PART
            

            if  let mensaje = composeAlert.textFields?.first?.text{
                
                let stringPass = mensaje.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if Utilidades.isPasswordValid(stringPass){
                    Auth.auth().currentUser?.updatePassword(to: mensaje, completion: { error in
                        if error != nil{
                            let contraseñaErronea = UIAlertController(title: "Contraseña erronea", message: "Error la contraseña no es válida", preferredStyle: .alert)
                            
                            contraseñaErronea.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
                            self.present(contraseñaErronea, animated: true, completion: nil)
                        }else{
                            let contraseñaValida = UIAlertController(title: "Contraseña cambiada", message: "se ha cambiado la contraseña correctamente", preferredStyle: .alert)
                            
                            contraseñaValida.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
                            self.present(contraseñaValida, animated: true, completion: nil)
                        }
                    })
                }else {
                    let contraseñaErronea = UIAlertController(title: "Contraseña erronea", message: "Error la contraseña no es válida", preferredStyle: .alert)
                    
                    contraseñaErronea.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
                    self.present(contraseñaErronea, animated: true, completion: nil)
                }
                
                
            }
            
        }))
        
        self.present(composeAlert, animated: true, completion: nil)
    }
    
    
    

}
