integer main (
        use string welcome
        set welcome to "This will be discarded."
        set welcome to "This is a sample program.\n"

        printf ["%s\n", welcome]

        use integer max
        set max to 80
        
        use integer x
        set x to 1

        while x <= max do
                use integer y
                set y to 1

                while y <= x do
                        printf ["#"]
                        set y to y+1
                end

                printf["\n"]

                set x to x+1
        end

        return 1
)
