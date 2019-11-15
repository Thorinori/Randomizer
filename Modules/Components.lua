require("Modules/ListEditor")
require("Modules/FieldEditor")

--For a quick open menu idea
function checkChildren()
    if(iup.GetChildCount(randomization_panel) > 0) then
        randomization_panel.visible = "YES"
        available_scripts_panel.visible = "NO"
    end
end

--Generates a component that generates a random number between minimum and maximum
function generate_random_number(name, minimum, maximum)
    local comp_label = iup.label{title=name, font=15}
    local comp_button = iup.button{title = "Randomize "..name, alignment = "ACENTER"}
    local modify_button = iup.button{title = "Modify "..name, alignment = "ACENTER"}
    local move_up_button = iup.button{title = "Move Up "..name, alignment = "ACENTER"}
    local move_down_button = iup.button{title = "Move Down "..name, alignment = "ACENTER"}
    local delete_button = iup.button{title = "Remove Rule", aligmnet = "ACENTER"}
    local rand_label = iup.label{title="This will be a random value between ".. minimum.." and "..maximum, alignment="ALEFT:ACENTER"}
    local minihbox = iup.vbox{iup.hbox{comp_button,modify_button,delete_button, move_up_button, move_down_button,padding="5x5", margin="5x10", normalizesize="YES"},rand_label,alignment = "ACENTER", padding="2x2", normalizesize="BOTH",
        alignmentcol = "ACENTER", alignmentlin = "ACENTER", numdiv="2",orientation="HORIZONTAL", expandchildren="HORIZONTAL"}

    function comp_button:action()
        rand_label.title = comp_label.title .. ": " .. tostring(math.random(minimum, maximum))
    end

    function modify_button:action()
        edit_fields(name)
    end

    function delete_button:action()
        local item_removed = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                item_removed = true
                table.remove(data, k)
                break
            end
        end
        if(item_removed) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    function move_up_button:action()
        local item_moved = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                if(data[k-1] ~= nil) then
                    item_moved = true
                    data[k-1], data[k] = v, data[k-1]
                end
                break
            end
        end
        if(item_moved) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    
    function move_down_button:action()
        local item_moved = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                if(data[k+1] ~= nil) then
                    item_moved = true
                    data[k+1], data[k] = v, data[k+1]
                end
                break
            end
        end
        if(item_moved) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    local comp = iup.vbox{comp_label,minihbox, alignment = "ALEFT", margin="2x2"}

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end

--Generates a component that generates a value from the provided list
function generate_from_list(name, prov_list)
    local list = prov_list
    local comp_label = iup.label{title=name, font=15}
    local comp_button = iup.button{title = "Randomize "..name, alignment = "ALEFT"}
    local modify_button = iup.button{title = "Modify "..name, alignment = "ACENTER"}
    local move_up_button = iup.button{title = "Move Up "..name, alignment = "ACENTER"}
    local move_down_button = iup.button{title = "Move Down "..name, alignment = "ACENTER"}
    local delete_button = iup.button{title = "Remove Rule", aligmnet = "ALEFT"}
    local rand_label = iup.label{title="This will be a random item from the provided list", alignment="ALEFT:ACENTER"}
    local minihbox = iup.vbox{iup.hbox{comp_button,modify_button,delete_button,move_up_button, move_down_button,padding="5x5", margin="5x10", normalizesize="YES"},rand_label, alignment = "ATOP", padding="2x2", normalizesize="BOTH",
        alignmentcol = "ACENTER", alignmentlin = "ACENTER", numdiv="2",orientation="HORIZONTAL", expandchildren="HORIZONTAL"}

    function comp_button:action()
        local choice = math.random( 1, #list)
        rand_label.title = comp_label.title .. ": " .. list[choice]
    end

    function modify_button:action()
        edit_list(list, name)
    end
    
    function delete_button:action()
        local item_removed = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                item_removed = true
                table.remove(data, k)
                break
            end
        end
        if(item_removed) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end


    function move_up_button:action()
        local item_moved = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                if(data[k-1] ~= nil) then
                    item_moved = true
                    data[k-1], data[k] = v, data[k-1]
                end
                break
            end
        end
        if(item_moved) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    function move_down_button:action()
        local item_moved = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                if(data[k+1] ~= nil) then
                    item_moved = true
                    data[k+1], data[k] = v, data[k+1]
                end
                break
            end
        end
        if(item_moved) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    local comp = iup.vbox{comp_label,minihbox, alignment = "ALEFT", margin="2x2"}

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end

--Generates a component that builds a seed from the provided list
function generate_seed(name, prov_list, max_len)
    local name = name
    local list = prov_list
    local comp_label = iup.label{title=name, font=15}
    local comp_button = iup.button{title = "Randomize "..name, alignment = "ALEFT"}
    local modify_button = iup.button{title = "Modify "..name, alignment = "ACENTER"}
    local move_up_button = iup.button{title = "Move Up "..name, alignment = "ACENTER"}
    local move_down_button = iup.button{title = "Move Down "..name, alignment = "ACENTER"}
    local delete_button = iup.button{title = "Remove Rule", aligmnet = "ALEFT"}
    local rand_text = iup.text{value="This will contain a seed for you to copy", alignment="ACENTER", readonly="YES", visiblecolumns=max_len}
    local minihbox = iup.vbox{iup.hbox{comp_button,modify_button,delete_button,move_up_button, move_down_button,alignment="ALEFT",padding="5x5", margin="5x5", normalizesize="YES"}, rand_text,alignment = "ATOP",
        padding="2x2", alignmentcol = "ALEFT", alignmentlin = "ACENTER", numdiv="2",orientation="HORIZONTAL", expandchildren="HORIZONTAL"}

    function comp_button:action()
        local len = math.random(1, max_len)
        local str = ""
        for i=1,len do
            local char = math.random(1,#list)
            str = str .. list[char]
        end
        rand_text.value = str
    end

    function modify_button:action()
        edit_list(list, name)
    end
    
    function delete_button:action()
        local item_removed = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                item_removed = true
                table.remove(data, k)
                break
            end
        end
        if(item_removed) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    function move_up_button:action()
        local item_moved = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                if(data[k-1] ~= nil) then
                    item_moved = true
                    data[k-1], data[k] = v, data[k-1]
                end
                break
            end
        end
        if(item_moved) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    function move_down_button:action()
        local item_moved = false
        for k,v in ipairs(data) do
            if(v["args"][1] == name) then
                if(data[k+1] ~= nil) then
                    item_moved = true
                    data[k+1], data[k] = v, data[k+1]
                end
                break
            end
        end
        if(item_moved) then
            local tmpfile = "./Scripts/tmp.lua"
            writefile(tmpfile, data)
            reload_file(tmpfile)
            os.remove(tmpfile)
        end
    end

    local comp = iup.vbox{comp_label,minihbox, alignment = "ALEFT", margin="2x2"}

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end