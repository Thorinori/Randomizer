function edit_list(prov_list, name)
    local list_editor_dialog = extra_dialogs["list_editor"]
    if( not list_editor_dialog) then
        list_editor = iup.text{multiline = "YES", expand="YES"}
        local editor_button_box = iup.hbox{alignment="ACENTER"}
        local editor_panel = iup.vbox{list_editor,editor_button_box, alignment="ACENTER"}

        local save_button = iup.button{title = "Save Changes to List"}
        local cancel_button = iup.button{title = "Cancel Changes to List"}

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
                        local tmp =  mysplit(list_editor.value, "\n")
                        v["args"][2] = tmp
                        local tmpfile = "./Scripts/tmp/tmp.lua"
                        writefile(tmpfile, data)
                        list_editor.value = ""
                        iup.Hide(list_editor_dialog)
                        reload_file(tmpfile)
                        os.remove(tmpfile)
                    end
                end
            else
                list_editor.value = ""
                iup.Hide(list_editor_dialog)
            end

        end

        list_editor_dialog = iup.dialog{
            editor_panel,
            title = "List Editor",
            dialogframe = "Yes",
            parentdialog = main_win,
            size="HALFxHALF"
        }

        extra_dialogs["list_editor"] = list_editor_dialog
    end

    for k,v in ipairs(data) do
        if(v["args"][1] == name) then
            local s = ""
            for _,item in ipairs(v["args"][2]) do
                s = s .. item .. "\n"
            end
            list_editor.value = s
        end 
    end
    list_editor_dialog:showxy(iup.CURRENT,iup.CURRENT)
end