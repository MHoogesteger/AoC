using Graphs
using GLMakie, GraphMakie
using GraphMakie.NetworkLayout
using Bijections
using SimpleWeightedGraphs

function proc_file(file)
    nodes = Bijection{String,Int}()
    tunnels = Vector{Vector{SubString{String}}}()
    flows = Vector{Int64}()
    g = SimpleGraph()
    # add_vertex!(g)
    # add_vertex!(g)
    # add_edge!(g,1,2)
    # add_edge!(g,1,1)
    f = open(file)
    iter = 0
    for line in eachline(f)
        iter+=1
        s = split(line,('=',',',':',' ',';'))
        name = s[2]
        flow = parse(Int,s[6])
        tunnel = s[12:2:end]
        nodes[name] = iter
        push!(tunnels,tunnel)
        push!(flows,flow)
        add_vertex!(g)
        add_edge!(g,iter,iter)
    end
    for node in 1:iter
        for tunnel in tunnels[node]
            add_edge!(g,node,nodes[tunnel])
        end
    end
    close(f)
    return g, nodes,tunnels, flows
end

function cleangraph(nodes,flows,FWdists)
    newnodes = Bijection{String,Int}()
    newflows = Vector{Int64}() 
    g = SimpleWeightedGraph()
    
    iter = 0
    s = findall(flows.!=0)
    push!(s,nodes["AA"])
    sort!(s,by = x-> flows[x],rev=true)

    for idx in s
        iter+=1
        newnodes[nodes(idx)] = iter
        push!(newflows,flows[idx])
        add_vertex!(g)
        for idx_i in 1: iter-1
            add_edge!(g,iter,idx_i,FWdists.dists[s[iter],s[idx_i]])
        end
    end
    return  g, newnodes, newflows,s
end

function travel(g,flows,nodes,n_nodes,maxtime=30,start_node="AA")
    start_node = nodes[start_node]
    visited = fill(false,n_nodes)
    visited[start_node] = true
    return  travel_and_open(g,start_node,0,flows,0,maxtime,visited)

end
function travel_and_open(g,node,flow,flows,time,maxtime,visited)
    new_visited = deepcopy(visited)
    new_visited[node] = true

    new_flow = flow+flows[node]*(maxtime-time)
    
    if all(new_visited)
        return new_flow,nothing
    end
    nvec = intersect(neighbors(g,node),findall(new_visited.==false))
    fvec = fill(new_flow,length(nvec))
    tvec = fill(0,length(nvec))
    for idx in eachindex(nvec)
        node_time = time+Int(get_weight(g,node,nvec[idx])) + 1
        if node_time<maxtime
            fvec[idx],_ = travel_and_open(g,nvec[idx],new_flow,flows,node_time,maxtime,new_visited)
            tvec[idx] = node_time
        end
    end
    best_flow,best_idx = findmax(fvec)
    return best_flow,nvec[best_idx],tvec[best_idx]
end

function travel_and_store_recursively(g,flows,nodes,n_nodes,maxtime=30,start_node="AA")
    start_node = nodes[start_node]
    visited = fill(false,n_nodes)
    path = Vector{Tuple{Int,Int,Int}}()
    visited[start_node] = true
    time = 0
    flow = 0
    push!(path,(start_node,time,flow))
    while !all(visited) && time < maxtime
        next_flow,next_node,next_time = travel_and_open(g,start_node,0,flows,time,maxtime,visited)
        visited[next_node] = true
        if next_time==0
            break
        end
        time =next_time
        start_node = next_node
        push!(path,(next_node,next_time,next_flow))
    end
    return path
end


function travel_with_elephant(g,flows,nodes,n_nodes,maxtime=26,start_node="AA";kwargs...)
    start_node = nodes[start_node]
    open_nodes = BitSet(1:n_nodes)
    # println(kwargs)
    # pop!(open_nodes,start_node)
    return  travel_with_elephant_and_open(g,start_node,start_node,0,0,flows,0,0,maxtime,open_nodes,false,0,1;kwargs...)

end

function travel_with_elephant_and_open(g,node,elnode,flow,flow_el,flows,time,eltime,maxtime,open_nodes,travel_el,best_flow,iter;cutoff=true)
    if travel_el
        pop!(open_nodes,elnode)
    else
        pop!(open_nodes,node)
    end
    new_flow = flow
    new_flow_el = flow_el

    if travel_el
        new_flow_el += flows[elnode]*(maxtime-eltime)
    else
        new_flow += flows[node]*(maxtime-time)
    end

    new_tot_flow = new_flow+new_flow_el

    if isempty(open_nodes)
        if travel_el
            push!(open_nodes,elnode)
        else
            push!(open_nodes,node)
        end
        return new_tot_flow,nothing
    end
    if cutoff
        # max_possible_flow = sum(flows[collect(open_nodes)])*(maxtime-min(eltime,time)+1)
        max_possible_flow = mapreduce(x->flows[x],+,open_nodes)*(maxtime-min(eltime,time)+1)
        # max_possible_flow = reduce(+,getindex.(Ref(flows),open_nodes))*(maxtime-min(eltime,time)+1)
        if new_tot_flow + max_possible_flow < best_flow
            # println("Cutting short $new_tot_flow  $max_possible_flow  $best_flow")
            
            if travel_el
                push!(open_nodes,elnode)
            else
                push!(open_nodes,node)
            end
            return 0,nothing
        end
    end
    bestflow = new_tot_flow
    tmax = time
    tmax_el = eltime
    ntargetmax = node
    ntargetmax_el = elnode

    for ntarget in open_nodes
        node_time = time + Int(get_weight(g,node,ntarget)) + 1
        node_time_el = eltime + Int(get_weight(g,elnode,ntarget)) + 1
        if node_time<=node_time_el
            if node_time<maxtime
                cflow,_ = travel_with_elephant_and_open(g,ntarget,elnode,new_flow,new_flow_el,flows,node_time,eltime,maxtime,open_nodes,false,bestflow,iter+1;cutoff)
                if cflow>bestflow
                    bestflow = cflow
                    tmax = node_time
                    ntargetmax = ntarget
                    tmax_el = eltime
                    ntargetmax_el = elnode
                end
            end
        else
            if node_time_el<maxtime
                cflow,_ = travel_with_elephant_and_open(g,node,ntarget,new_flow,new_flow_el,flows,time,node_time_el,maxtime,open_nodes,true,bestflow,iter+1;cutoff)
                if cflow>bestflow
                    bestflow = cflow
                    tmax = time
                    ntargetmax = node
                    tmax_el = node_time_el
                    ntargetmax_el = ntarget
                end
            end
        end
    end
    if iter==2
        println("Outer loop iter")
    end
    if travel_el
        push!(open_nodes,elnode)
    else
        push!(open_nodes,node)
    end
    return bestflow,ntargetmax,ntargetmax_el,tmax,tmax_el
end


function travel_with_elephant_and_store_recursively(g,flows,nodes,n_nodes,maxtime=26,start_node="AA")
    start_node = nodes[start_node]
    start_node_el = start_node
    open_nodes = BitSet(1:n_nodes)
    path = Vector{Tuple{Int,Int,Int,Int,Int}}()
    time = 0
    time_el = 0
    flow = 0
    push!(path,(start_node,start_node_el,time,time_el,flow))
    iter = 0
    travel_el=false
    while !isempty(open_nodes) && time < maxtime && time_el < maxtime
        iter+=1
        copy_open =deepcopy(open_nodes)
        if start_node in open_nodes
            pop!(open_nodes,start_node)
        end
        if start_node_el in open_nodes
            pop!(open_nodes,start_node_el)
        end
        next_flow,k... = travel_with_elephant_and_open(g,start_node,start_node_el,0,0,flows,time,time_el,maxtime,deepcopy(copy_open),travel_el,0,iter)
        if !isnothing(k[1])
            (next_node,next_node_el,next_time,next_time_el) = k
        else
            break
        end
        if next_node == start_node
            travel_el=true
        else
            travel_el=false
        end
        if next_node == start_node && next_node_el == start_node_el
            break
        end

        time =next_time
        time_el =next_time_el
        start_node = next_node
        start_node_el = next_node_el
        push!(path,(next_node,next_node_el,next_time,next_time_el,next_flow))
    end
    return path,open_nodes

end

file = "day16_input.txt"
g, nodes,tunnels, flows = proc_file(file)
h = graphplot(g,nlabels=sprint.(show,flows[1:nv(g)]); layout=Stress(dim=2))
GLMakie.activate!()
display(GLMakie.Screen(),h)
 
FWdists = floyd_warshall_shortest_paths(g)

gnew, newnodes, newflows,s = cleangraph(nodes,flows,FWdists)

f = graphplot(gnew,nlabels=sprint.(show,newflows[1:nv(gnew)]); layout=Spring(dim=3))
display(GLMakie.Screen(),f)

bf = travel(gnew,newflows,newnodes,length(newnodes))
display(bf)
pf = travel_and_store_recursively(gnew,newflows,newnodes,length(newnodes))
nf = map(x->newnodes(x[1]),pf)
ff = map(x->newflows[x[1]],pf)
display(pf)
ebf = travel_with_elephant(gnew,newflows,newnodes,length(newnodes))
display(ebf)
epf,ev = travel_with_elephant_and_store_recursively(gnew,newflows,newnodes,length(newnodes))
enf = map(x->(newnodes(x[1]),newnodes(x[2])),epf)
eff = map(x->newflows[x[1]],epf)
display(epf)
# using BenchmarkTools
# @btime travel_with_elephant(gnew,newflows,newnodes,length(newnodes))