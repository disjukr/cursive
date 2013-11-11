import haxe.Cson;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using Reflect;

class Test extends TestCase {
    public function new() {
        super();
    }
    public static function main() {
        var runner = new TestRunner();
        runner.add(new Test());
        runner.run();
    }
    inline function type(a: Dynamic): String {
        return if (Type.getClass(a) == Array) "array";
            else if (Type.getClass(a) == String) "string";
            else if (a.isObject()) "object";
            else "etc";
    }
    inline function compareType(a: Dynamic, b: Dynamic): Bool {
        return type(a) == type(b);
    }
    inline function compareArray(a: Array<Dynamic>, b: Array<Dynamic>): Bool {
        var eq = true;
        if (a.length != b.length)
            eq = false;
        else for (i in 0...a.length) {
            if (!compare(a[i], b[i])) {
                eq = false;
                break;
            }
        }
        return eq;
    }
    inline function compareObject(a: Dynamic, b: Dynamic): Bool {
        var eq = true;
        var fields = a.fields();
        if (fields.length != b.fields().length)
            eq = false;
        else for (field in fields.iterator()) {
            if (!compare(a.field(field), b.field(field))) {
                eq = false;
                break;
            }
        }
        return eq;
    }
    inline function compare(a: Dynamic, b: Dynamic): Bool {
        return if (compareType(a, b)) {
            switch (type(a)) {
            case "array": compareArray(a, b);
            case "object": compareObject(a, b);
            default: a == b;
            }
        }
        else false;
    }
    public function testIsName() {
        inline function assertT(testValue) {
            assertTrue(Cson.isName(testValue));
        }
        inline function assertF(testValue) {
            assertFalse(Cson.isName(testValue));
        }
        assertT("a");
        assertT("A");
        assertT("0");
        assertT("9");
        assertF(" ");
        assertF("\t");
        assertF("\n");
        assertF("\r");
        assertF(",");
        assertF(":");
        assertF("=");
        assertF("\"");
        assertF("\'");
        assertF("[");
        assertF("{");
        assertF("]");
        assertF("}");
        assertF("#");
    }
    public function testIsWS() {
        assertTrue(Cson.isWS(" "));
        assertTrue(Cson.isWS("\t"));
        assertTrue(Cson.isWS("\n"));
        assertTrue(Cson.isWS("\r"));
        assertFalse(Cson.isWS("a"));
        assertFalse(Cson.isWS(","));
    }
    public function testIsCRLF() {
        assertTrue(Cson.isCRLF("\r", "\n"));
        assertFalse(Cson.isCRLF("a", "\n"));
        assertFalse(Cson.isCRLF("\r", "a"));
        assertFalse(Cson.isCRLF("a", "a"));
    }
    public function testIsNameSeparator() {
        assertTrue(Cson.isNameSeparator(":"));
        assertTrue(Cson.isNameSeparator("="));
        assertFalse(Cson.isNameSeparator("a"));
    }
    public function testIsEndOfDQuote() {
        assertTrue(Cson.isEndOfDQuote("a", "\""));
        assertTrue(Cson.isEndOfDQuote("\"", "\""));
        assertFalse(Cson.isEndOfDQuote("\\", "\""));
        assertFalse(Cson.isEndOfDQuote("a", "a"));
        assertFalse(Cson.isEndOfDQuote("\\", "a"));
    }
    public function testIsEndOfSQuote() {
        assertTrue(Cson.isEndOfSQuote("a", "\'"));
        assertTrue(Cson.isEndOfSQuote("\'", "\'"));
        assertFalse(Cson.isEndOfSQuote("\\", "\'"));
        assertFalse(Cson.isEndOfSQuote("a", "a"));
        assertFalse(Cson.isEndOfSQuote("\\", "a"));
    }
    public function testIsQuote() {
        assertTrue(Cson.isQuote("\""));
        assertTrue(Cson.isQuote("\'"));
        assertFalse(Cson.isQuote("`"));
    }
    public function testIsBeginOfBracket() {
        assertTrue(Cson.isBeginOfBracket("["));
        assertTrue(Cson.isBeginOfBracket("{"));
        assertFalse(Cson.isBeginOfBracket("]"));
        assertFalse(Cson.isBeginOfBracket("}"));
        assertFalse(Cson.isBeginOfBracket("("));
        assertFalse(Cson.isBeginOfBracket(")"));
    }
    public function testIsEndOfBracket() {
        assertTrue(Cson.isEndOfBracket("]"));
        assertTrue(Cson.isEndOfBracket("}"));
        assertFalse(Cson.isEndOfBracket("["));
        assertFalse(Cson.isEndOfBracket("{"));
        assertFalse(Cson.isEndOfBracket("("));
        assertFalse(Cson.isEndOfBracket(")"));
    }
    public function isBracket() {
        assertTrue(Cson.isBracket("["));
        assertTrue(Cson.isBracket("{"));
        assertTrue(Cson.isBracket("]"));
        assertTrue(Cson.isBracket("}"));
        assertFalse(Cson.isBracket("("));
        assertFalse(Cson.isBracket(")"));
    }
    public function testStringToLiteral() {
        inline function assert(testValue, expected) {
            assertEquals(expected, Cson.stringToLiteral(testValue));
        }
        assert("", "");
        assert("\t", "\\t");
        assert("a\t", "a\\t");
        assert("a\t\t", "a\\t\\t");
        assert("a\tb\t", "a\\tb\\t");
        assert("\"", "\\\"");
    }
    public function testTokenize() {
        inline function assert(testValue, expected) {
            var actual = Cson.tokenize(testValue);
            if (compareArray(expected, actual))
                assertTrue(true);
            else
                assertEquals(expected, actual);
        }
        assert("[", ["["]);
        assert("}", ["}"]);
        assert("[{}]", ["[", "{", "}", "]"]);
        assert("[ { } ]", ["[", "{", "}", "]"]);
        assert("[,{,},]", ["[", "{", "}", "]"]);
        assert("\'\'", ["\"\""]);
        assert("\'a\'", ["\"a\""]);
        assert("\'\"a\'", ["\"\\\"a\""]);
        assert("\"\"", ["\"\""]);
        assert("\"a\"", ["\"a\""]);
        assert("\"\\\"a\"", ["\"\\\"a\""]);
        assert("\'a\' \'b\'", ["\"a\"", "\"b\""]);
        assert("\"a\" \'b\'", ["\"a\"", "\"b\""]);
        assert("\'a\' \"b\"", ["\"a\"", "\"b\""]);
        assert("\"a\" \"b\"", ["\"a\"", "\"b\""]);
        assert("|a", ["\"a\""]);
        assert("|a\n|b", ["\"a\\nb\""]);
        assert("|a\n|b\n|c", ["\"a\\nb\\nc\""]);
        assert("|a\n |b", ["\"a\\nb\""]);
        assert("|a\n  |b", ["\"a\\nb\""]);
        assert("|abc\n  |def", ["\"abc\\ndef\""]);
        assert("|abc\n  |def\n", ["\"abc\\ndef\""]);
        assert("|abc\n  |def\n\n|a", ["\"abc\\ndef\"", "\"a\""]);
        assert("[#comment]", ["["]);
        assert("[#comment]\n]", ["[", "]"]);
        assert("[#comment]\r\n]", ["[", "]"]);
        assert("0", ["0"]);
        assert("0 1 2 3", ["0", "1", "2", "3"]);
        assert("true", ["true"]);
        assert("true false null", ["true", "false", "null"]);
        assert("true false null ", ["true", "false", "null"]);
        assert("1.23e-1", ["1.23e-1"]);
        assert("1.23e-1 0.123e1", ["1.23e-1", "0.123e1"]);
        assert("1.23e-1 0.123e+1", ["1.23e-1", "0.123e+1"]);
        assert("1.23e-1 0.123e+1 ", ["1.23e-1", "0.123e+1"]);
        assert("[{1, true\n \"DQuote\" \'SQuote\' |verbatim\n|string\n\n}]",
            ["[", "{", "1", "true", "\"DQuote\"", "\"SQuote\"",
             "\"verbatim\\nstring\"", "}", "]"]);
    }
    public function testToJson() {
        inline function assert(testValue, expected) {
            assertEquals(expected, Cson.toJson(testValue));
        }
        assert("0", "0");
        assert("1\n", "1");
        assert("true", "true");
        assert("\"string\"", "\"string\"");
        assert("|verbatim\n|string", "\"verbatim\\nstring\"");
        assert("a = 1\nb = 2", "{\"a\":1,\"b\":2}");
        assertEquals("{\n  \"a\": 1,\n  \"b\": 2\n}",
            Cson.toJson("a = 1, b = 2", 2));
    }
    public function testParse() {
        inline function assert(testValue, expected: Dynamic) {
            var actual = Cson.parse(testValue);
            if (compare(expected, actual))
                assertTrue(true);
            else
                assertEquals(expected, actual);
        }
        assert("true", true);
        assert("false", false);
        assert("null", null);
        assert("0", 0);
        assert("1", 1);
        assert("10", 10);
        assert("-1", -1);
        assert("-1.23e45", -1.23e45);
        assert("\"\"", "");
        assert("\'\'", "");
        assert("\"\'\"", "\'");
        assert("\'\"\'", "\"");
        assert("[]", []);
        assert("[0]", [0]);
        assert("[0, 1]", [0, 1]);
        assert("[true, null, 0, \'string\']", [true, null, 0, "string"]);
        assert("[1, 2, 3, ]", [1, 2, 3]);
        assert("1, 2", [1, 2]);
        assert("3, 4, ", [3, 4]);
        assert("true\nfalse", [true, false]);
        assert("{}", {});
        assert("{\"a\": 0}", {a: 0});
        assert("{\'b\': true}", {b: true});
        assert("{c: null}", {c: null});
        assert("d: \"string\"", {d: "string"});
        assert("e = []", {e: []});
        assert("a = 1, b = true, c = null, d = 'string', e = [], f = {}",
            {a: 1, b: true, c: null, d: "string", e: [], f: {}});
        assert("nested = [[[]], [[], []], []]",
            {nested: [[[]], [[], []], []]});
    }
}
