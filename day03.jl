using BenchmarkTools

function Base.unsafe_read(s::IO, p::Ref{T}, n::Integer) where {T}
    GC.@preserve p unsafe_read(s, Base.unsafe_convert(Ref{T}, p)::Ptr, n)
end

function calcPrio(file)
c_outer = open(file,"r") do f 
    c = Vector{Int}()
    io = IOBuffer()
    for line in eachline(f)
        print(io,line)
        sl = io.size
        a = BitSet(@view io.data[1:sl÷2])
        b = BitSet(@view io.data[sl÷2+1:sl])
        append!(c,intersect(a,b))
        ~ = take!(io)
    end
    return c
end
calcPrioVec(c_outer)
end

function calcBadgePrio(file)
c_outer = open(file,"r") do f 
    c = Vector{Int}()
    io1 = IOBuffer()
    io2 = IOBuffer()
    io3 = IOBuffer()
    while !eof(f)
        print(io1,readline(f))
        print(io2,readline(f))
        print(io3,readline(f))
        append!(c,intersect(BitSet(io1.data),BitSet(io2.data),BitSet(io3.data)))
        
        ~ = take!(io1)
        ~ = take!(io2)
        ~ = take!(io3)
    end
    return c
end
calcPrioVec(c_outer)
end

function calcPrioVec(v)
    return sum(v[v.<Int('a')].-Int('A').+27) + sum(v[v.>=Int('a')].-Int('a').+1)
end

@show calcPrio("day03_test.txt")
@show calcBadgePrio("day03_test.txt")
@show calcPrio("day03_input.txt")
@show calcBadgePrio("day03_input.txt")
@show calcPrio("day03_large_input.txt")
@show calcBadgePrio("day03_large_input.txt");

@btime calcPrio("day03_large_input.txt");
@btime calcBadgePrio("day03_large_input.txt");