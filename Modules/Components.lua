function generate_numberline(name, minimum, maximum, always_randomize)
    local comp_label = iup.label{title=name}
    local comp_button = iup.button{title = "HAHA A BUTTON"}
    local comp = iup.hbox{comp_label, comp_button, alignment = "ACENTER", margin="2x2"}
    iup.Append(randomization_panel,comp)
    iup.Map(comp)
    iup.Refresh(randomization_panel)    

end