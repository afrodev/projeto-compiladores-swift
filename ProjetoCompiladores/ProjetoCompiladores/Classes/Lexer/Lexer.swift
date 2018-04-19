//
//  Lexer.swift
//  ProjetoCompiladores
//
//  Created by Guilherme Paiva on 19/04/2018.
//  Copyright © 2018 GHP Enterprises. All rights reserved.
//

import Foundation

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
