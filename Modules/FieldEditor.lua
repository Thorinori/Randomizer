function edit_fields(name)
    local field_editor_dialog = extra_dialogs["field_editor"]
    if( not field_editor_dialog) then
        number_editor_1 = iup.text{expand="HORIZONTAL"}
        number_editor_2 = iup.text{expand="HORIZONTAL"}
        local number_editor_1_box = iup.hbox{iup.label{title = "Minimum: "}, number_editor_1, margin="2x10"}
        local number_editor_2_box = iup.hbox{iup.label{title = "Maximum: "}, number_editor_2, margin="2x10"}
        local editor_button_box = iup.hbox{alignment="ACENTER"}
        local editor_panel = iup.vbox{number_editor_1_box,number_editor_2_box,editor_button_box, alignment="ACENTER"}

        local save_button = iup.button{title = "Save Changes to Numbers"}
        local cancel_button = iup.button{title = "Cancel Changes to Numbers"}

        function save_button:action()
            close(1)
        end

        function cancel_button:action()
            close(0)
        end

        iup.Append(editor_button_box,save_button)
        iup.Map(save_button)
        iup.Append(editor_button_box,cancel_button)
        iup.Map(cancel_button)
        iup.Refresh(editor_button_box)

        function close(option)
            if(option == 1) then
                --Save changes
                for k,v in ipairs(data) do
                    if(v["args"][1] == name) then
                        v["args"][2] = number_editor_1.value
                        v["args"][3] = number_editor_2.value
                        local tmpfile = "./Scripts/tmp/tmp.lua"
                        writefile(tmpfile, data)
                        number_editor_1.value = ""
                        number_editor_2.value = ""
                        iup.Hide(field_editor_dialog)
                        reload_file(tmpfile)
                        os.remove(tmpfile)
                    end
                end
            else
                number_editor_1.value = ""
                number_editor_2.value = ""
                iup.Hide(field_editor_dialog)
            end

        end

        field_editor_dialog = iup.dialog{
            editor_panel,
            title = "Field Editor",
            dialogframe = "Yes",
            parentdialog = main_win,
            size="HALFxHALF"
        }

        extra_dialogs["field_editor"] = field_editor_dialog
    end

    for k,v in ipairs(data) do
        if(v["args"][1] == name) then
            number_editor_1.value = v["args"][2]
            number_editor_2.value = v["args"][3]
        end 
    end
    field_editor_dialog:showxy(iup.CURRENT,iup.CURRENT)
end