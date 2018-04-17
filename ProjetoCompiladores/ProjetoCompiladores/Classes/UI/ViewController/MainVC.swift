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
        
//        Main sendo executado
//        Analisador léxico
//        let lexer = Lexer()
        
//        Analisador sintático
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

class Token: Hashable {
    var hashValue: Int
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        <#code#>
    }
    
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
    private var look: Token!
    var top: Env?
    var used: Int = 0
    
    init(lexer: Lexer) {
        self.lexer = lexer
        self.move()
    }
    
    func move() {
        self.look = self.lexer.scan()
    }
    
    func error(_ s: String) throws {
        throw "near line \(Lexer.line): \(s)"
    }
    
    func match(t: Int) {
        if self.look!.tag == t {
            self.move()
        } else {
            try! error("syntax error")
        }
    }
    
    func program() {
        let s:Stmt = self.block()
        let begin: Int = s.newLabel()
        let after: Int = s.newLabel()
        s.emitLabel(i: begin)
        s.gen(b: begin, a: after)
        s.emitLabel(i: after)
    }
    
    func block() -> Stmt {
        match(t: Int(Character("{").asciiValue!))
        let savedEnv = self.top
        self.top = Env(n: top!)
        self.decls()
        let s = self.stmts()
        match(t: Int(Character("}").asciiValue!))
        self.top = savedEnv
        return s
    }
    
    func decls() {
        while self.look!.tag == Tag.BASIC {
            let p = self.type()
            let tok = self.look
            match(t: Tag.ID)
            match(t: Int(Character(";").asciiValue!))
            let id = Id(id: tok as! Word, p: p, b: used)
            top?.put(w: tok!, i: id.offset)
            used = used + p.width
        }
    }
    
    func type() -> Type {
        let p = self.look as! Type
        match(t: Tag.BASIC)
        if self.look!.tag != Int(Character("[").asciiValue!) {
            return p
        } else {
            return self.dims(p)
        }
    }
    
    func dims(_ p: Type) -> Type {
        var param = p
        match(t: Int(Character("[").asciiValue!))
        let tok = self.look!
        match(t: Tag.NUM)
        match(t: Int(Character("]").asciiValue!))
        if self.look!.tag == Int(Character("[").asciiValue!) {
            param = dims(param)
        }
        return Array(sz: tok.tag.hashValue, p: param)
    }
    
    func stmts() -> Stmt {
        if self.look.tag == Int(Character("}").asciiValue!) {
            return Stmt.Null
        } else {
            return Seq(s1: self.stmt(), s2: self.stmts())
        }
    }
    
    func stmt() -> Stmt {
        var x: Expr
//        var s: Stmt
        var s1: Stmt
        var s2: Stmt
        var savedStmt: Stmt
        
        switch self.look.tag {
        case Int(Character(";").asciiValue!):
            self.move()
            return Stmt.Null
            
        case Tag.IF:
            match(t: Tag.IF)
            match(t: Int(Character("(").asciiValue!))
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            s1 = self.stmt()
            if self.look.tag != Tag.ELSE {
                return If(x: x, s: s1)
            }
            match(t: Tag.ELSE)
            s2 = self.stmt()
            return Else(x: x, s1: s1, s2: s2)
            
        case Tag.WHILE:
            var whilenode = While()
            savedStmt = Stmt.Enclosing
            Stmt.Enclosing = whilenode
            match(t: Tag.WHILE)
            match(t: Int(Character("(").asciiValue!))
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            s1 = self.stmt()
            whilenode = While(x: x, s: s1)
            Stmt.Enclosing = savedStmt
            return whilenode
            
        case Tag.DO:
            var donode = Do()
            savedStmt = Stmt.Enclosing
            Stmt.Enclosing = donode
            match(t: Tag.DO)
            s1 = self.stmt()
            match(t: Tag.WHILE)
            match(t: Int(Character("(").asciiValue!))
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            match(t: Int(Character(";").asciiValue!))
            donode = Do(s: s1, x: x)
            Stmt.Enclosing = savedStmt
            return donode
            
        case Tag.BREAK:
            match(t: Tag.BREAK)
            match(t: Int(Character(";").asciiValue!))
            return Break()
            
        case Int(Character("{").asciiValue!):
            return self.block()
            
        default:
            return self.assign()
        }
    }
    
    func assign() -> Stmt {
        var stmt = Stmt()
        let t = self.look!
        match(t: Tag.ID)
        let id = top?.get(w: t)
        if id == nil {
            try! self.error("\(t.toString()) undeclared")
        }
        if self.look.tag == Int(Character("=").asciiValue!) {
            self.move()
            stmt = Set(i: id!, x: self.bool())
        } else {
            let x: Access = self.offset(id!)
            match(t: Int(Character("=").asciiValue!))
            stmt = SetElem(x: x, y: self.bool())
        }
        match(t: Int(Character(";").asciiValue!))
        return stmt
    }
    
    func bool() -> Expr {
        var x = self.join()
        while self.look.tag == Tag.OR {
            let tok = self.look!
            self.move()
            x = Or(tok: tok, x1: x, x2: self.join())
        }
        return x
    }
    
    func join() -> Expr {
        var x = self.equality()
        while self.look.tag == Tag.AND {
            let tok = self.look!
            self.move()
            x = Rel(tok: tok, x1: x, x2: self.equality())
        }
        return x
    }
    
    func equality() -> Expr {
        var x  = self.rel()
        while self.look.tag == Tag.EQ || self.look.tag == Tag.NE {
            let tok = self.look!
            self.move()
            x = Rel(tok: tok, x1: x, x2: self.rel())
        }
        return x
    }
    
    func rel() -> Expr {
        let x = self.expr()
        switch self.look.tag {
        case Int(Character("<").asciiValue!), Tag.LE, Tag.GE, Int(Character(">").asciiValue!):
            let tok = self.look!
            self.move()
            return Rel(tok: tok, x1: x, x2: self.expr())
        
        default:
            return x
        }
    }
    
    func expr() -> Expr {
        var x = self.term()
        while self.look.tag == Int(Character("+").asciiValue!) ||
              self.look.tag == Int(Character("-").asciiValue!) {
            let tok = self.look!
            self.move()
            x = Arith(tok: tok, x1: x, x2: self.term())
        }
        return x
    }
    
    func term() -> Expr {
        var x = self.unary()
        while self.look.tag == Int(Character("*").asciiValue!) ||
              self.look.tag == Int(Character("/").asciiValue!) {
            let tok = self.look!
            self.move()
            x = Arith(tok: tok, x1: x, x2: self.unary())
        }
        return x
    }
    
    func unary() -> Expr {
        if self.look.tag == Int(Character("-").asciiValue!) {
            self.move()
            return Unary(tok: Word.minus, x: self.unary())
        } else if self.look.tag == Int(Character("!").asciiValue!) {
            let tok = self.look!
            self.move()
            return Not(tok: tok, x1: self.unary(), x2: self.unary())
        } else {
            return self.factor()!
        }
    }
        
    func factor() -> Expr? {
        var x: Expr?
        switch self.look.tag {
        case Int(Character("(").asciiValue!):
            self.move()
            x = self.bool()
            match(t: Int(Character(")").asciiValue!))
            return x
        case Tag.NUM:
            x = Constant(tok: self.look, p: Type.int)
            self.move()
            return x
        case Tag.REAL:
            x = Constant(tok: self.look, p: Type.float)
            self.move()
            return x
        case Tag.TRUE:
            x = Constant.True
            self.move()
            return x
        case Tag.FALSE:
            x = Constant.False
            self.move()
            return x
        case Tag.ID:
//            let s = self.look.toString()
            let id = top!.get(w: self.look)
            if id == nil {
                try! error("\(self.look.toString()) undeclared")
            }
            self.move()
            if self.look.tag != Int(Character("[").asciiValue!) {
                return id
            } else {
                return self.offset(id!)
            }
        default:
            try! self.error("syntax error")
            return x
        }
    }
    
    func offset(_ a: Id) -> Access {
        var i: Expr
        var w: Expr
        var t1: Expr
        var t2: Expr
        var loc: Expr
        var type = a.type
        match(t: Int(Character("[").asciiValue!))
        i = self.bool()
        match(t: Int(Character("]").asciiValue!))
        type = (type as! Array).of
        w = Constant(i: type!.width)
        t1 = Arith(tok: Token(t: Int(Character("*").asciiValue!)), x1: i, x2: w)
        loc = t1
        while self.look.tag == Int(Character("[").asciiValue!) {
            match(t: Int(Character("[").asciiValue!))
            i = self.bool()
            match(t: Int(Character("]").asciiValue!))
            type = (type as! Array).of
            w = Constant(i: type!.width)
            t1 = Arith(tok: Token(t: Int(Character("*").asciiValue!)), x1: i, x2: w)
            t2 = Arith(tok: Token(t: Int(Character("+").asciiValue!)), x1: loc, x2: t1)
            loc = t2
        }
        return Access(a: a, i: loc, p: type)
    }
    
}

class Env {
    private var table: [Token : Id] // TODO(GUI): Tem que implementar os hashable de Token e Id
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
    
    func put(w: Token, i: Int) {
        self.table.updateValue(w.toString(), forKey: i)
    }
    
    func get(w: Token) -> Id? {
        var e: Env? = self
        
        while e != nil {
            let found: Id?
            
            if e!.table[w.tag] != nil {
                // TODO(GUI): ISSO AQUI TA MEGA ERRADO
                found = Id(id: Word(s: w.toString(), tag: w.tag), p: Type(s: w.toString(), tag: w.tag, w: w.tag), b: w.tag)
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

// Arquivo: array.swift (deveria ser Array.swift)
class Array: Type {
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
    var type: Type?
    
    init(tok: Token, p: Type?) {
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
    
    func emitJumps(test: String, t: Int, f: Int) {
        if t != 0 && f != 0 {
            emit(s: "if \(test) goto L \(t)")
            emit(s: "goto L \(f)")
        } else if t != 0 {
            emit(s: "if \(test) goto L \(t)")
        } else if f != 0 {
            emit(s: "iffalse \(test) goto L \(f)")
        }
        // Se não nenhum desses casos não faz nada
    }
    
    func toString() -> String {
        return self.op.toString()
    }
}

class Id: Expr, Hashable {
    var hashValue: Int
    
    static func == (lhs: Id, rhs: Id) -> Bool {
        <#code#>
    }
    
    var offset: Int
    
    init(id: Word, p: Type, b: Int) {
        self.offset = b
        super.init(tok: id, p: p)
    }
}

class Op: Expr {
    
    override init(tok: Token, p: Type?) {
        super.init(tok: tok, p: p)
    }
    
    override func reduce() -> Expr {
        let x = gen()
        let t = Temp(p: type)
        
        emit(s: "\(t.toString()) = \(x.toString())")
        
        return t
    }
}


class Arith: Op {
    let expr1, expr2: Expr
    
    init(tok: Token, x1: Expr, x2: Expr) {
        self.expr1 = x1
        self.expr2 = x2
        super.init(tok: tok, p: nil)

        self.type = Type.max(p1: expr1.type, p2: expr2.type)
        
        if type == nil {
            // Deixei sem tratar porque não é pra rodar mais de que der error
            try! error(s: "type error")
        }
        
    }
    
    override func gen() -> Expr {
        return Arith.init(tok: op, x1: expr1.reduce(), x2: expr2.reduce())
    }
    
    override func toString() -> String {
        return "\(expr1.toString()) \(op.toString()) \(expr2.toString())"
    }
}

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

class Unary: Op {
    var expr: Expr
    
    init(tok: Token, x: Expr) {
        self.expr = x
        super.init(tok: tok, p: nil)

        self.type = Type.max(p1: Type.int, p2: expr.type)
        if type == nil {
            try! error(s: "type error")
        }
    }
    
    override func gen() -> Expr {
        return Unary(tok: op, x: expr.reduce())
    }
    
    override func toString() -> String {
        return "\(op.toString()) \(expr.toString())"
    }
}

class Constant: Expr {
    override init(tok: Token, p: Type?) {
        super.init(tok: tok, p: p)
    }
    
    init(i: Int) {
        super.init(tok: Num(v: i), p: Type.int)
    }
    
    static var True  = Constant(tok: Word.True, p: Type.bool),
               False = Constant(tok: Word.False, p: Type.bool)
    
    override func jumping(t: Int, f: Int) {
        if self === Constant.True && t != 0 {
            emit(s: "goto L \(t)")
        } else if self === Constant.False && f != 0 {
            emit(s: "goto L \(f)")
        }
    }
}

class Logical: Expr {
    var expr1, expr2: Expr
    
    init(tok: Token, x1: Expr, x2: Expr) {
        self.expr1 = x1
        self.expr2 = x2
        super.init(tok: tok, p: nil)
        self.type = check(p1: expr1.type, p2: expr2.type)
        
        if type == nil {
            try! error(s: "type error")
        }
    }
    
    func check(p1: Type?, p2: Type?) -> Type? {
        if p1 === Type.bool && p2 === Type.bool {
            return Type.bool
        } else {
            return nil
        }
    }
    
    override func gen() -> Expr {
        let f = newLabel()
        let a = newLabel()
        
        let temp = Temp(p: type)
        self.jumping(t: 0, f: f)
        
        emit(s: "\(temp.toString()) = true")
        emit(s: "goto L \(a)")
        emitLabel(i: f)
        emit(s: "\(temp.toString()) = false")
        emitLabel(i: a)
        
        return temp
    }
    
    override func toString() -> String {
        return expr1.toString() + " " + op.toString() + " " + expr2.toString()
    }
}


class Or: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x1, x2: x2)
    }
    
    override func jumping(t: Int, f: Int) {
        let label = t != 0 ? t : newLabel()
        expr1.jumping(t: label, f: 0)
        expr2.jumping(t: t, f: f)
        if t == 0 {
            emitLabel(i: label)
        }
    }
}

class And: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x2, x2: x2)
    }
    
    override func jumping(t: Int, f: Int) {
        let label = f != 0 ? f : newLabel()
        expr1.jumping(t: 0, f: label)
        expr2.jumping(t: f, f: t)
        
        if f == 0 {
            emitLabel(i: label)
        }
    }
    
    override func toString() -> String {
        return op.toString() + " " + expr2.toString()
    }
}

class Not: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x2, x2: x2)
    }
    
    override func jumping(t: Int, f: Int) {
        expr2.jumping(t: f, f: t)
    }
    
    override func toString() -> String {
        return op.toString() + " " + expr2.toString()
    }
}


class Rel: Logical {
    override init(tok: Token, x1: Expr, x2: Expr) {
        super.init(tok: tok, x1: x2, x2: x2)
    }
    
    override func check(p1: Type?, p2: Type?) -> Type? {
        if p1 is Array || p2 is Array {
            return nil
        } else if p1 === p2 {
            return Type.bool
        } else {
            return nil
        }
    }
    
    override func jumping(t: Int, f: Int) {
        let a = expr1.reduce()
        let b = expr2.reduce()
        let test = a.toString() + " " + op.toString() + " " + b.toString()
        emitJumps(test: test, t: t, f: f)
        emit(s: "if " + test + " goto L \(t)")
        emit(s: "goto L \(f)")
    }
    
    override func toString() -> String {
        return op.toString() + " " + expr2.toString()
    }
}

class Access: Op {
    var array: Id
    var index: Expr
    
    init(a: Id, i: Expr, p: Type?) {
        self.array = a
        self.index = i
        
        super.init(tok: Word(s: "[]", tag: Tag.INDEX), p: p)
    }
    
    override func gen() -> Expr {
        return Access(a: array, i: index.reduce(), p: type)
    }
    
    override func jumping(t: Int, f: Int) {
        emitJumps(test: reduce().toString(), t: t, f: f)
    }
    
    override func toString() -> String {
        return array.toString() + " [ " + index.toString() + " ] "
    }
}

class Stmt: Node {
    override init() {}
    
    static var Null = Stmt()
    func gen(b: Int, a: Int) {}
    
    var after: Int = 0
    static var Enclosing: Stmt = Stmt.Null
}


class If: Stmt {
    var expr: Expr
    var stmt: Stmt
    
    init(x: Expr, s: Stmt) {
        self.expr = x
        self.stmt = s
        
        if !(expr.type === Type.bool) {
            try! expr.error(s: "boolean required in if")
        }
    }
    
    override func gen(b: Int, a: Int) {
        let label = newLabel()
        expr.jumping(t: 0, f: a)
        emitLabel(i: label)
        stmt.gen(b: label, a: a)
    }
}

class Else: Stmt {
    var expr: Expr
    var stmt1: Stmt
    var stmt2: Stmt
    
    init(x: Expr, s1: Stmt, s2: Stmt) {
        self.expr = x
        self.stmt1 = s1
        self.stmt2 = s2
        if !(expr.type === Type.bool) {
            try! expr.error(s: "boolean required in if")
        }
    }
    
    override func gen(b: Int, a: Int) {
        let label1 = newLabel()
        let label2 = newLabel()
        
        expr.jumping(t: 0, f: label2)
        emitLabel(i: label1)
        stmt1.gen(b: label1, a: a)
        emit(s: "goto L \(a)")
        
        emitLabel(i: label2)
        stmt1.gen(b: label2, a: a)
    }
}

class While: Stmt {
    var expr: Expr?
    var stmt: Stmt?
    
    override init() {
        self.expr = nil
        self.stmt = nil
    }
    
    init(x: Expr?, s: Stmt?) {
        self.expr = x
        self.stmt = s
        
        if !(expr?.type === Type.bool) {
            try! expr?.error(s: "boolean required in while")
        }
    }
    
    override func gen(b: Int, a: Int) {
        self.after = a
        self.expr?.jumping(t: 0, f: a)
        
        let label = newLabel()
        emitLabel(i: label)
        stmt?.gen(b: label, a: b)
        emit(s: "goto L \(b)")
    }
}

class Do: Stmt {
    var expr: Expr?
    var stmt: Stmt?
    
    override init() {
        self.expr = nil
        self.stmt = nil
    }
    
    init(s: Stmt, x: Expr) {
        self.expr = x
        self.stmt = s
        super.init()
        
        if !(expr?.type === Type.bool) {
            try! error(s: "boolean required in do")
        }
    }
    
    override func gen(b: Int, a: Int) {
        self.after = a
        let label = newLabel()
        stmt?.gen(b: b, a: label)
        emitLabel(i: label)
        expr?.jumping(t: b, f: 0)
    }
}

class Set: Stmt {
    var id: Id
    var expr: Expr
    
    init(i: Id, x: Expr) {
        self.id = i
        self.expr = x
        super.init()
        
        if check(p1: id.type, p2: x.type) == nil {
            try! error(s: "type error")
        }
    }
    
    func check(p1: Type?, p2: Type?) -> Type? {
        if Type.numeric(p: p1) && Type.numeric(p: p2) {
            return p2
        }
        
        else if p1?.lexeme == Type.bool.lexeme && p2?.lexeme == Type.bool.lexeme {
            return p2
        }
        
        else {
            return nil
        }
    }
    
    func gen(a: Int, b: Int) {
        emit(s: "\(id.toString()) = \(expr.gen().toString())")
    }
}

class SetElem: Stmt {
    var array: Id
    var index: Expr
    var expr: Expr
    
    init(x: Access, y: Expr) {
        self.array = x.array
        self.index = x.index
        self.expr = y
        super.init()
        
        if check(p1: x.type, p2: expr.type) == nil {
            try! expr.error(s: "type error")
        }
    }
    
    func check(p1: Type?, p2: Type?) -> Type? {
        if p1 is Array || p2 is Array {
            return nil
        }
        
        else if p1 === p2 { // === verifica se p1 aponta pro mesmo endereco de p2
            return p2       // semelhante ao == do Java
        }
        
        else if Type.numeric(p: p1) && Type.numeric(p: p2) {
            return p2
        }
        
        else {
            return nil
        }
    }
    
    override func gen(b: Int, a: Int) {
        let s1: String = index.reduce().toString()
        let s2: String = expr.reduce().toString()
        
        emit(s: "\(array.toString()) [ \(s1) ] = \(s2)")
    }
}

// Seq.swift
class Seq: Stmt {
    var stmt1: Stmt
    var stmt2: Stmt
    
    init(s1: Stmt, s2: Stmt) {
        self.stmt1 = s1
        self.stmt2 = s2
    }
    
    override func gen(b: Int, a: Int) {
        if stmt1 === Stmt.Null {
            stmt2.gen(b: b, a: a)
        }
        
        else if stmt2 === Stmt.Null {
            stmt1.gen(b: b, a: a)
        }
        
        else {
            let label = newLabel()
            stmt1.gen(b: b, a: label)
            emitLabel(i: label)
            stmt2.gen(b: label, a: a)
        }
    }
}

// Break.swift
class Break: Stmt {
    var stmt: Stmt
    
    // eis um problema! pg.617 ou pg.14
    override init() {
        self.stmt = Stmt.Enclosing
        super.init()
        
        if Stmt.Enclosing === Stmt.Null { // talvez isso resolva mas sem ctz
            try! error(s: "unenclosed break")
        }
    }
    
    override func gen(b: Int, a: Int) {
        emit(s: "goto L \(stmt.after)")
    }
}


