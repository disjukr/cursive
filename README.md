cursive
=======

[![travis](https://travis-ci.org/disjukr/cursive.png)](https://travis-ci.org/disjukr/cursive)

[CSON(cursive script object notation)][cson] implementation for [haxe][haxe].

[cson]: https://github.com/lifthrasiir/cson
[haxe]: http://haxe.org/


What is CSON?
-------------
CSON is strict superset of [JSON][json]
while offering plenty of convenient syntax.

```cson
{
    "key1": "value", # You can write comment!
    key2: "value", # You don't need quoting for key
    key3: "value" # You can omit the comma when followed by newline
    key4 = "value" # You can use equal sign instead of colon
    key5 = 'value' # You can use single quote instead of double quote
    key6 = |You can write
           |multiline string
           |easy
}
```
And...
```cson
"key1": "value", # You can write comment!
key2: "value", # You don't need quoting for key
key3: "value" # You can omit the comma when followed by newline
key4 = "value" # You can use equal sign instead of colon
key5 = 'value' # You can use single quote instead of double quote
key6 = |You can write
       |multiline string
       |easy
```
You can omit the top-level enclosing braces!

that is converted to JSON like this:
```json
{
    "key1": "value",
    "key2": "value",
    "key3": "value",
    "key4": "value",
    "key5": "value",
    "key6": "You can write\nmultiline string\neasy"
}
```

[json]: http://json.org/


License
-------

The MIT License (MIT)

Copyright (c) 2013, JongChan Choi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
