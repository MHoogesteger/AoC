function proc_file(file,row)
    f = open(file)
    sensors = Vector{Vector{Int}}()
    beacons = BitSet()
    temp = Vector{Int}(undef,5)
    for line in eachline(f)
        temp[[1,2,4,5]] .= parse.(Int,split(line,('=',',',':'))[[2,4,6,8]])
        temp[3] =abs(temp[4]-temp[1]) + abs(temp[5]-temp[2])
        println(temp[3])
        if temp[5]==row
            push!(beacons,temp[4])
        end
        if temp[3]>=abs(temp[2]-row)
            push!(sensors,temp[1:5])
        end
    end
return hcat(sensors...),beacons
end

function proc_file_two(file)
    f = open(file)
    sensors = Vector{Vector{Int}}()
    temp = Vector{Int}(undef,5)
    for line in eachline(f)
        temp[[1,2,4,5]] .= parse.(Int,split(line,('=',',',':'))[[2,4,6,8]])
        temp[3] =abs(temp[4]-temp[1]) + abs(temp[5]-temp[2])
        println(temp[3])
        push!(sensors,temp[1:5])
    end
return hcat(sensors...)
end

function check_row_occupied(sensors,row)
    temp = similar(@view sensors[1:3,:])
    temp[3,:] .= sensors[3,:] .- abs.(sensors[2,:].-row)
    temp[1,:] .= sensors[1,:] .- temp[3,:]
    temp[2,:] .= sensors[1,:] .+ temp[3,:]
    display(collect(zip(temp[1,:],temp[2,:])))
    occupied = BitSet(vcat(collect.([range(x...) for x in zip(temp[1,:],temp[2,:])])...))
    return temp,occupied
end
function check_row_occupied(sensors,row,minx,maxx)
    temp = similar(@view sensors[1:3,:])
    temp[3,:] .= sensors[3,:] .- abs.(sensors[2,:].-row)
    temp[1,:] .= sensors[1,:] .- temp[3,:]
    temp[2,:] .= sensors[1,:] .+ temp[3,:]
    # display(collect(zip(temp[1,:],temp[2,:])))
    occupied = BitSet(clamp.(vcat(collect.([range(x...) for x in zip(temp[1,:],temp[2,:])])...), minx,maxx))
    return temp,occupied
end

function check_part_two_bruteforce(sensors,minx,maxx)
    line = minx
    b = BitSet()
    for row in minx:maxx
        # println(row)
        _,b = check_row_occupied(sensors,row,minx,maxx)
        if length(b)<(maxx-minx+1)
            # println(b)
            line = row
            break
        end
        println("$row")
    end
    col = 0
    for x in minx:maxx
        if !in(x,b)
            col = x
            break
        end
    end
    return line,col,col*4000000+line
end

function check_part_two_smarter(sensors,minx,maxx)
    found = false
    ns = size(sensors,2)
    curx,cury = 0 , 0
    for idx in 1:ns
        sx,sy = sensors[1,idx],sensors[2,idx]
        topx,topy = sx,sy+sensors[3,idx]+1
        curx,cury = topx,topy
        iters = sensors[3,idx]*4
        iter = 1
        while true
            if curx >= minx && curx<=maxx && cury >=minx && cury <= maxx       
                for idx_i in 1:ns
                    dist = abs(curx-sensors[1,idx_i]) + abs(cury-sensors[2,idx_i])
                    if dist <=sensors[3,idx_i]
                        break
                    end
                    if idx_i == ns
                        found = true
                    end
                end

            end
            found && break
            iter +=1
            if curx>=sx && cury<sy
                curx+=1
                cury+=1
            elseif curx>sx && cury>=sy
                curx -=1
                cury +=1
            elseif curx<=sx && cury>sy
                curx -=1
                cury -=1
            elseif curx<sx && cury<=sy
                curx +=1
                cury -=1
            else
                error("Unexpected position.")
            end
            (curx!=topx || cury !=topy) || break
        end
        found && break
    end
    return found,curx,cury,curx*4000000+cury
end


file = "day15_input.txt"
row = 10
s,b = proc_file(file,row)
display(s)
t,o = check_row_occupied(s,row)
n_occ = length(o)-length(b)

s2 = proc_file_two(file)
# display(s2)
l = check_part_two_smarter(s2,0,4000000)
