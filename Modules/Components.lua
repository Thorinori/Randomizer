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
    local delete_button = iup.button{title = "Remove Rule (WIP)", aligmnet = "ACENTER"}
    local rand_label = iup.label{title="This will be a random value between ".. minimum.." and "..maximum, alignment="ACENTER:ACENTER"}
    local minihbox = iup.hbox{iup.vbox{comp_button,delete_button,padding="0x5", margin="0x10", normalizesize="YES"},rand_label, iup.fill{},alignment = "ALEFT", padding="2x2", normalizesize="BOTH",
        alignmentcol = "ACENTER", alignmentlin = "ACENTER", numdiv="2",orientation="HORIZONTAL", expandchildren="HORIZONTAL"}

    function comp_button:action()
        rand_label.title = comp_label.title .. ": " .. tostring(math.random(minimum, maximum))
    end

    local comp = iup.vbox{comp_label,minihbox, alignment = "ALEFT", margin="2x2"}

    function delete_button:action()
       --[[ table.remove(comp_actions, index)
        table.remove(data, index)
        comp:detach()
        iup.Refresh(randomization_panel)
        iup.RefreshChildren(randomization_panel)
        checkChildren()]]
    end

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end

--Generates a component that generates a value from the provided list
function generate_from_list(name, list)

    local comp_label = iup.label{title=name, font=15}
    local comp_button = iup.button{title = "Randomize "..name, alignment = "ALEFT"}
    local delete_button = iup.button{title = "Remove Rule (WIP)", aligmnet = "ALEFT"}
    local rand_label = iup.label{title="This will be a random name from the provided list", alignment="ACENTER:ACENTER"}
    local minihbox = iup.hbox{iup.vbox{comp_button,delete_button,padding="0x5", margin="0x10", normalizesize="YES"},rand_label, iup.fill{}, alignment = "ATOP", padding="2x2", normalizesize="BOTH",
        alignmentcol = "ACENTER", alignmentlin = "ACENTER", numdiv="2",orientation="HORIZONTAL", expandchildren="HORIZONTAL"}

    function comp_button:action()
        local choice = math.random( 1, #list)
        rand_label.title = comp_label.title .. ": " .. list[choice]
    end
    
    local comp = iup.vbox{comp_label, iup.label{seperator="HORIZONTAL"},minihbox, alignment = "ACENTER", margin="2x2"}

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end

--Generates a component that builds a seed from the provided list
function generate_seed(name, max_len, list)

    local comp_label = iup.label{title=name, font=15}
    local comp_button = iup.button{title = "Randomize "..name, alignment = "ALEFT"}
    local delete_button = iup.button{title = "Remove Rule (WIP)", aligmnet = "ALEFT"}
    local rand_text = iup.text{value="This will contain a seed for you to copy", alignment="ACENTER", readonly="YES", visiblecolumns=max_len}
    local minihbox = iup.hbox{iup.vbox{comp_button,delete_button,alignment="ALEFT",padding="0x5", margin="5x0", normalizesize="YES"}, rand_text, iup.fill{},alignment = "ALEFT",
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
    
    local comp = iup.vbox{comp_label,minihbox, alignment = "ALEFT", margin="2x2"}

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end