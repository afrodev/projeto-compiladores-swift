//
//  Env.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Env {
    private var table: [Token : Id]
    internal var prev: Env
    //    {
    //        variaveis "internal" podem ser acessadas apenas
    //        dentro da propria classe ou por herança, semelhante
    //        ao "protected" do Java
    //    }
    
    init(n: Env) {
        self.table = [:]
        self.prev = n
    }
    
    func put(w: Token, i: Id) {
        self.table.updateValue(i, forKey: w)
    }
    
    func get(w: Token) -> Id? {
        var e: Env? = self
        
        while e != nil {
            let found: Id?
            
            if let id = e?.table[w] {
                found = id
                return found
            }
            e = e!.prev
        }
        
        return nil
    }
}
