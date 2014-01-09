package haxe;

import haxe.Json;

using StringTools;
using haxe.Utf8;

class Cson {
    static inline var BACKSPACE: String = String.fromCharCode(8);
    static inline var FORM_FEED: String = String.fromCharCode(12);

    static #if test public #end inline function
    isName(char: String): Bool {
        return if (isWS(char)) false else switch (char) {
        case ",", ":", "=", "\"", "\'", "[", "{", "]", "}", "#":
            false;
        default:
            true;
        }
    }

    static #if test public #end inline function
    isWS(char: String): Bool {
        return char.isSpace(0);
    }

    static #if test public #end inline function
    isCRLF(char: String, nextChar: String): Bool {
        return char == "\r" && nextChar == "\n";
    }

    static #if test public #end inline function
    isNameSeparator(char: String): Bool {
        return char == ":" || char == "=";
    }

    static #if test public #end inline function
    isEndOfDQuote(prevChar: String, char: String): Bool {
        return prevChar != "\\" && char == "\"";
    }

    static #if test public #end inline function
    isEndOfSQuote(prevChar: String, char: String): Bool {
        return prevChar != "\\" && char == "\'";
    }

    static #if test public #end inline function
    isQuote(char: String): Bool {
        return char == "\"" || char == "\'";
    }

    static #if test public #end inline function
    isBeginOfBracket(char: String): Bool {
        return char == "[" || char == "{";
    }

    static #if test public #end inline function
    isEndOfBracket(char: String): Bool {
        return char == "]" || char == "}";
    }

    static #if test public #end inline function
    isBracket(char: String): Bool {
        return isBeginOfBracket(char) || isEndOfBracket(char);
    }

    static #if test public #end inline function
    stringToLiteral(string: String): String {
        return string.replace("\\", "\\\\").replace(BACKSPACE, "\\b")
                     .replace(FORM_FEED, "\\f").replace("\n", "\\n")
                     .replace("\r", "\\r").replace("\t", "\\t")
                     .replace("\"", "\\\"");
    }

    static #if test public #end inline function
    charAt(text: String, index: Int): String {
        return if (text == null ||
                   0 > index ||
                   index >= Utf8.length(text)) ""
            else {
                var code: Null<Int> = Utf8.charCodeAt(text, index);
                if (code == null) "" else String.fromCharCode(code);
            }
    }

    static #if test public #end function
    tokenize(text: String): Array<String> {
        #if cpp
        // currently `Utf8.sub()` has a problem in cpp target
        // https://github.com/HaxeFoundation/haxe/issues/2268
        inline function sub(text, pos, len): String {
            var array: Array<Int> = untyped
                __global__.__hxcpp_utf8_string_to_char_array(text);
            var sub = array.splice(pos, len);
            return untyped
                __global__.__hxcpp_char_array_to_utf8_string(sub);
        }
        #end
        var tokens: Array<String> = [];
        var prevChar, currentChar, nextChar;
        var i: Int = -1;
        var length = Utf8.length(text);
        while (++i < length) {
            currentChar = charAt(text, i);
            prevChar = charAt(text, i - 1);
            nextChar = charAt(text, i + 1);
            inline function updatePrev() {
                currentChar = charAt(text, ++i);
                prevChar = charAt(text, i - 1);
            }
            inline function updateNext() {
                currentChar = charAt(text, ++i);
                nextChar = charAt(text, i + 1);
            }
            if (isBracket(currentChar)) tokens.push(currentChar);
            else if (isWS(currentChar) || currentChar == ",") continue;
            else if (isCRLF(currentChar, nextChar)) ++i;
            else if (isNameSeparator(currentChar)) tokens.push(":");
            else if (isQuote(currentChar)) {
                var escapeCount: Int = 0;
                var isSQuote = currentChar == "\'";
                var from = i;
                updatePrev();
                if (isSQuote) {
                    var buffer: StringBuf = new StringBuf();
                    while (!isEndOfSQuote(prevChar, currentChar) &&
                           i < length) {
                        if (currentChar == "\"" && (escapeCount % 2) == 0)
                            buffer.add("\\");
                        buffer.add(currentChar);
                        escapeCount = if (currentChar == "\\") escapeCount + 1
                                      else 0;
                        updatePrev();
                    }
                    tokens.push("\"" + buffer.toString() + "\"");
                }
                else {
                    while (!isEndOfDQuote(prevChar, currentChar) && i < length)
                        updatePrev();
                    tokens.push(#if cpp sub(text,
                                #else text.sub( #end from, i - from + 1));
                }
            }
            else if (currentChar == "|") {
                var buffer: Array<String> = [];
                var exit;
                var from;
                inline function startLine() {
                    exit = false;
                    from = i + 1;
                }
                inline function push() {
                    buffer.push(stringToLiteral(#if cpp sub(text,
                        #else text.sub( #end from, i - from)));
                    exit = true;
                }
                startLine();
                while (i < length) {
                    updateNext();
                    if (exit) {
                        if (currentChar == "|") {
                            startLine();
                            continue;
                        }
                        else if (isCRLF(currentChar, nextChar)) {
                            ++i;
                            break;
                        }
                        else if (currentChar == "\n") break;
                        else if (!isWS(currentChar)) {
                            --i;
                            break;
                        }
                    }
                    else if (isCRLF(currentChar, nextChar)) {
                        push();
                        ++i;
                    }
                    else if (currentChar == "\n")
                        push();
                }
                if (!exit) push();
                tokens.push("\"" + buffer.join("\\n") + "\"");
            }
            else if (currentChar == "#") {
                while (i < text.length) {
                    updateNext();
                    if (currentChar == "\n") break;
                    else if (isCRLF(currentChar, nextChar)) {
                        ++i;
                        break;
                    }
                }
            }
            else {
                if (!isName(nextChar)) {
                    tokens.push(currentChar);
                    continue;
                }
                var from = i;
                while (i < text.length) {
                    updateNext();
                    if (!isName(nextChar)) break;
                }
                tokens.push(#if cpp sub(text,
                            #else text.sub( #end from, i - from + 1));
            }
        }
        return tokens;
    }

    public static function toJson(text: String, indent: Dynamic = 0): String {
        var tokens = tokenize(text);
        var indentLevel = 0;
        var doIndent = true;
        if (Std.is(indent, Int) && indent > 0) {
            var indentCount = indent;
            indent = "";
            for (i in 0...indentCount)
                indent += " ";
        }
        else if (Type.getClass(indent) == String) {
            var indentCount = Std.parseInt(indent);
            if (indentCount != null) {
                indent = "";
                for (i in 0...indentCount)
                    indent += " ";
            }
        }
        else if (indent == true) {
            indent = "    ";
        }
        else {
            doIndent = false;
        }
        inline function newline(): String {
            var indentBuffer = "";
            for (i in 0...indentLevel)
                indentBuffer += indent;
            return "\n" + indentBuffer;
        }
        if (!isBeginOfBracket(tokens[0])) {
            var second = tokens[1];
            if (second != null) {
                if (second == ":") {
                    tokens.unshift("{");
                    tokens.push("}");
                }
                else {
                    tokens.unshift("[");
                    tokens.push("]");
                }
            }
        }
        for (i in 0...tokens.length) {
            var token = tokens[i];
            var first = charAt(token, 0);
            var nextToken = tokens[i + 1];
            var nextFirst = charAt(nextToken, 0);
            if (doIndent) {
                if (token == ":") tokens[i] += " ";
                if (isBeginOfBracket(first)) ++indentLevel;
                if (isEndOfBracket(first)) --indentLevel;
            }
            if (isName(first) && nextToken == ":")
                tokens[i] = "\"" + token + "\"";
            if ((!isBeginOfBracket(first) && first != ":") &&
                nextToken != null &&
                (!isEndOfBracket(nextFirst) && nextFirst != ":")) {
                tokens[i] += ",";
                if (doIndent) tokens[i] += newline();
            }
        }
        if (doIndent) {
            for (i in 0...tokens.length) {
                var token = tokens[i];
                var prevToken = tokens[i - 1];
                var nextToken = tokens[i + 1];
                var first = charAt(token, 0);
                if (isBeginOfBracket(first)) {
                    ++indentLevel;
                    if ((nextToken != "") &&
                        !isEndOfBracket(charAt(nextToken, 0)))
                        tokens[i] += newline();
                }
                if (isEndOfBracket(first)) {
                    --indentLevel;
                    if ((prevToken != "") &&
                        !isBeginOfBracket(charAt(prevToken, 0)))
                        tokens[i] = newline() + token;
                }
            }
        }
        return tokens.join("");
    }

    public static function parse(csonString: String): Dynamic {
        return Json.parse(toJson(csonString));
    }
}
