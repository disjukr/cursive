package haxe;

import haxe.Json;

using StringTools;
using haxe.Utf8;

class Cson {
    static inline var BACKSPACE: String = String.fromCharCode(8);
    static inline var FORM_FEED: String = String.fromCharCode(12);

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
    isQuote(char: String): Bool {
        return char == "\"" || char == "\'";
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
    isBracket(char: String): Bool {
        return isBeginOfBracket(char) || isEndOfBracket(char);
    }

    static #if test public #else inline #end function
    stringToLiteral(string: String): String {
        return string.replace("\\", "\\\\").replace(BACKSPACE, "\\b")
                     .replace(FORM_FEED, "\\f").replace("\n", "\\n")
                     .replace("\r", "\\r").replace("\t", "\\t")
                     .replace("\"", "\\\"");
    }

    static #if test public #else inline #end function
    charAt(text: String, index: Int): String {
        var code: Null<Int> = text.charCodeAt(index);
        return if (code == null) null else String.fromCharCode(code);
    }

    static #if test public #end function
    tokenize(text: String): Array<String> {
        var tokens: Array<String> = [];
        var prevChar, currentChar, nextChar;
        var i: Int = -1;
        var length = text.length;
        while (++i < length) {
            currentChar = charAt(text, i);
            prevChar = charAt(text, i - 1);
            nextChar = charAt(text, i + 1);
            if (isBracket(currentChar)) tokens.push(currentChar);
            else if (currentChar == "," || currentChar == "\n") continue;
            else if (isCRLF(currentChar, nextChar)) ++i;
            else if (isNameSeparator(currentChar)) tokens.push(":");
            else if (isQuote(currentChar)) {
                var escapeCount: Int = 0;
                var isSQuote = currentChar == "\'";
                var from = i;
                inline function nextChar() {
                    currentChar = charAt(text, ++i);
                    prevChar = charAt(text, i - 1);
                }
                nextChar();
                if (isSQuote) {
                    var buffer: StringBuf = new StringBuf();
                    while (!isEndOfSQuote(prevChar, currentChar) &&
                           i < length) {
                        if (currentChar == "\"" && (escapeCount % 2) == 0)
                            buffer.add("\\");
                        buffer.add(currentChar);
                        escapeCount = if (currentChar == "\\") escapeCount + 1
                                      else 0;
                        nextChar();
                    }
                    tokens.push("\"" + buffer.toString() + "\"");
                }
                else {
                    while (!isEndOfDQuote(prevChar, currentChar) && i < length)
                        nextChar();
                    #if cpp
                    // currently `Utf8.sub()` has a problem in cpp target
                    // https://github.com/HaxeFoundation/haxe/issues/2268
                    tokens.push(function (): String {
                        var array: Array<Int> = untyped
                            __global__.__hxcpp_utf8_string_to_char_array(text);
                        var sub = array.splice(from, i - from + 1);
                        return untyped
                            __global__.__hxcpp_char_array_to_utf8_string(sub);
                    }());
                    #else
                    tokens.push(text.sub(from, i - from + 1));
                    #end
                }
            }
            else "TODO";
        }
        return tokens;
    }

    public static function toJson(text: String, indent: Int): String {
        return "TODO";
    }

    public static function parse(text: String): Dynamic {
        "TODO";
        return Json.parse(text);
    }
}
