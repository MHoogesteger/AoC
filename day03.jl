using BenchmarkTools
file = "day03_large_input.txt"

function calcPrio(file)
f = open(file,"r")
c = Vector{Char}()

while !eof(f)
    s = readline(f)
    sl = length(s)
    a = unique(SubString(s,1,sl÷2))
    b = unique(SubString(s,sl÷2+1,sl))
    ind = findall(x->x in b, a)
    push!(c,a[ind][end])
end

close(f)
calcPrioVec(c)
end

function calcBadgePrio(file)
f = open(file,"r")
c = Vector{Char}()
while !eof(f)
    s1 = unique(readline(f))
    s2 = unique(readline(f))
    s3 = unique(readline(f))
    sl = length(s1)
    ind = findall(x->x in s2 && x in s3, s1)
    push!(c,s1[ind][end])
end

close(f)
calcPrioVec(c)
end

function calcPrioVec(c)
    v = c.-'a'.+1

nv = v[v.<0].+'a'.-'A'.+26
pv = v[v.>0]

sum(nv)+sum(pv)
end

@show calcPrio("day03_test.txt")
@show calcBadgePrio("day03_test.txt")
@show calcPrio("day03_input.txt")
@show calcBadgePrio("day03_input.txt")
@show calcPrio("day03_large_input.txt")
@show calcBadgePrio("day03_large_input.txt");

@btime calcPrio("day03_large_input.txt");
@btime calcBadgePrio("day03_large_input.txt");