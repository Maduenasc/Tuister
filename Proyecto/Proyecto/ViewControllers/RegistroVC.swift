//
//  RegistroVC.swift
//  Proyecto
//
//  Created by Roberto Puentes Marchal on 14/05/2020.
//  Copyright © 2020 Roberto Puentes Marchal. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class Registro: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var correoTextField: UITextField!
    
    @IBOutlet weak var IdTextField: UITextField!
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var contraseñaTextField: UITextField!
    
    @IBOutlet weak var ErrorTextField: UILabel!
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // Do any additional setup after loading the view.
    }
    
    func mostrarError(_ message:String) {
        
        let datosErroneos = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        datosErroneos.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
        self.present(datosErroneos, animated: true, completion: nil)    }
    
    
    //Comprueba los campos y valida que los datos son correctos. Este método devuelve nil o el mensaje de error.
    func validarDatos() -> String? {
        
        //comprobar que los campos están rellenados
        if correoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           IdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           nombreTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           contraseñaTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Por favor rellena los campos"
        }
        
        //comprobar que la contraseña es válida
        let stringContraseña = contraseñaTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !Utilidades.isPasswordValid(stringContraseña) {
            //la contraseña no es válida
            return "Asegúrese que su contraseña contiene 8 caracteres, contiene un caracter especial y un número y no contiene ñ ni tildes."
        }
        
        return nil
    }
    
    @IBAction func PulsarRegistro(_ sender: Any) {
        
        //validar campos
        let error = validarDatos()

        
        if error != nil{
            //los datos no son válidos
            mostrarError(error!)
        }else{
            //crear versiones limpias de los datos
            let nombre = nombreTextField.text!.trimmingCharacters(in: .newlines)
            let id = IdTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let correo = correoTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let contraseña = contraseñaTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //crear usuario
            Auth.auth().createUser(withEmail: correo, password: contraseña) { (resultado, err) in
                //comprobar error
                if err != nil {
//                    //hubo un error
                    self.mostrarError("Inserte un correo válido")
                }else{
                    //el usuario se ha creado, vamos a guardar el Id y el nombre completo
                    let db = Firestore.firestore()
                    
                    db.collection("usuarios").addDocument(data: ["Id":id, "NombreYApellidos":nombre,"uid": resultado!.user.uid ]) { (error) in
                        if error != nil {
                            self.mostrarError("error guardando datos de usuario en la base de datos")
                        }
                    }
                    //llevar a página inicio
                    self.transicionPantallaInicio()
                }
            }
            
            
        }
    }
    
    func transicionPantallaInicio() {
        
        let tablon = storyboard?.instantiateViewController(identifier: Constantes.Storyboard.TablonVC) as? tablonVC
        
        view.window?.rootViewController = tablon
        view.window?.makeKeyAndVisible()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
