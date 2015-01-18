integer main (
    use integer x
    use integer y

    set x to 1+2+3+5+8+13+21
    set y to 1

    while x > 0 do
        set x to x - 1
        set y to y * 2
    end

    if x = 0 then
        set x to 1+2+3+4+5+8+13+21
    else
        set x to y-x
    end

    return 1
)
