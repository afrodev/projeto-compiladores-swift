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
    
    public static let int   = Type(s: "int", tag: Tag.BASIC, w: 4),
    float = Type(s: "float", tag: Tag.BASIC, w: 8),
    char  = Type(s: "char", tag: Tag.BASIC, w: 1),
    bool  = Type(s: "bool", tag: Tag.BASIC, w: 1)
    
    static func numeric(p: Type?) -> Bool {
        if p?.lexeme == Type.char.lexeme || p?.lexeme == Type.int.lexeme || p?.lexeme == Type.float.lexeme {
            return true
        }
        
        return false
    }
    
    static func max(p1: Type?, p2: Type?) -> Type? {
        if !numeric(p: p1) || !numeric(p: p2) {
            return nil
        }
            
        else if p1?.lexeme == Type.float.lexeme || p2?.lexeme == Type.float.lexeme {
            return Type.float
        }
            
        else if p1?.lexeme == Type.int.lexeme || p2?.lexeme == Type.int.lexeme {
            return Type.int
        }
        
        return Type.char
    }
}
