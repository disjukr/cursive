import haxe.Cson;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class Test extends TestCase {
    public function new() {
        super();
    }
    public static function main() {
        var runner = new TestRunner();
        runner.add(new Test());
        runner.run();
    }
    inline function compareArray(a: Array<Dynamic>, b: Array<Dynamic>): Bool {
        var eq = true;
        if (a.length != b.length)
            eq = false;
        for (i in 0...a.length)
            if (a[i] != b[i])
                eq = false;
        return eq;
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
        assert("true", ["true"]);
    }
}
