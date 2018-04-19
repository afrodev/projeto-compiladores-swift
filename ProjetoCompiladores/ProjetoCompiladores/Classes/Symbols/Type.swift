//
//  Type.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

class Type: Word {
    var width: Int = 0  // width e usado para alocacao de memoria
    
    init(s: String, tag: Int, w: Int) {
        super.init(s: s, tag: tag)
        self.width = w
    }
    
    public static let Int   = Type(s: "int", tag: Tag.BASIC, w: 4),
                      Float = Type(s: "float", tag: Tag.BASIC, w: 8),
                      Char  = Type(s: "char", tag: Tag.BASIC, w: 1),
                      Bool  = Type(s: "bool", tag: Tag.BASIC, w: 1)
    
    static func numeric(p: Type?) -> Bool {
        if p?.lexeme == Type.Char.lexeme || p?.lexeme == Type.Int.lexeme || p?.lexeme == Type.Float.lexeme {
            return true
        }
        
        return false
    }
    
    static func max(p1: Type?, p2: Type?) -> Type? {
        if !numeric(p: p1) || !numeric(p: p2) {
            return nil
        }
            
        else if p1?.lexeme == Type.Float.lexeme || p2?.lexeme == Type.Float.lexeme {
            return Type.Float
        }
            
        else if p1?.lexeme == Type.Int.lexeme || p2?.lexeme == Type.Int.lexeme {
            return Type.Int
        }
        
        return Type.Char
    }
}
