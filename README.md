#SUNDAY-LANG
######the programming language to learn during foggy sundays

The idea is to crete a new language that gets compiled to C. This language is inspired by AppleScript [http://en.wikipedia.org/wiki/AppleScript].


This is an example of how the synthax should become:

```
(
    use variable x
    set variable c to 10

    while c > 1 do
        set variable c to c - 1
        print c
        print "\n"
    end

    if c = 1 then
        print "countdown terminated"
    else
        print "an error occurred"
    end
)

(
    use variable x
    use variable y
    use variable z
    use variable w

    set variable x to 5
    set variable y to x+2
    set variable z to cos(y)
    set variable w to "hello world!"

    print w
)
```
