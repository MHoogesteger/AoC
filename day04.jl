using BenchmarkTools

function calcPairContains(file)
f = open(file,"r")
    c = 0
    v = Vector{Int}()
    for line in eachline(f)
        v = parse.(Int,split(line,[',','-']))
        if (v[1]>=v[3] && v[2]<=v[4]) || (v[1]<=v[3] && v[2]>=v[4])
            c+=1
        end
    end
close(f)
return c
end

function calcPairOverlap(file)
    f = open(file,"r")
        c = 0
        v = Vector{Int}()
        for line in eachline(f)
            v = parse.(Int,split(line,[',','-']))
            if (v[1]<=v[4] && v[2]>=v[3])
                c+=1
            end
        end
    close(f)
    return c
    end

@show calcPairContains("day04_test.txt")
@show calcPairContains("day04_input.txt")

@show calcPairOverlap("day04_test.txt")
@show calcPairOverlap("day04_input.txt")
# @show calcBadgePrio("day04_test.txt")
# @show calcPrio("day03_input.txt")
# @show calcBadgePrio("day03_input.txt")
@btime calcPairContains("day04_test.txt");
@btime calcPairContains("day04_input.txt");

@btime calcPairOverlap("day04_test.txt");
@btime calcPairOverlap("day04_input.txt");
# @btime calcBadgePrio("day03_large_input.txt");