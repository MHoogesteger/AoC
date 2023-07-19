file = "day06_input.txt"


function part_one(file)
    iostream = open(file)
    for line = eachline(iostream)
    id=0
    while !allunique(line[id.+range(stop=14)])
        id +=1
    end
    println(id+14)
    end
    close(iostream)
    return nothing
end

@show part_one(file)