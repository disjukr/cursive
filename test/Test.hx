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
    public function testIsName() {
        assertTrue(Cson.isName("a"));
        assertTrue(Cson.isName("A"));
        assertTrue(Cson.isName("0"));
        assertTrue(Cson.isName("9"));
        assertFalse(Cson.isName(" "));
        assertFalse(Cson.isName("\t"));
        assertFalse(Cson.isName("\n"));
        assertFalse(Cson.isName("\r"));
        assertFalse(Cson.isName(","));
        assertFalse(Cson.isName(":"));
        assertFalse(Cson.isName("="));
        assertFalse(Cson.isName("\""));
        assertFalse(Cson.isName("\'"));
        assertFalse(Cson.isName("["));
        assertFalse(Cson.isName("{"));
        assertFalse(Cson.isName("]"));
        assertFalse(Cson.isName("}"));
        assertFalse(Cson.isName("#"));
    }
    public function testIsWS() {
        assertTrue(Cson.isWS(" "));
        assertTrue(Cson.isWS("\t"));
        assertTrue(Cson.isWS("\n"));
        assertTrue(Cson.isWS("\r"));
        assertFalse(Cson.isWS("a"));
        assertFalse(Cson.isWS(","));
    }
}
