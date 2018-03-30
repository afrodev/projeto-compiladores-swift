//
//  MainVC.swift
//  ProjetoCompiladores
//
//  Created by Humberto Vieira on 30/03/18.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Cocoa

class MainVC: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Main sendo executado
        // Analisador léxico
        let lexer = Lexer()
        
        // Analisador sintático
        let parser = Parser(lexer: lexer)
        parser.program()
        print("")
    }
}

// MARK: É utilizada nos analisadores, sendo INDEX, MINUS e TEMP usadas nas árvores sintáticas
class Tag {
    static let AND = 256, BASIC = 257, BREAK = 258, DO = 259, ELSE = 260,
    EQ = 261, FALSE = 262, GE = 263, ID = 264, IF = 265, INDEX = 266,
    LE = 267, MINUS = 268, NE = 269, NUM = 270, OR = 271, REAL = 272,
    TEMP = 273, TRUE = 274, WHILE = 275
}


class Token {
    final let tag: Int
    
    init(t: Int) {
        self.tag = t
    }
    
    func toString() -> String {
        return "\(tag)"
    }
}

class Num: Token {
    final var value: Int
    
    init(v: Int) {
        self.value = v
        super.init(t: Tag.NUM)
    }
    
    override func toString() -> String {
        return "\(value)"
    }
}

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
    
    static let and = Word(s: "&&", tag: Tag.AND)
    static let or = Word(s: "||", tag: Tag.OR)
    static let eq = Word(s: "==", tag: Tag.EQ)
    static let ne = Word(s: "!=", tag: Tag.NE)
    static let le = Word(s: "<=", tag: Tag.LE)
    static let ge = Word(s: ">=", tag: Tag.GE)
    static let minus = Word(s: "minus", tag: Tag.MINUS)
    static let True = Word(s: "true", tag: Tag.TRUE)
    static let False = Word(s: "false", tag: Tag.FALSE)
    static let temp = Word(s: "t", tag: Tag.TEMP)

}

// MARK: Real - Para o ponto flutuante
class Real: Token {
    final let value: Float
    
    init(v: Float) {
        self.value = v
        super.init(t: Tag.REAL)
    }
    
    override func toString() -> String {
        return "\(value)"
    }
}

// MARK: Lexer - A função scan, reconhece números, identificadores e palavras reservadas
class Lexer {
    static let line: Int = 1
    var peek: Character = " "
    var words: [String: String] = [:]
    
    init() {
        reserve(word: Word(s: "if", tag: Tag.IF))
        reserve(word: Word(s: "else", tag: Tag.ELSE))
        reserve(word: Word(s: "while", tag: Tag.WHILE))
        reserve(word: Word(s: "do", tag: Tag.DO))
        reserve(word: Word(s: "break", tag: Tag.BREAK))
        reserve(word: Word.True)
        reserve(word: Word.False)
//        reserve(word: Type.Int)
//        reserve(word: Type.Char)
//        reserve(word: Type.Bool)
//        reserve(word: Type.Float)
    }
    
    func reserve(word: Word) {
        words.updateValue(word.lexeme, forKey: word.toString())
    }
    
    func readch() -> Bool {
        guard let read = readLine() else { return false }
        let charRead = Character(read)
        peek = charRead
        return true
    }
    
    func readch(c: Character) -> Bool {
        guard readch() else { return false }
        if peek != c {
           return false
        }
        peek = " "
        return true
    }
    
}

class Parser {
    private let lexer: Lexer
    
    init(lexer: Lexer) {
        self.lexer = lexer
    }
    
    func program() {
        
    }
}



