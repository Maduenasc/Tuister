//
//  ViewController.swift
//  Proyecto
//
//  Created by Roberto Puentes Marchal on 13/05/2020.
//  Copyright © 2020 Roberto Puentes Marchal. All rights reserved.
//

import UIKit
import FirebaseAuth

class Login: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var correo: UITextField!
    @IBOutlet weak var contraseña: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func validarDatos() -> String? {
        
        //comprobar que los campos están rellenados
        if correo.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           contraseña.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Por favor rellena los campos"
        }
        
        return nil
    }
    
    func mostrarError(_ message:String) {
        let datosErroneos = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        datosErroneos.addAction(UIAlertAction(title: "Entendido", style: .cancel, handler: nil))
        self.present(datosErroneos, animated: true, completion: nil)
    }
    
    func transicionPantallaInicio() {
        
        let tablon = storyboard?.instantiateViewController(identifier: Constantes.Storyboard.TablonVC) as? tablonVC
        view.window?.rootViewController = tablon
        view.window?.makeKeyAndVisible()
        
    }
    
    @IBAction func botonLogin(_ sender: Any) {
        //validar TextFields
        let error = validarDatos()
        
        if error != nil{
            //los datos no son válidos
            self.mostrarError(error!)
        }else{
            //campos limpios
            let stringCorreo = correo.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let stringContraseña = contraseña.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            //acceder al usuario
            Auth.auth().signIn(withEmail: stringCorreo, password: stringContraseña) { (result, error) in
                
                if error != nil {
                    //no se pudo logear
                    self.mostrarError("Error: usuario o contraseña inválidos")
                }else{
                    //pasamos a tablon
                    self.transicionPantallaInicio()
                }
            }
        }
        
    }
    @IBAction func botonRegistro(_ sender: Any) {
    }
    
}

