function checkChildren()
    if(iup.GetChildCount(randomization_panel) > 0) then
        randomization_panel.visible = "YES"
        available_scripts_panel.visible = "NO"
    end
end

function generate_random_number(name, minimum, maximum)
    local comp_label = iup.label{title=name, font=15}
    local comp_button = iup.button{title = "Randomize", alignment = "ACENTER"}
    local rand_label = iup.label{title="This will be a random value between ".. minimum.." and "..maximum, alignment="ACENTER:ACENTER"}
    local minihbox = iup.hbox{rand_label, iup.label{seperator="VERTICAL"}, comp_button, alignment = "ATOP", padding="2x2"}

    function comp_button:action()
        rand_label.title = tostring(math.random(minimum, maximum))
    end

    local comp = iup.vbox{comp_label, iup.label{seperator="HORIZONTAL"},minihbox, alignment = "ACENTER", margin="2x2"}

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end

function generate_from_list(name, list)

    local comp_label = iup.label{title=name, font=15}
    local comp_button = iup.button{title = "Randomize", alignment = "ACENTER"}
    local rand_label = iup.label{title="This will be a random name from the provided list", alignment="ACENTER:ACENTER"}
    local minihbox = iup.hbox{rand_label, iup.label{seperator="VERTICAL"}, comp_button, alignment = "ATOP", padding="2x2"}

    function comp_button:action()
        local choice = math.random( 1, #list)
        rand_label.title = list[choice]
    end
    
    local comp = iup.vbox{comp_label, iup.label{seperator="HORIZONTAL"},minihbox, alignment = "ACENTER", margin="2x2"}

    table.insert(comp_actions, comp_button.action)
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)
    iup.RefreshChildren(randomization_panel)
    checkChildren()
end