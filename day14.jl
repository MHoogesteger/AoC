function proc_file(file,hasfloor)
    f = open(file)
    strings = Vector{Vector{Tuple}}()
    minx = 500
    miny = 0
    maxx = 500
    maxy = 0
    for line in eachline(f)
        string = split(line,(',',' '))
        xs = @view string[1:3:end]
        ys = @view string[2:3:end]
        iter = zip(parse.(Int,xs),parse.(Int,ys))
        for (x,y) in iter
            if x>maxx
                maxx = x
            end
            
            if x<minx
                minx = x
            end
            
            if y>maxy
                maxy = y
            end
            
            if y<miny
                miny = y
            end
        end
        push!(strings,collect(iter))
    end
    sx = maxx-minx+1
    sy = maxy-miny+1
    if hasfloor 
        sy+=2
        sx+=2*sy
        minx-=sy
    end
    M = fill('.',sx,sy)
    if hasfloor
        M[:,end].='F'
    end
    for string in strings
        for (from,to) in zip(string[1:end-1],string[2:end])
            xs = range(minimum([from[1],to[1]]),maximum([from[1],to[1]]))
            ys = range(minimum([from[2],to[2]]),maximum([from[2],to[2]]))
            M[xs.-minx.+1,ys.-miny.+1] .= '#'
        end
    end
    return permutedims(M),minx
end

function traverse_and_fill(M,source_col)
    M = permutedims(M)
    count = 0
    sx,sy = size(M)
    while true
        curx,cury = source_col,1
        settled = false
        while cury < sy && curx > 1 && curx < sx
            if M[curx,cury+1]=='.'
                cury +=1
            elseif M[curx-1,cury+1]=='.'
                cury +=1
                curx -=1
            elseif M[curx+1,cury+1]=='.'
                cury +=1
                curx +=1
            else
                settled=true
                M[curx,cury]='o'
                break
            end
        end
        if settled 
            count+=1
            if curx==source_col && cury==1
                break
            end
        else
            break
        end
    end
    return permutedims(M),count
end

file = "day14_input.txt"
Mn,mxn = proc_file(file,false)
Mfn,cn = traverse_and_fill(Mn,500-mxn+1)

Mf,mxf = proc_file(file,true)
Mff,cf = traverse_and_fill(Mf,500-mxf+1)

