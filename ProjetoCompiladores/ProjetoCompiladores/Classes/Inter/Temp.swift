//
//  Temp.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Temp: Expr {
    static var count = 0
    var number = 0
    
    init(p: Type?) {
        super.init(tok: Word.temp, p: p)
        self.number = Temp.count + 1
    }
    
    override func toString() -> String {
        return "t \(number)"
    }
}
