struct Monkey
    id::Int
    items::Vector{Int64}
    operation::Char
    val::Int
    test
    target_true_id::Int
    target_false_id::Int
end

function proc_file(file)
    f = open(file)
    monkeys = Vector{Monkey}()
    while !eof(f)
        line = readline(f)
        id = parse(Int,line[8:end-1])

        line = readline(f)
        items = Vector{Int}()
        for n = 19:4:length(line)
            push!(items,parse(Int,line[n:n+1]))
        end

        
        line = readline(f)
        if line[24]=='*'
            if line[26]=='o'
                op = '^'
                val = 2
            else
                op = '*'
                val = parse(Int,line[26:end])
            end
        else
            op = '+'
            val = parse(Int,line[26:end])
        end

        line = readline(f)
        test = parse(Int,line[22:end])

        line = readline(f)
        target_true = parse(Int,line[30:end])

        line = readline(f)
        target_false = parse(Int,line[30:end])
        push!(monkeys,Monkey(id,items,op,val,test,target_true,target_false))
        line = readline(f)
    end
    close(f)
    return monkeys
end

function do_round(monkeys,counts,divby,modby)
    for monkey in monkeys
        counts[monkey.id+1] += length(monkey.items)
        while length(monkey.items) != 0
            item = popfirst!(monkey.items)
            #increase item
            if monkey.operation == '^'
                item = item ^ monkey.val
            elseif monkey.operation == '*'
                item = item * monkey.val
            elseif monkey.operation == '+'
                item = item + monkey.val
            else
                error("Unexpected operation")
            end

            # Decrease item
            item = item ÷ divby
            if modby!=0
                item = item % modby
            end

            # Test item
            if (item % monkey.test) == 0
                throw_target = monkey.target_true_id+1
            else
                throw_target = monkey.target_false_id+1
            end
            # Throw item
            push!(monkeys[throw_target].items,item)
        end
    end
    return monkeys,counts
end

function do_rounds(monkeys,rounds,divby,modby)
    counts = fill(0,size(monkeys))
    for round in 1:rounds
        do_round(m,counts,divby,modby)
    end
    return monkeys,counts
end

file = "day11_input.txt"

m = proc_file(file)
m,c = do_rounds(m,20,3,0)
println(reduce(*,sort(c)[end-1:end]))


m = proc_file(file)
lcm = reduce(*,[m.test for m in m])
m,c = do_rounds(m,10000,1,lcm)
println(reduce(*,sort(c)[end-1:end]))


