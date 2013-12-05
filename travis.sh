#!/bin/sh

echo testing $TARGET

mkdir bin

case $TARGET in
    "cpp")
        haxe -cp test -main Test -D test \
        -cpp bin
        ./bin/Test
        ;;
    "neko")
        haxe -cp test -main Test -D test \
        -D neko-source -neko bin/test.n
        neko ./bin/test.n
        ;;
    "js")
        haxe -cp test -main Test -D test \
        -js bin/test.js
        node ./bin/test.js
        ;;
    *)
        echo unsupported target
        ;;
esac
