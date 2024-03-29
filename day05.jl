function read_start_config(iostream;padding =1)
    stacks = Vector{Vector{Char}}()
    line = readline(iostream)
    linelength = length(line)
    num_stacks = Int((linelength+padding)/4)
    for _ = 1:num_stacks
        push!(stacks,Vector{Char}())
    end
    for id in 1:num_stacks
        c = line[id*4-2]
        if c!=' '
            push!(stacks[id],c)
        end
    end
    while true
        line = readline(iostream)
        linelength = length(line)
        if linelength==0
            break
        end
        for id in 1:num_stacks
            c = line[id*4-2]
            if c!=' '
                push!(stacks[id],c)
            end
        end
    end
    for id in 1:num_stacks
        pop!(stacks[id])
    end
    return stacks
end


function read_and_apply_moves_9000(iostream,stacks)
    for line = eachline(iostream)
        v = split(line)
        move_crates_one_by_one(stacks,parse(Int,v[2]),parse(Int,v[4]),parse(Int,v[6]))
    end
    return stacks
end
function read_and_apply_moves_9000(iostream,stacks)
    for line = eachline(iostream)
        v = split(line)
        move_crates_one_by_one(stacks,parse(Int,v[2]),parse(Int,v[4]),parse(Int,v[6]))
    end
    return stacks
end

function read_and_apply_moves_9001(iostream,stacks)
    for line = eachline(iostream)
        v = split(line)
        move_crates_as_stack(stacks,parse(Int,v[2]),parse(Int,v[4]),parse(Int,v[6]))
    end
    return stacks
end

function read_and_apply_moves_both(iostream,stacks)
    stacks_9000 = stacks
    stacks_9001 = deepcopy(stacks)
    for line = eachline(iostream)
        v = split(line)
        num = parse(Int,v[2])
        src = parse(Int,v[4])
        dst = parse(Int,v[6])
        move_crates_one_by_one(stacks_9000,num,src,dst)
        move_crates_as_stack(stacks_9001,num,src,dst)
    end
    return stacks_9000,stacks_9001
end

function move_crates_one_by_one(stacks, num, src, dest)
    crates= splice!(stacks[src],1:num)
    prepend!(stacks[dest],reverse!(crates))
end

function move_crates_as_stack(stacks, num, src, dest)
    crates= splice!(stacks[src],1:num)
    prepend!(stacks[dest],crates)
end

function get_top_crates(stacks)
    s = IOBuffer()
    for n = eachindex(stacks)
        write(s,stacks[n][1])
    end
    return String(take!(s))
end
   

file = "day05_input.txt"
padding = 0

function do_9000(file)
    iostream = open(file)
    stacks = read_start_config(iostream;padding=padding)
    stacks = read_and_apply_moves_9000(iostream,stacks)
    topcrates = get_top_crates(stacks)
    close(iostream)
    return topcrates
end
function do_9001(file)
    iostream = open(file)
    stacks = read_start_config(iostream;padding=padding)
    stacks = read_and_apply_moves_9001(iostream,stacks)
    topcrates = get_top_crates(stacks)
    close(iostream)
    return topcrates
end

function do_both(file)
    iostream = open(file)
    stacks = read_start_config(iostream;padding=padding)
    (stacks_9000,stacks_9001) = read_and_apply_moves_both(iostream,stacks)
    (topcrates_9000,stacks_9001) = (get_top_crates(stacks_9000),get_top_crates(stacks_9001))
    close(iostream)
    return (topcrates_9000,stacks_9001)
end

# @time a = do_9000(file)
# @time b = do_9001(file)
@time c = do_both(file)

println(a)
println(b)
println(c)