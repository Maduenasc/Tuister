//
//  tuist.swift
//  Proyecto
//
//  Created by Roberto Puentes Marchal on 14/05/2020.
//  Copyright © 2020 Roberto Puentes Marchal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol DocumentSerializable {
    init?(diccionario:[String:Any])
}

struct tuist{
    var id:String
    var mensaje:String
    var hora:Timestamp
    
    var diccionario:[String:Any] {
        return [
            "id":id,
            "mensaje":mensaje,
            "hora":hora
        ]
    }
}

extension tuist : DocumentSerializable{
    init?(diccionario:[String:Any]){
        guard let id = diccionario["id"] as? String,
            let mensaje = diccionario["mensaje"] as? String,
            let hora = diccionario["hora"] as? Timestamp else {return nil}
        
        self.init(id: id, mensaje: mensaje, hora: hora)
    }
}
