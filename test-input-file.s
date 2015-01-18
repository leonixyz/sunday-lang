(
    use variable x
    use variable y
    use variable returnValue

    set variable x to 1+2+3+5+8+13+21
    set variable y to 1

    while x > 0 do
        set variable x to x - 1
        set variable y to y * 2
    end

    if x = 0 then
        set variable x to 1+2+3+4+5+8+13+21
    else
        set variable x to y
    end

    set variable returnValue to y - x
)
