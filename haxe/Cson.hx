package haxe;

import haxe.Json;

using StringTools;
using haxe.Utf8;

class Cson {
    static #if test public #else inline #end function
    isName(char: String): Bool {
        return if (isWS(char)) false else switch (char) {
        case ",", ":", "=", "\"", "\'", "[", "{", "]", "}", "#":
            false;
        default:
            true;
        }
    }
    static #if test public #else inline #end function
    isWS(char: String): Bool {
        return char.isSpace(0);
    }
    static #if test public #else inline #end function
    isCRLF(char: String, nextChar: String): Bool {
        return char == "\r" && nextChar == "\n";
    }
    static #if test public #else inline #end function
    isNameSeparator(char: String): Bool {
        return char == ":" || char == "=";
    }
    static #if test public #else inline #end function
    isEndOfDQuote(prevChar: String, char: String): Bool {
        return prevChar != "\\" && char == "\"";
    }
    static #if test public #else inline #end function
    isEndOfSQuote(prevChar: String, char: String): Bool {
        return prevChar != "\\" && char == "\'";
    }
    static #if test public #else inline #end function
    isBeginOfBracket(char: String): Bool {
        return char == "[" || char == "{";
    }
    static #if test public #else inline #end function
    isEndOfBracket(char: String): Bool {
        return char == "]" || char == "}";
    }
    static #if test public #else inline #end function
    stringToLiteral(string: String): String {
        return "TODO";
    }
    static function tokenize(text: String): Array<String> {
        return ["TODO"];
    }
    public static function toJson(text: String, indent: Int): String {
        return "TODO";
    }
    public static function parse(text: String): Dynamic {
        "TODO";
        return Json.parse(text);
    }
}
