
function process_line!(M,line,rownumber)
    colnumber = 1
    for c in line
        M[rownumber,colnumber] = parse(Int,c)
        colnumber +=1
    end
end

function get_visibility_matrix(M)
    V = Matrix{Bool}(undef,size(M))
    l = size(M,1)
    for (ind,val) in pairs(M)
        (i,j) = Tuple(ind)
        v = false
        if i == 1 || i == l || j == 1 || j == l
            v = true
        else
            if reduce(max,(M[1:i-1,j]);init=0)<val
                v = true
            elseif reduce(max,(M[i+1:end,j]);init=0)<val
                v = true
            elseif reduce(max,(M[i,1:j-1]);init=0)<val
                v = true
            elseif reduce(max,(M[i,j+1:end]);init=0)<val
                v = true
            end
        end

        V[ind] = v
    end
    return V
end

function get_scenic_score_matrix(M)
    S = Matrix{Int}(undef,size(M))
    l = size(M,1)
    for (ind,val) in pairs(M)
        (i,j) = Tuple(ind)
        s = 0
        if !(i == 1 || i == l || j == 1 || j == l)
            ind_in = 1
            while (i-ind_in) != 1 && M[i-ind_in,j]<val
                ind_in+=1
            end
            ind_ip = 1
            while (i+ind_ip) != l && M[i+ind_ip,j]<val
                ind_ip+=1
            end
            ind_jn = 1
            while (j-ind_jn) != 1 && M[i,j-ind_jn]<val
                ind_jn+=1
            end
            ind_jp = 1
            while (j+ind_jp) != l && M[i,j+ind_jp]<val
                ind_jp+=1
            end
            s = ind_in*ind_ip*ind_jn*ind_jp
        end
        S[ind] = s
    end
    return S
end


file = "day08_input.txt"
function proc_file(file)
    f = open(file)

    line = readline(f)
    l = length(line)
    M = Matrix{Int32}(undef,l,l)

    rownumber = 1
    process_line!(M,line,rownumber)
    for line in eachline(f)
        rownumber += 1
        process_line!(M,line,rownumber)
    end
    return M
end
M = proc_file(file)
V = get_visibility_matrix(M)
println("Number of visible trees: $(count(V))")

S = get_scenic_score_matrix(M)
println("Maximum scenic score: $(maximum(S))")










