function proc_file(file)
    f = open(file)
    pairs = Vector{Union{Bool,Nothing}}()
    pair = 1
    while true
        line1 = eval(Meta.parse(readline(f)))
        line2 = eval(Meta.parse(readline(f)))
        push!(pairs,compare(line1,line2))
        pair +=1

        if eof(f)
            break
        end
        readline(f)
    end
    return pairs
end

function compare(v1,v2)
    if v1 isa Vector && v2 isa Vector
        b1 = isempty(v1)
        b2 = isempty(v2)
        if b1 && !b2
            return true
        elseif !b1 && b2
            return false
        elseif b1 && b2
            return nothing
        else
            b = compare(popfirst!(v1),popfirst!(v2))
            if isnothing(b)
                return compare(v1,v2)
            end
            return b
        end
    elseif isa(v1,Vector) && !isa(v2,Vector)
        return compare(v1,[v2])
    elseif !isa(v1,Vector) && isa(v2,Vector)
        return compare([v1],v2)
    else
        if v1<v2
            return true
        elseif v1>v2
            return false
        else
            return nothing
        end
    end
end

function proc_file_two(file)
    f = open(file)
    count_1 = 1
    count_2 = 2
    while true
        e1 = Meta.parse(readline(f))
        e2 = Meta.parse(readline(f))
        if compare(eval(e1),[[2]])==true
            count_1 +=1
        end
        if compare(eval(e2),[[2]])==true
            count_1 +=1
        end
        if compare(eval(e1),[[6]])==true
            count_2 +=1
        end
        if compare(eval(e2),[[6]])==true
            count_2 +=1
        end
        if eof(f)
            break
        end
        readline(f)
    end
    return count_1*count_2
end

file = "day13_input.txt"
a = proc_file(file)
@show sum(findall(a))



@show proc_file_two(file)
