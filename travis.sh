#!/bin/sh

case $TARGET in
    "cpp")
        haxe -cp test -main Test -D test \
        -cpp bin \
        -cmd ./bin/Test
        ;;
    "neko")
        haxe -cp test -main Test -D test \
        -D neko-source -neko bin/test.n \
        -cmd neko ./bin/test.n
        ;;
    "js")
        haxe -cp test -main Test -D test \
        -js bin/test.js \
        -cmd node ./bin/test.js
        ;;
    *)
esac
