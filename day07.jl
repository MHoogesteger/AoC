
using BenchmarkTools
mutable struct Directory
    name::String
    size::Int64
    children::Dict{String,Directory}
    parent::Union{Directory,Nothing}
    Directory(name,parent) = new(name,0,Dict{String,Directory}(),parent)
end

allDirs = Dict{String,Directory}()

function addDir(parent,name,allDirs)
    d = Directory(name,parent)
    parent.children[name] = d
    while haskey(allDirs,name)
        name = "_$(name)"
    end
    allDirs[name] = d
end

function addFile(parent,size)
    while true
        parent.size += size
        if parent.name == "/"
            break
        end
        parent = parent.parent
    end
end

function process_line(line,curdir,td,allDirs)
    newdir = curdir
    if line[1]=='$'
        if line[1:4]== "\$ cd"
            # change Directory
            if line[6:end]== ".."
                newdir = curdir.parent
            elseif line[6:end]== "/"
                newdir = td
            else
                newdir = curdir.children[line[6:end]]
            end
        elseif line[1:4]== "\$ ls"
        # goto Dir mode = do nothing
        end
    elseif line[1:3]== "dir"
        addDir(curdir, line[5:end],allDirs)
    else
        v = split(line)
        s = parse(Int,v[1])
        n = v[2]
        addFile(curdir,s)
    end
    return newdir
end

function process_line_buf(io,curdir,td,allDirs)
    newdir = curdir
    if io.data[1]==UInt8('$')
        if io.data[3]== UInt8('c')
            # change Directory
            if io.size==7 && io.data[6] == UInt8('.') && io.data[7] == UInt8('.')
                newdir = curdir.parent
            elseif io.data[6]== UInt8('/')
                newdir = td
            else
                newdir = curdir.children[String(take!(io))[6:end]]
            end
        elseif io.data[3]== UInt8('l')
        # goto Dir mode = do nothing
        end
    elseif io.data[1]==UInt8('d')
        addDir(curdir, String(take!(io))[5:end],allDirs)
    else
        v = split(String(take!(io)))
        s = parse(Int,v[1])
        addFile(curdir,s)
    end
    take!(io)
    return newdir
end



function getSize(dir)
    size = 0
    for (_,child) in dir.children
        if child isa Directory
            c_size = getSize(child)
        else
            c_size = child.size
        end
        size += c_size
    end
    return size
end

function getSizeNonRecur(dir)
    return dir.size
end

function getCumSize(dir)
    size = 0
    for (_,child) in dir.children
        if child isa Directory
            c_size = getSizeNonRecur(child)
            if c_size < 100000
                size += c_size
            end
            size += getCumSize(child)
        end
    end
    return size
end

function getCumSizeNonRecur(allDirs)
    cumsize = 0
    for (_,dir) in allDirs
        if dir.size < 100000
            cumsize += dir.size
        end
    end
    return cumsize
end

function getMinSizeDir(dir,req_size,cur_best_size)
    for (_,child) in dir.children
        if child isa Directory
            c_size = getSizeNonRecur(child)
            if c_size > req_size
                if c_size < cur_best_size
                    dir = child
                    cur_best_size = c_size
                end
                dir, cur_best_size = getMinSizeDir(child,req_size,cur_best_size)
            end
        end
    end
    return dir, cur_best_size
end

function getMinSizeDirNonRecur(req_size,allDirs)
    minsize = req_size*10
    name = ""
    for (_,dir) in allDirs
        if dir.size > req_size && dir.size < minsize
            minsize = dir.size
            name = dir.name
        end
    end
    return name, minsize
end


function doParts(file)
    iostream = open(file)
    io = IOBuffer()
    td = Directory("/",nothing)
    allDirs["/"] = td
    curdir = td

    for line = eachline(iostream)
        curdir = process_line(line,curdir,td,allDirs)
    end
    used_space = getSizeNonRecur(td)
    # println("Top-level size is: $(used_space)")
    tot_space = getCumSizeNonRecur(allDirs)
    # println("CumTotal size is: $(tot_space)")
    needed_space = 30000000 - ( 70000000 - used_space)
    # println("Needed size is: $(needed_space)")
    del_name, del_size = getMinSizeDirNonRecur(needed_space,allDirs)
    # println("Delete dir $del_name has size: $(del_size)")
    
    close(iostream)
    return used_space,tot_space,needed_space,del_name,del_size
end

function doPartsBuf(file)
    iostream = open(file)
    io = IOBuffer()
    td = Directory("/",nothing)
    allDirs["/"] = td
    curdir = td
    for line = eachline(iostream)
        print(io,line)
        curdir = process_line_buf(io,curdir,td,allDirs)
    end
    used_space = getSizeNonRecur(td)
    # println("Top-level size is: $(used_space)")
    tot_space = getCumSizeNonRecur(allDirs)
    # println("CumTotal size is: $(tot_space)")
    needed_space = 30000000 - ( 70000000 - used_space)
    # println("Needed size is: $(needed_space)")
    del_name, del_size = getMinSizeDirNonRecur(needed_space,allDirs)
    # println("Delete dir has size: $(del_size)")
    
    close(iostream)
    return used_space,tot_space,needed_space,del_name,del_size
end


file = "day07_deep.txt"
@show doParts(file)
@show doPartsBuf(file)








