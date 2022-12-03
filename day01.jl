using BenchmarkTools
using DelimitedFiles
using CSV
function calcmaxelf_naive(file)
    m = 0
    open(file,"r") do f
        line = 0
        cur = 0
        while !eof(f)
            s = replace(readline(f)," " => "")
            line =+ 1
            if isempty(s)
                if cur> m
                    m = cur
                    cur = 0
                end
            else
                cur += parse(Int64,s)
            end
        end
        m
    end
    return m
end

function calcmaxelf_blob(file)
    m = 0
    s = ""
    open(file,"r") do f
        s = replace(read(f,String), "\r" => "", " " => "")
    end
    sp = split(s,"\n\n")
    c = 0
    for spl in sp
        a = sum([parse(Int64,c) for c in split(spl,"\n"; keepempty=false)])
        if a>c
            c=a
        end
    end
    return c
end

function calcmaxelf_dc(file)
    m = 0
    s = ""
    open(file,"r") do f
        s = replace(read(f,String), "\r" => "", " " => "")
    end
    maximum([sum([parse(Int64,c) for c in split(spl,"\n"; keepempty=false)]) for spl in split(s,"\n\n")])
end

function calcmaxelf_dc_t3(file)
    m = 0
    s = ""
    open(file,"r") do f
        s = replace(read(f,String), "\r" => "", " " => "")
    end
    a = sort([sum([parse(Int64,c) for c in split(spl,"\n"; keepempty=false)]) for spl in split(s,"\n\n")];order=Base.ReverseOrdering())
    sum(a[1:3])
end

function calcmaxelf_eachline(file)
    m = 0
    open(file,"r") do f
        line = 0
        cur = 0
        t = 0
        for line in eachline(f)
            if isempty(line)
                if cur> m
                    m = cur
                    cur = 0
                end
            else
                t = parse(Int,line)
                cur += t
            end
        end
        m
    end
    return m
end

function calcmaxelf_readlines(file)
    m = 0
    open(file,"r") do f
        s = readlines(f;keep=false)
        if s[end]!=""
            append!(s,[""])
        end
        inds = vcat(0,findall(==(""),s))
        sk = view.(Ref(s), (:).(inds[1:end-1].+1,inds[2:end].-1))
        a = 0
        for n in eachindex(sk)
            a = sum(parse.(Int,sk[n]))
            if a>m
                m=a
            end
        end
    end
    return m
end

function calcmaxelf_csv(file)
    m = 0
    cur = 0
    open(file,"r") do f
        s = CSV.File(f;header=false,types=Int,ignoreemptyrows=false,select=[1])
        for c in s.Column1
            if ismissing(c)
                if cur> m
                    m = cur
                    cur = 0
                end
            else
                cur += c
            end
        end
    end

    return m
end

function calcmaxelf_dlm(file)
    m = 0
    cur = 0
    open(file,"r") do f
        s = replace(read(f,String), "\r" => "", " " => "")
        sl = readdlm.(IOBuffer.(split(strip(s),"\n\n")),Int32)
        for c in sl
            cur = sum(c)
            if cur> m
                m = cur
            end
        end
    end

    return m
end

function calcmaxelf_dlm2(file)
    m = 0
    cur = 0
    open(file,"r") do f
        s = replace(read(f,String), "\r" => "", " " => "")
        sl = readdlm.(IOBuffer.(split(strip(s),"\n\n")),Int32)
        m=maximum(sum.(sl))
    end

    return m
end

println(calcmaxelf_dc_t3("day01_input.txt"))

println("Naive results:")
println("Testdata maximum: $(calcmaxelf_naive("day01_test.txt"))")
println("Inputdata maximum: $(calcmaxelf_naive("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_naive("day01_large_input.txt"))")
# println()
# println("Blob results:")
# println("Testdata maximum: $(calcmaxelf_blob("day01_test.txt"))")
println("Inputdata maximum: $(calcmaxelf_blob("day01_input.txt"))")
# # println("Largedata maximum: $(calcmaxelf_blob("day01_large_input.txt"))")
# println()
# println("DC results:")
# println("Testdata maximum: $(calcmaxelf_dc("day01_test.txt"))")
println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# # println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
# println()
# println("Eachline results:")
# println("Testdata maximum: $(calcmaxelf_eachline("day01_test.txt"))")
# println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
# println()
# println("Readlines results:")
# println("Testdata maximum: $(calcmaxelf_readlines("day01_test.txt"))")
# println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
println()
println("CSV results:")
println("Testdata maximum: $(calcmaxelf_csv("day01_test.txt"))")
# println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
println()
println("DLM results:")
println("Testdata maximum: $(calcmaxelf_dlm("day01_test.txt"))")
# println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
println()
println("DLM2 results:")
println("Testdata maximum: $(calcmaxelf_dlm2("day01_test.txt"))")
# println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")

# @btime calcmaxelf_naive("day01_test.txt")
# @btime calcmaxelf_blob("day01_test.txt")
# @btime calcmaxelf_dc("day01_test.txt")
# @btime calcmaxelf_eachline("day01_test.txt")
# @btime calcmaxelf_readlines("day01_test.txt")
# @btime calcmaxelf_csv("day01_test.txt")
# @btime calcmaxelf_dlm("day01_test.txt")
# @btime calcmaxelf_dlm2("day01_test.txt")
# println()
# @btime calcmaxelf_naive("day01_input.txt")
# @btime calcmaxelf_blob("day01_input.txt")
# @btime calcmaxelf_dc("day01_input.txt")
# @btime calcmaxelf_eachline("day01_input.txt")
# @btime calcmaxelf_readlines("day01_input.txt")
# @btime calcmaxelf_csv("day01_input.txt")
# @btime calcmaxelf_dlm("day01_input.txt")
# @btime calcmaxelf_dlm2("day01_input.txt")
# println()
# @btime calcmaxelf_naive("day01_large_input.txt")
# @btime calcmaxelf_blob("day01_large_input.txt")
# @btime calcmaxelf_dc("day01_large_input.txt")
# @btime calcmaxelf_eachline("day01_large_input.txt")
# @btime calcmaxelf_readlines("day01_large_input.txt")
# @btime calcmaxelf_csv("day01_large_input.txt")
# @btime calcmaxelf_dlm("day01_large_input.txt")
# @btime calcmaxelf_dlm2("day01_large_input.txt")
