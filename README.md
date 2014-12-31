#SUNDAY-LANG
######yet another programming language

**This is not meant to be a complete programming language, but only a deliverable for the course of Formal Languages and Compilers for the Free University of Bozen.**

-----------------------------------
Dear Benjamin,


I think these features are necessary, feel free to add what you like:
 - types and variables (integer, real)
 - numeric constants (integer, real)
 - flow control statements (if, if-else, while)
 - ... ?

What whe have to choose in order to implement those things:
 - Synthax
 - Intermediate code
 - ... ?


My idea is to create an imperative language that is compiled to C, the reason is that in this way we can easily produce real executables by simply calling gcc on the final output (the intermediate code) our compiler produces. In this way we can choose whatever nice synthax we want, we can skip code optimization and code generation phases, and in the end we also have a piece of code that works and does something.

Another idea, because prof. Artale is fan of Apple, is that we could implement a new programming language inspired by AppleScript [http://en.wikipedia.org/wiki/AppleScript]. Some weeks ago I read an article on YCombinator about this old language: it stated that such a textual language is very good for absolute beginners because it's easily readable and easily understandable.

If we carefully choose what built-in functions include in our programming language, all we have to do is to use old, stable and well tested C code, like printf, strcmp, etc.

What do you think?



Giulio.
