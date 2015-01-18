#SUNDAY-LANG
######the programming language to learn during foggy sundays

The idea is to crete a new language that gets compiled to C. This language is inspired by AppleScript [http://en.wikipedia.org/wiki/AppleScript].


This is an example of how the synthax should become:

```
integer two_to_the[x] (
    use integer y
    set y to 1

    while x > 0 do
        set y to y*2
        set x to x-1
    end

    return y
)

integer main (
    use integer x
    use integer y

    set x to two_to_the[5]
    set y to two_to_the[9]

    return x-y
)
```
