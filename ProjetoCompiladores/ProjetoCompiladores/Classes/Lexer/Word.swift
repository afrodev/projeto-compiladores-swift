//
//  Word.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

// MARK: Word - Gerencia os lexemas para palavras reservadas, identificadores e token como o &&
class Word: Token {
    var lexeme: String = ""
    
    init(s: String, tag: Int) {
        super.init(t: tag)
        self.lexeme = s
    }
    
    override func toString() -> String {
        return lexeme
    }
    
    static let and   = Word(s: "&&", tag: Tag.AND)
    static let or    = Word(s: "||", tag: Tag.OR)
    static let eq    = Word(s: "==", tag: Tag.EQ)
    static let ne    = Word(s: "!=", tag: Tag.NE)
    static let le    = Word(s: "<=", tag: Tag.LE)
    static let ge    = Word(s: ">=", tag: Tag.GE)
    static let minus = Word(s: "minus", tag: Tag.MINUS)
    static let True  = Word(s: "true", tag: Tag.TRUE)
    static let False = Word(s: "false", tag: Tag.FALSE)
    static let temp  = Word(s: "t", tag: Tag.TEMP)
}
