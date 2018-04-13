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
        
        print(Lexer().readch())
        
        //print(readLine())
        // Main sendo executado
        // Analisador léxico
        //let lexer = Lexer()
        
        // Analisador sintático
//        let parse = Parser(lexer: lexer)
//        parse.program()
//        print("\n")
    }
}

// MARK: É utilizada nos analisadores, sendo INDEX, MINUS e TEMP usadas nas árvores sintáticas
class Tag {
    static let
    AND   = 256, BASIC = 257, BREAK = 258, DO   = 259, ELSE  = 260,
    EQ    = 261, FALSE = 262, GE    = 263, ID   = 264, IF    = 265,
    INDEX = 266, LE    = 267, MINUS = 268, NE   = 269, NUM   = 270,
    OR    = 271, REAL  = 272, TEMP  = 273, TRUE = 274, WHILE = 275
}

class Token {
    final let tag: Int
    
    init(t: Int) {
        self.tag = t
    }
    
    func toString() -> String {
        guard let code = UnicodeScalar(tag) else {
            print("Error trying to cast Int to Char")
            return ""
        }
        
        return "\(Character(code))"
    }
}

class Num: Token {
    final var value: Int
    
    init(v: Int) {
        self.value = v
        super.init(t: Tag.NUM)
    }
    
    override func toString() -> String {
        guard let code = UnicodeScalar(value) else {
            print("Error trying to cast Int to Char")
            return ""
        }
        
        return "\(Character(code))"
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

enum ReadChError: Error {
    case failToRead
}

// MARK: Lexer - A função scan, reconhece números, identificadores e palavras reservadas
class Lexer {
    static var line: Int = 1
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
        reserve(word: Type.int)
        reserve(word: Type.char)
        reserve(word: Type.bool)
        reserve(word: Type.float)
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

    func scan() -> Token? {
        while readch() {
            if peek == " " || peek == "\t" { continue }
            else if peek == "\n" { Lexer.line += 1 }
            else { break }
        }

        switch peek {
        case "&":
            if readch(c: "&") { return Word.and }
            else { return Token(t: Int(Character("&").asciiValue!) ) }
        case "|":
            if readch(c: "|") { return Word.or }
            else { return Token(t: Int(Character("|").asciiValue!) ) }
        case "=":
            if readch(c: "=") { return Word.eq }
            else { return Token(t: Int(Character("=").asciiValue!) ) }
        case "!":
            if readch(c: "=") { return Word.ne }
            else { return Token(t: Int(Character("!").asciiValue!) ) }
        case "<":
            if readch(c: "=") { return Word.le }
            else { return Token(t: Int(Character("<").asciiValue!) ) }
        case ">":
            if readch(c: "=") { return Word.ge }
            else { return Token(t: Int(Character(">").asciiValue!) ) }
        default:
            break
        }

        if peek.isDigit() {
            var v = 0

            repeat {
                guard let pValue = Int(String(peek)) else { return nil }
                v = 10 * v + pValue
                _ = readch()

            } while (peek.isDigit())

            if (peek != ".") { return Num(v: v) } // o peek devia ser '..'
            var x: Float = Float(v)
            var d: Float = 10

            while true {
                _ = readch()
                if !peek.isDigit() { break }
                x = x + Float(peek.toInt() ?? 0) / d
                d = d * 10
            }

            return Real(v: x)
        }

        if peek.isLetter() {
            var b: String = ""
            
            repeat {
                b.append(peek)
                _ = readch()
            } while (peek.isDigit() || peek.isLetter())

            let s: String = b
            
            if let sw = words[s] {
                let w: Word = Word.init(s: sw, tag: 0)
                return w
            }

            let w = Word(s: s, tag: Tag.ID)
            words.updateValue(s, forKey: w.toString())
            return w
        }

        let tok = Token(t: peek.toInt() ?? 0)
        peek = " "
        return tok
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

class Env {
    private var table: [Int : String]
    internal var prev: Env
//    {
//        variaveis "Internal" podem ser acessadas apenas
//        dentro da propria classe ou por herança, semelhante
//        ao "Protected" do Java
//    }
    
    init(n: Env) {
        self.table = [:]
        self.prev = n
    }
    
    func put(w: Token, i: Int) {
        self.table.updateValue(w.toString(), forKey: i)
    }
    
    func get(w: Token) -> Int? {
        var e: Env? = self
        
        while e != nil {
            let found: Int?
            
            if e!.table[w.tag] != nil {
                found = w.tag
                return found!
            }
            e = e!.prev
        }

        return nil
    }
}

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
    
    static func numeric(p: Type) -> Bool {
        if p.lexeme == Type.char.lexeme || p.lexeme == Type.int.lexeme || p.lexeme == Type.float.lexeme {
            return true
        }
        
        return false
    }
    
    static func max(p1: Type, p2: Type) -> Type? {
        if !numeric(p: p1) || !numeric(p: p2) {
            return nil
        }
        
        else if p1.lexeme == Type.float.lexeme || p2.lexeme == Type.float.lexeme {
            return Type.float
        }
        
        else if p1.lexeme == Type.int.lexeme || p2.lexeme == Type.int.lexeme {
            return Type.int
        }
        
        return Type.char
    }
}

// Arquivo: array.swift (deveria ser Array.swift)
class array: Type {
    var of: Type        // arranjo *of* type
    var size: Int = 1   // numero de elementos
    
    init(sz: Int, p: Type) {
        self.of = p
        super.init(s: "[]", tag: Tag.INDEX, w: sz * p.width)
        self.size = sz
    }
    
    override func toString() -> String {
        return "[\(size)]\(of.toString())"
    }
}

extension String: Error {}

class Node {
    var lexline: Int = 0
    
    init() {
        self.lexline = Lexer.line
    }
    
    func error(s: String) throws {
        throw "near line \(lexline): \(s)"
    }
    
    static var labels: Int = 0
    
    func newLabel() -> Int {
        return Node.labels + 1
    }
    
    func emitLabel(i: Int) {
        print("L", i, ":")
    }
    
    func emit(s: String) {
        print("\t", s)
    }
}

class Expr: Node {
    var op: Token
    var type: Type
    
    init(tok: Token, p: Type) {
        self.op = tok
        self.type = p
    }
    
    func gen() -> Expr {
        return self
    }
    
    func reduce() -> Expr {
        return self
    }
    
    func jumping(t: Int, f: Int) {
        emitJumps(test: toString(), t: t, f: f)
    }
    
    // Falta umas parada
    func emitJumps(test: String, t: Int, f: Int) {
        if t != 0 && f != 0 {
            emit(s: "if \(test)")
        }
    }
    
    func toString() -> String {
        return self.op.toString()
    }
}
