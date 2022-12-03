function calcscore(file)
    m = 0
    scores = Dict([("AX",4),("AY",8),("AZ",3),
                   ("BX",1),("BY",5),("BZ",9),
                   ("CX",7),("CY",2),("CZ",6)])
    open(file,"r") do f
        while !eof(f)
            s = replace(readline(f)," " => "")
            m += scores[s]
        end
    end
    return m
end

function calcscore_inv(file)
    m = 0
    scores = Dict([("AX",3),("AY",4),("AZ",8),
                   ("BX",1),("BY",5),("BZ",9),
                   ("CX",2),("CY",6),("CZ",7)])
    open(file,"r") do f
        while !eof(f)
            s = replace(readline(f)," " => "")
            m += scores[s]
        end
    end
    return m
end
println(calcscore("day02_test.txt"))
println(calcscore("day02_input.txt"))

println(calcscore_inv("day02_test.txt"))
println(calcscore_inv("day02_input.txt"))

