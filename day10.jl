function proc_file_signal_strength(file)
    f = open(file)
    iobuf = IOBuffer()
    cVals = 20:40:220
    clength = length(cVals)
    cind = 1
    nextcycle = cVals[cind]
    signalstrength = 0
    X=1
    cycle=0
    for line in eachline(f)
        print(iobuf,line)
        cycle+=1
        if cycle==nextcycle
            signalstrength+= cycle*X
            cind +=1
            if cind>clength
                break
            end
            nextcycle = cVals[cind]
        end
        if iobuf.size>=6
            cycle+=1
            if cycle==nextcycle
                signalstrength+= cycle*X
                cind +=1
                if cind>clength
                    break
                end
                nextcycle = cVals[cind]
            end
            X +=quickparse(iobuf,6)
        end
        take!(iobuf)
    end
    return X,cycle,signalstrength
end

function dispScreen(screen)
    for slice in eachslice(screen,dims=1)
        for b in slice
            b ? print('#') : print('.')
        end
        print("\n")
    end
end

function proc_file_screen(file)
    f = open(file)
    iobuf = IOBuffer()
    screen = fill(false,6,40)
    X=1
    cycle=0
    for line in eachline(f)
        print(iobuf,line)
        cycle+=1
        drawscreen(screen,cycle,X) && break
        if iobuf.size>=6
            cycle+=1
            drawscreen(screen,cycle,X) && break
            X +=quickparse(iobuf,6)
        end
        take!(iobuf)
    end
    return X,cycle,screen
end

function drawscreen(screen,cycle,x)
    row = 1+((cycle-1) ÷ 40)
    
    if row>6
        return true
    end

    col = 1+((cycle-1) % 40)
    if abs(col-1-x)<=1
        screen[row,col] = true
    end

    return false
end


function quickparse(io::IOBuffer,start_ind=1)
    sign = 1
    val = 0
    ind = start_ind
    s = UInt8('0');
    if io.data[ind]== UInt8('-')
        sign = -1
        ind +=1
    end
    while ind<=io.size
        val = val*10 + io.data[ind]-s
        ind +=1
    end
    return val*sign
end
file = "day10_input.txt"
x,c,S = proc_file_signal_strength(file)
println(S)
x,c,S = proc_file_screen(file)




dispScreen(S)






