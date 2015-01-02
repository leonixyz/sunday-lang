#SUNDAY-LANG
######yet another programming language

**This is meant to be a final deliverable for the course of Formal Languages and Compilers for the Free University of Bozen. Development is at a very early stage.**

-----------------------------------
These features are currently under development:
 - variables (numeric, strings)
 - numeric constants (real)
 - flow control statements (if, if-else, while)

The idea is to create an imperative language that is compiled to C. In this way it's easy to produce real executables by simply calling gcc on the final output of the compiler. This programming language is inspired by AppleScript [http://en.wikipedia.org/wiki/AppleScript].


This is an example of how the synthax should become:
```
set variable x to 5

while x > 1
    set variable x to x - 1
    print x
end

if x = 1 then
    print "countdown terminated"
else
    print "an error occurred"
end

```
