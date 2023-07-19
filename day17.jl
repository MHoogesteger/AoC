function gen_rocks()
    rocks = Vector{Matrix{Bool}}()
    push!(rocks,Bool.([1 1 1 1]))
    push!(rocks,Bool.([0 1 0
                       1 1 1
                       0 1 0]))
    push!(rocks,Bool.([1 1 1
                       0 0 1
                       0 0 1]))
    push!(rocks,reshape(Bool.([1
                       1
                       1
                       1]),4,1))
    push!(rocks,Bool.([1 1
                       1 1]))

    widths = map(a->mapreduce(x->x[2],max,findall(a),init=1),rocks)
    heights = map(a->mapreduce(x->x[1],max,findall(a),init=1),rocks)
    return rocks, widths,heights
end
check_overlap(rock,space) = any(rock.&space)

function check_overlap_quick(rock,space) 
    for idx in eachindex(rock)
        if @inbounds rock[idx]&space[idx]
            return true
        end
    end
    return false 
end

function can_fall(rock,cave,row,col,width,height)
    return row - height > 0 && !check_overlap_quick(rock, @view cave[row-height:row-1,col:col+width-1])
end

function can_right(rock,cave,row,col,width,height)
    return col + width - 1 < 7 && !check_overlap_quick(rock, @view cave[row-height+1:row,col+1:col+width])
end

function can_left(rock,cave,row,col,width,height)
    return col > 1 && !check_overlap_quick(rock, @view cave[row-height+1:row,col-1:col+width-2])
end

function fall_rocks(rocks,widths,heights,pattern,numrocks;width=7,start_pos=3,clearance=3)
    cave = fill(false,(numrocks*maximum(heights)+1000,width))
    n_rocks = length(rocks)
    n_pattern = length(pattern)
    i_rock = 1
    last_top = 0
    i_pattern = 1
    while i_rock<=numrocks
        i_rock_mod = mod1(i_rock, n_rocks)
        r = rocks[i_rock_mod]
        w = widths[i_rock_mod]
        h = heights[i_rock_mod]
        row = last_top+h+3
        col = 3
        while true
            p = pattern[mod1(i_pattern, n_pattern)]
            i_pattern+=1

            if p && can_right(r,cave,row,col,w,h)
                col+=1
            elseif !p && can_left(r,cave,row,col,w,h)
                col-=1
            end

            if can_fall(r,cave,row,col,w,h)
                row-=1
            else
                @views cave[row-h+1:row,col:col+w-1] .= cave[row-h+1:row,col:col+w-1] .| r
                break
            end
        end
        last_top = max(row,last_top)
        i_rock +=1
    end
    return cave[1:last_top,:], last_top
end

function fall_rocks_iter(rocks,widths,heights,pattern,numrocks=1000000;width=7,start_pos=3,clearance=3)
    reprows = Vector{Tuple{Vector{Bool},Int}}()
    cave = fill(false,(numrocks*maximum(heights)+1000,width))
    n_rocks = length(rocks)
    n_pattern = length(pattern)
    i_rock = 1
    last_top = 0
    i_pattern = 1
    while i_rock<=numrocks
        i_rock_mod = mod1(i_rock, n_rocks)
        r = rocks[i_rock_mod]
        w = widths[i_rock_mod]
        h = heights[i_rock_mod]
        row = last_top+h+3
        col = 3
        while true
            i_pattern_mod = mod1(i_pattern, n_pattern)
            p = pattern[i_pattern_mod]
            i_pattern+=1

            if p && can_right(r,cave,row,col,w,h)
                col+=1
            elseif !p && can_left(r,cave,row,col,w,h)
                col-=1
            end

            if can_fall(r,cave,row,col,w,h)
                row-=1
            else
                @views cave[row-h+1:row,col:col+w-1] .= cave[row-h+1:row,col:col+w-1] .| r
                
                if i_rock_mod == 1 && i_pattern_mod == 1 && row > 10
                    push!(reprows,(cave[row-10,:],i_rock))
                end
                break
            end
        end
        last_top = max(row,last_top)
        i_rock +=1
    end
    return reprows, last_top
end

function read_pattern(file)
    pattern = Vector{Bool}()
    open(file) do f
        for c in readeach(f, Char)
            if c == '>' 
                push!(pattern,true)
            elseif c == '<'
                push!(pattern,false)
            else
                error("error reading file pattern")
            end
        end
    end
    return pattern
end

function printcave(cave)
    for slice in Iterators.reverse(eachrow(cave))
        print("|")
        for x in slice
            x ? print("#") : print(".")
        end
        println("|")
    end
end

file = "day17_test.txt"

r,w,h = gen_rocks()
p = read_pattern(file)

c,n = fall_rocks(r,w,h,p,2022)

cr,nr = fall_rocks_iter(r,w,h,p)
#printcave(c)


