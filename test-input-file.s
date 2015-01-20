integer main (
    use integer x
    use integer y

    set x to 1+2+3+5+8+13+21
    set y to 1

    while x > 0 do
        use integer z
        set z to x 

        while y < x do
            use integer z
            set z to x-y
            set y to y+1
        end

        set x to x - 1
        set y to 1
    end

    if x = 0 then
        use integer x
        set x to 1+2+3+4+5+8+13+21
    else
        use integer x
        set x to y-x
    end

    return 1
)
