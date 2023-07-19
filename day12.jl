function proc_file(file)
    f = open(file)
    grid_fac = Vector{Vector{Int}}()
    io = IOBuffer()
    for line in eachline(f)
        print(io,line)
        push!(grid_fac,parse_line(io))
        take!(io)
    end

    grid = transpose(hcat(grid_fac...))

    sidx = findall(grid.==-13)[1]
    eidx = findall(grid.==-27)[1]
    grid[sidx] = 1
    grid[eidx] = 26
    
    

    return (grid,sidx,eidx)
end

function parse_line(io)
    return io.data[1:io.size].-Int('a').+1
end


function dijkstra_grid(grid,sidx,eidx)
    cost = fill(-1,size(grid))
    visited = fill(false,size(grid))
    path = fill(CartesianIndex(0,0),size(grid))
    cost[sidx] = 0
    open_neighbours = Vector{CartesianIndex{2}}()
    push!(open_neighbours,sidx)
    iters = 0
    f(x) = cost[x]
    g(x) = f(x) + sqrt(abs((x-eidx)[1])^2 + abs((x-eidx)[2])^2)
    while true

        sort!(open_neighbours,by=g)
        if length(open_neighbours)==0
            break
        end

        curn = popfirst!(open_neighbours)
        if curn == eidx
            break
        end

        iters +=1

        ns = get_reachable_neighbours(grid,curn)
        curcost = cost[curn]+1
        for n in ns
            if visited[n] == false && (cost[n]==-1 || cost[n]>curcost) && grid[n]<=(grid[curn]+1)
                cost[n] = curcost
                path[n] = curn
                push!(open_neighbours,n)
            end
        end
        visited[curn] = true
    end
    println("Iterations $(iters)")

    return cost,visited,path
end

function dijkstra_grid_reverse(grid,eidx)
    cost = fill(-1,size(grid))
    visited = fill(false,size(grid))
    path = fill(CartesianIndex(0,0),size(grid))
    cost[eidx] = 0
    open_neighbours = Vector{CartesianIndex{2}}()
    push!(open_neighbours,eidx)
    iters = 0
    f(x) = cost[x]
    endpoint = eidx
    while true

        sort!(open_neighbours,by=f)
        if length(open_neighbours)==0
            break
        end

        curn = popfirst!(open_neighbours)
        if grid[curn] == 1
            endpoint = curn
            break
        end

        iters +=1

        ns = get_reachable_neighbours(grid,curn)
        curcost = cost[curn]+1
        for n in ns
            if visited[n] == false && (cost[n]==-1 || cost[n]>curcost) && grid[curn]<=(grid[n]+1)
                cost[n] = curcost
                path[n] = curn
                push!(open_neighbours,n)
            end
        end
        visited[curn] = true
    end
    println("Iterations $(iters)")

    return cost,visited,path,endpoint
end


function get_reachable_neighbours(grid,idx)
    n = Vector{CartesianIndex{2}}()
    if idx[1] != 1
        push!(n,idx-CartesianIndex(1,0))
    end
    if idx[1] != size(grid,1)
        push!(n,idx+CartesianIndex(1,0))
    end
    if idx[2] != 1
        push!(n,idx-CartesianIndex(0,1))
    end
    if idx[2] != size(grid,2)
        push!(n,idx+CartesianIndex(0,1))
    end
    return n
end

function disp_grid(grid,cost,visited,path,sidx,eidx)
    d = fill('.',size(grid))
    d[sidx] = 'S'
    d[eidx] = 'E'
    cidx = eidx
    count = 0
    while cidx != sidx
        nidx = path[cidx]
        didx = nidx-cidx
        if didx[1]==-1
            d[nidx]='V'
        end
        if didx[1]==1
            d[nidx]='^'
        end
        if didx[2]==-1
            d[nidx]='>'
        end
        if didx[2]==1
            d[nidx]='<'
        end
        cidx = nidx
        count+=1
    end
    display(d)
    return count
end

file = "day12_input.txt"
(grid,sidx,eidx) = proc_file(file)
cost,visited,path = dijkstra_grid(grid,sidx,eidx)
@show c = disp_grid(grid,cost,visited,path,sidx,eidx)

(grid,sidx,eidx) = proc_file(file)
cost,visited,path,endpoint = dijkstra_grid_reverse(grid,eidx)
@show c = disp_grid(grid,cost,visited,path,eidx,endpoint)



