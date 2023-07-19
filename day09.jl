function process_line!(snake,line,track,nel,diff)
    dir = line[1]
    steps = parse(Int,line[3:end])
    for  _ in range(stop=steps)
        move_head!(snake,dir)
        move_tail!(snake,nel,diff)
        push!(track,snake[:,end])
        # print_snake(snake)
    end
end

function move_head!(snake,dir)
    if dir == 'R'
        snake[1,1] +=1
    elseif dir =='L'
        snake[1,1] -=1
    elseif dir =='U'
        snake[2,1] +=1
    elseif dir =='D'
        snake[2,1] -=1
    end
end

function print_snake(snake)
    println(transpose(snake))
end

function move_tail!(snake,nel,diff)
    for ind in 2:nel
        @inbounds diff[1] = snake[1,ind-1] - snake[1,ind]
        @inbounds diff[2] = snake[2,ind-1] - snake[2,ind]
        if abs(diff[1]) >1 ||abs(diff[2]) >1
            @inbounds snake[1,ind] += clamp(diff[1], -1, 1)
            @inbounds snake[2,ind] += clamp(diff[2], -1, 1)
        else
            break
        end
        ind +=1
    end
end

file = "day09_large_input.txt"
function proc_file(file,nel)
    f = open(file)
    snake = fill(1,(2,nel))
    diff = fill(0,(2,1))
    track = Vector{Vector{Int64}}()
    sizehint!(Vector{Vector{Int64}}(),100000)
    for line in eachline(f)
        process_line!(snake,line,track,nel,diff)
    end
    println("Number of unique locations: $(length(unique(t)))")
    return snake,track
end


s,t = proc_file(file,2)
@time proc_file(file,2)
@time proc_file(file,2)

s,t = proc_file(file,10)
@time proc_file(file,10)
@time proc_file(file,10)







