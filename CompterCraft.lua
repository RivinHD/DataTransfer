
local chest, torch, strip, ground, height, width, depth

local function question(message)
    print(message)
    return io.read()
end

local function intquesttion(message)
    local i = tonumber(question(message))
    if i == nil then
        print("input is not a number")
        intquesttion(message)
    else
        return i
    end
end

local function toBool(respons)
    if respons == "y" then
        return true
    else
        return false
    end
end

local function forward()
    while true do
        if turtle.forward() then
            return
        else
            if turtle.detect() then
                turtle.dig()
            else
                turtle.attack()
            end
        end
    end
end

local function up()
    while true do
        if turtle.up() then
            return
        else
            if turtle.detectUp() then
                turtle.digUp()
            else
                turtle.attackUp()
            end
        end
    end
end

local function down()
    while true do
        if turtle.down() then
            return
        else
            if turtle.detectDown() then
                turtle.digDown()
            else
                turtle.attackDown()
            end
        end
    end
end

local function dig()
    if turtle.detect() then
        turtle.dig()
    end
end

local function digUp()
    if turtle.detectUp then
        turtle.digUp()
    end
end

local function digDown()
    if turtle.detectDown() then
        turtle.digDown()
    end
end

local function checkFuel()
    local refueled = false
    print("Fuel Level:" .. turtle.getFuelLevel())
    if turtle.getFuelLevel() == 0 then
        for i=1, 16, 1 do
            turtle.select(i)
            if turtle.refuel() then
                refueled = true
                print("Refueld:" .. turtle.getFuelLevel())
                break
            end
        end
        if not refueled then
            print("Need Fuel")
            local exit = toBool(question("exit? (y/n)"))
            if exit then
                error()
            else
                checkFuel()
            end
        end
    end
end

local function checkItem(ID)
    for i = 1, 16, 1 do
        if turtle.getItemDetail(i) == ID then
            return i
        end
    end
end

local function checkInventoryFull()
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

local function efficientDig(heightDelta)
    if heightDelta > 1 then
        dig()
        forward()
        digUp()
        if heightDelta > 2 then
            digDown()
        end
    else
        dig()
        forward()
    end
end

local function stripdig()
    for i = 1, 5, 1 do
        dig()
        forward()
    end
    turtle.turnLeft()
    turtle.turnLeft()
    for i = 1, 5, 1 do
        forward()
    end
end

local function main()
    -- inputs
    height = intquestion("Height?")
    width = intquesttion("Width?")
    depth = intquesttion("Depth?")
    chest = toBool(question("Place Chest? (y/n)"))
    torch = toBool(question("Place Torches? (y/n)"))
    strip = toBool(question("Stripmine? (y/n)"))
    ground = toBool(question("Build Ground? (y/n)"))
    
    -- check fuel
    checkFuel()
    
    -- align left corner
    turtle.turnLeft()
    for w = 1, w/2, 1 do
        dig()
        forward()
    end
    turtle.turnRight()

    --align dig
    efficientDig(height)
    if height > 3 then
        digUp()
        up()
    end

    -- start digging
    for d=1, depth, 1 do
        -- dig
        local r = false -- =right
        for h=height, 1, -3 do
            --stripmine
            if strip and math.fmod(d, 3) == 1 and math.fmod(h, 3) == 1 then
                if r then
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                end
                if height == 2 then
                    up()
                end
                stripdig()
                if height == 2 then
                    down()
                end
            else
                if r then
                    turtle.turnLeft()
                else
                    turtle.turnRight()
                end
            end

            --normal digging
            for w = 1, width, 1 do
                efficientDig(h)
                if h == height then
                    -- place ground
                    if ground  then
                        if height > 2 then
                            down()
                        end
                        if not turtle.detectDown() then
                            local slot = checkItem("minecraft:cobblestone")
                            if slot ~= nil then
                                turtle.select(i)
                                turtle.placeDown()
                            end
                        end
                        if height > 2 then
                            up()
                        end
                    end
                    -- place torch
                    if torch and math.fmod(d, 8) == 1 and math.fmod(w, 8) == 5 then
                        local slot = checkItem("minecraft:torch")
                        if height > 1 then
                            if height == 2 then
                                up()
                            end
                            if slot ~= nil then
                                turtle.select(slot)
                                turtle.placeDown()
                            end
                            if height == 2 then
                                down()
                            end
                        end
                    end
                end
            end

            -- stripmine
            if strip and math.fmod(d, 3) == 1 and math.fmod(h, 3) == 1 then
                if r then
                    turtle.turnLeft()
                else
                    turtle.turnRight()
                end
                if height == 2 then
                    up()
                end 
                stripdig()
                if height == 2 then
                    down()
                end
            else
                if r then
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                end
            end

            -- side
            r = not r

            -- end, go up
            if h > 1 then
                uph = 2
                if h > 2 then
                    uph = 3
                end
                for i = 1, uph, 1 do
                    digUp()
                    up()
                end
            end

        end

        -- align left bottom
        if r then
            for i = 1, width, 1 do
                forward()
            end
        end
        for i = 1, height - 1, 1 do
            down()
        end
        turtle.turnRight()
        efficientDig(height)
        checkFuel()
        --place chest
        if chest and checkInventoryFull() then
            turtle.turnLeft()
            turtle.turnLeft()
            local slot = checkItem("minecraft:chest")
            if slot ~= nil then
                turtle.select(slot)
                turtle.place()
                for i = 1, 16, 1 do
                    local ID = turtle.getItemDetail(i)
                    if ID ~= "minecraft:chest" or ID ~= "minecraft:torch" or ID ~="minecraft:coal" then
                        turtle.transferTo(i)
                    end
                end
                turtle.turnLeft()
                turtle.turnLeft()
            end
        end
        if height > 3 then
            digUp()
            up()
        end
    end

end

main()