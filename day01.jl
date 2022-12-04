using BenchmarkTools
using DelimitedFiles
using CSV
function calcmaxelf_naive(file)
    m = 0
    open(file,"r") do f
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
        cur = 0
        for line in eachline(f)
            if isempty(line)
                if cur> m
                    m = cur
                    cur = 0
                end
            else
                cur += parse(Int,line)
            end
        end
        m
    end
    return m
end

function calcmaxelf_mmap(file)
    m_outer = open(file,"r") do f
        m = 0
        v = mmap(f,Vector{UInt8})
        lb = findall(<(0x30),v)
        
        if (lb[2]-lb[1])==1
            lbr = true
            lbf = @view lb[1:2:end]
        else
            lbr = false
            lbf = lb
        end
        lbfa = @view lbf[1:end-1]
        lbfb = @view lbf[2:end]
        lbfid = findall(iszero,lbfb.-lbfa.-1 .-lbr)
        previd = 1
        st = 1
        for id in lbfid
            lbids = lbf[previd:id]
            cur = 0
            for lid in lbids
                cur += quickparse(v[st:lid-lbr])
                st = lid+1+lbr
            end
            if m<cur
                m=cur
            end
            st += (1+lbr)
            
            previd = id+2
        end
        return m
    end
    return m_outer
end

function calcmaxelf_eachline_iobuf(file)
    m = 0
    open(file,"r") do f
        io = IOBuffer()
        cur = 0
        for line in eachline(f)
            print(io,line)
            if io.size==0
                if cur > m
                    m = cur
                    cur = 0
                end
            else
                cur += quickparse3(io)
            end
            ~ = take!(io)
        end
        m
    end
    return m
end

function quickparse(io::IOBuffer)
    val = 0
    ind = 1
    s = Int('0');
    while ind<=io.size
        val = val*10 + io.data[ind]-s
        ind +=1
    end
    return val
end

function quickparse3(io::IOBuffer)
    return quickparse(io.data,io.size)
end

function quickparse(v::Vector{UInt8})
    val = 0
    s = Int('0');
    for k in v
        val = val*10 + k-s
    end
    return val
end

function quickparse(v::Vector{UInt8},size::Int)
    val = 0
    s = Int('0');
    for k in @view v[1:size]
        val = val*10 + k-s
    end
    return val
end

function quickparse2(io::IOBuffer)
    val = 0
    s = Int('0');
    for (ind,num) in enumerate(Iterators.dropwhile(==(0),reverse(io.data)))
        val += (num-s)*10^(ind-1)
    end
    return val
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
# println("Inputdata maximum: $(calcmaxelf_blob("day01_input.txt"))")
# # # println("Largedata maximum: $(calcmaxelf_blob("day01_large_input.txt"))")
# # println()
# # println("DC results:")
# # println("Testdata maximum: $(calcmaxelf_dc("day01_test.txt"))")
# println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# # # println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
println()
println("Eachline results:")
println("Testdata maximum: $(calcmaxelf_eachline("day01_test.txt"))")
println("Inputdata maximum: $(calcmaxelf_eachline("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_eachline("day01_large_input.txt"))")
println()
println("Eachline + IOBuffer results:")
println("Testdata maximum: $(calcmaxelf_eachline_iobuf("day01_test.txt"))")
println("Inputdata maximum: $(calcmaxelf_eachline_iobuf("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_eachline_iobuf("day01_large_input.txt"))")
println()
println("Mmap results:")
println("Testdata maximum: $(calcmaxelf_mmap("day01_test.txt"))")
println("Inputdata maximum: $(calcmaxelf_mmap("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_eachline_iobuf("day01_large_input.txt"))")
# # println()
# # println("Readlines results:")
# # println("Testdata maximum: $(calcmaxelf_readlines("day01_test.txt"))")
# # println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# # println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
# println()
# println("CSV results:")
# println("Testdata maximum: $(calcmaxelf_csv("day01_test.txt"))")
# # println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# # println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
# println()
# println("DLM results:")
# println("Testdata maximum: $(calcmaxelf_dlm("day01_test.txt"))")
# # println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# # println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")
# println()
# println("DLM2 results:")
# println("Testdata maximum: $(calcmaxelf_dlm2("day01_test.txt"))")
# println("Inputdata maximum: $(calcmaxelf_dc("day01_input.txt"))")
# println("Largedata maximum: $(calcmaxelf_dc("day01_large_input.txt"))")

@btime calcmaxelf_naive("day01_test.txt")
# @btime calcmaxelf_blob("day01_test.txt")
# @btime calcmaxelf_dc("day01_test.txt")
@btime calcmaxelf_eachline("day01_test.txt")
@btime calcmaxelf_eachline_iobuf("day01_test.txt")
@btime calcmaxelf_mmap("day01_test.txt")
# @btime calcmaxelf_readlines("day01_test.txt")
# @btime calcmaxelf_csv("day01_test.txt")
# @btime calcmaxelf_dlm("day01_test.txt")
# @btime calcmaxelf_dlm2("day01_test.txt")
# println()
@btime calcmaxelf_naive("day01_input.txt")
# @btime calcmaxelf_blob("day01_input.txt")
# @btime calcmaxelf_dc("day01_input.txt")
@btime calcmaxelf_eachline("day01_input.txt")
@btime calcmaxelf_eachline_iobuf("day01_input.txt")
@btime calcmaxelf_mmap("day01_input.txt")
# @btime calcmaxelf_readlines("day01_input.txt")
# @btime calcmaxelf_csv("day01_input.txt")
# @btime calcmaxelf_dlm("day01_input.txt")
# @btime calcmaxelf_dlm2("day01_input.txt")
# println()
# @btime calcmaxelf_naive("day01_large_input.txt")
# # @btime calcmaxelf_blob("day01_large_input.txt")
# # @btime calcmaxelf_dc("day01_large_input.txt")
# @btime calcmaxelf_eachline("day01_large_input.txt")
# @btime calcmaxelf_eachline_iobuf("day01_large_input.txt")
# @btime calcmaxelf_readlines("day01_large_input.txt")
# @btime calcmaxelf_csv("day01_large_input.txt")
# @btime calcmaxelf_dlm("day01_large_input.txt")
# @btime calcmaxelf_dlm2("day01_large_input.txt")
