#SUNDAY-LANG
######the programming language to learn during foggy sundays

The idea is to crete a new language that gets compiled to C. This language is inspired by AppleScript [http://en.wikipedia.org/wiki/AppleScript].


This is an example of how the synthax should become:

```
two_to_the[x] (
        use variable y
        set variable y to 1

        while x > 0 do
                set variable y to y*2
                set variable x to x-1
        end

        return y
)

main (
        use variable exp
        use variable result

        set variable exp to 5
        set variable result to two_to_the[exp]
        print result
        print "\n"

        set variable exp to 10
        set variable result to two_to_the[exp]
        print result
        print "\n"
)

```
