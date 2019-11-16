--Made by Joseph Pace (Thorinori)

--Maybe not needed. Not needed especially until Windows support is the focus.
local sep = package.config:sub(1,1)
if(sep == "/") then
    package.cpath = package.cpath .. ";./libs/UNIX/iup/Lua53/lib?53.so;"
else
    package.cpath = package.cpath .. ";./libs/Windows/iup/Lua53/?53.dll;"
end

iup = require("iuplua")
lfs = require("lfs")
require("Modules/FileIO")
require("Modules/TableFunctions")
require("Modules/Components")

--Misc Functions

function debug(s)
  if debug_mode then
    multitext.append = s
  end
end

function reset_random()
  comp_actions = {}
  local child = iup.GetNextChild(randomization_panel,nil)
  while(child) do
      local old_child = child
      child = iup.GetNextChild(randomization_panel,old_child)
      old_child:detach()
      old_child:destroy()
  end
  local title = iup.label{title="Randomizer", alignment = "ACENTER", padding="0x5"}
  iup.Append(randomization_panel, title)
  iup.Map(title)
  iup.Refresh(randomization_panel)
end

--Instantiate seed
math.randomseed(os.time())

--Configs
config = iup.config{}
config.app_name = "Randomizer"
config:Load()

--Globals
debug_mode = true -- For debug print statements into the multitext console (Primary use of the console)
extra_dialogs = {}
comp_actions = {} -- access them with comp_actions[n]() to call all in one loop
data = {} --Stores all active data for current profile
filedata = {} --Intermediate step to go from stored table format to used table format stored in data
current_file = "" --Path to current profile file

--Primary Components
create_rule_panel = iup.vbox{iup.label{title="Rule Creator", alignment = "ALEFT", padding="10x5"}, padding="10x5"}

randomization_panel = iup.vbox{iup.label{title="Randomizer", alignment = "ALEFT", padding="10x5"}, visible="YES", padding="10x5", alignment = "ALEFT"}
randomization_scroll = iup.scrollbox{randomization_panel, alignment = "ALEFT", padding="10x5", childoffset="90x5"}

extra_container = iup.hbox{create_rule_panel,randomization_scroll, padding="10x10"}
randomize_all_button = iup.button{title = "Randomize All", padding = "10x5"}

main_panel = iup.vbox{extra_container, iup.hbox{randomize_all_button,alignment="ACENTER"}, alignment = "ACENTER"}

--Stuff for quick open menu idea
available_scripts_panel =iup.vbox{visible="YES"} 
available_scripts = {}

--Setup multitext "console"
local visible = "NO"
local console = config:GetVariable("MainWindow", "Console")
if console == "YES" then
 visible = "YES"
end
multitext = iup.text{multiline = "YES", expand = "HORIZONTAL", scrollbar = "YES", visiblelines = 12, alignment = "ALEFT", 
  config = config, visible=visible, readonly = "YES", wordwrap="YES"}

--Setup buttont hat randomized all fields for profile
function randomize_all_button:action()
  for _, item in ipairs(comp_actions) do
      item()
      for i = 1, math.random(10) do --Extra random calls to make smaller ranges more varied
        math.random()
      end
  end
  debug(table.tostring(data))
end

--Menu Seperator
local horiz_sep = iup.separator{}

--File Menu
local new_button = iup.item{title = "New..."}
local open_button = iup.item{title = "Open...\t Ctrl+O"}
local save_button = iup.item{title = "Save...\t Ctrl+S"}
local saveas_button = iup.item{title = "Save as.."}
local exit_button = iup.item{title = "Exit"}

--File Menu Button Functions

function new_button:action()
  reset_random()
  data = {}
  filedata = {}
  comp_actions = {}
  current_file = ""
  main_win.title = "Randomizer"
end

function open_button:action()
  local open_file_window = iup.filedlg{
    dialogtype = "OPEN",
    filter = "*.lua",
    filterinfo = "Lua Files",
    directory = "./Scripts"
  }

  open_file_window:popup(iup.CENTER,iup.CENTER)

  if (tonumber(open_file_window.status) ~= -1) then
    reset_random()
    local fname = open_file_window.value
    filedata = readfile(fname)
    debug("Filedata: ".. filedata)
    load(filedata)()
    current_file = fname
    main_win.title = current_file .. "- Randomizer"
    iup.Refresh(main_win)
    i = 1
    for k,v in ipairs(data) do
   
        local func = v["func"].."("
        for key, val in ipairs(v["args"]) do
            debug("Type of argument: "..type(val))
            if type(val) == "string" then
              func = func .."\"".. tostring(val).."\","
            elseif type(val) == "table" then
              func = func .. table.tostring(val)..","
            else
              func = func .. val..","
            end
        end
        func = func:sub(1,-2)
        func = func..")"

        debug(func)
        load(func)()
        i = i + 1
    end
    debug(table.tostring(data))
  end

  open_file_window:destroy()
end

function reload_file(fname)
    reset_random()
    local fname = fname
    print("Attempting to reload " ..fname.."\n")
    filedata = {}
    filedata = readfile(fname)
    debug("Filedata: ".. filedata)
    load(filedata)()
    iup.Refresh(main_win)
    i = 1
    for k,v in ipairs(data) do
        local func = v["func"].."("
        for key, val in ipairs(v["args"]) do
            debug("Type of argument: "..type(val))
            if type(val) == "string" then
              func = func .."\"".. tostring(val).."\","
            elseif type(val) == "table" then
              func = func .. table.tostring(val)..","
            else
              func = func .. val..","
            end
        end
        func = func:sub(1,-2)
        func = func..")"

        debug(func)
        load(func)()
        i = i + 1
    end
    debug(table.tostring(data))

end

function save_button:action()
  if(current_file ~= '') then
    writefile(current_file, data)
  else
    iup.Message("Save Warning", "Please use Save As to Save a fresh file!")
  end
end

function saveas()
  local saveas_file_window = iup.filedlg{
    dialogtype = "SAVE",
    filter = "*.lua",
    directory = "./Scripts",
    parentdialog=main_win
  }

  saveas_file_window:popup(iup.CENTER,iup.CENTER)
  debug("Hit Save As")

  debug("Starting Save As")
  print(tonumber(saveas_file_window.status) ~= -1)
  if(tonumber(saveas_file_window.status) ~= -1) then
    local fname = saveas_file_window.value .. ".lua"
    writefile(fname, data)
    debug("Ended Save As")
    current_file = fname
    main_win.title = current_file .. "- Randomizer"
    iup.Refresh(main_win)
    saveas_file_window:destroy()
    return fname
  else
    debug("Save Failed")
    saveas_file_window:destroy()
  end
end

function saveas_button:action()
  saveas()
end

function exit_button:action()
  config:DialogClosed(main_win, "MainWindow")
  config:Save()
  config:destroy()
  return iup.CLOSE
end

local file_menu = iup.menu{new_button,open_button,save_button,saveas_button,horiz_sep,exit_button}
local file_submenu = iup.submenu{file_menu, title="File"}

--Help Menu
local about_button = iup.item{title="About"}

function about_button:action()
  iup.Message("About", "Randomizer\nAuthor: Joseph Pace (Thorinori)")
end

local help_menu = iup.menu{about_button}
local help_submenu = iup.submenu{help_menu, title="Help"}

--View Menu

local console_button = iup.item{title="Console"}

function console_button:action()
  local curr = multitext.visible
  if curr == "YES" then
    multitext.visible = "NO"
    multitext:detach()
    config:SetVariable("MainWindow", "Console", "NO")
  else
    multitext.visible = "YES"
    iup.Append(main_panel,multitext)
    iup.Map(multitext)
    iup.Refresh(randomization_panel)   
    config:SetVariable("MainWindow", "Console", "YES")
  end
  iup.Refresh(main_win)
  iup.RefreshChildren(main_win)
end

local view_menu = iup.menu{console_button}
local view_submenu = iup.submenu{view_menu, title="View"}

--Main Menu
local menu = iup.menu{file_submenu,view_submenu,help_submenu}

--Rule Creator Section
blank_panel = iup.vbox{visible="YES"}
random_number_panel = iup.vbox{visible="NO"}
random_list_panel = iup.vbox{visible="NO"}
seed_panel = iup.vbox{visible="NO"}

layers = iup.zbox{blank_panel,random_number_panel,random_list_panel,seed_panel}

local instruction_label = iup.label{title = "Select a type of rule from the dropdown below"}
local create_rule_dropdown_button = iup.list{"Random Number", "Random Choice from List", "Seed", dropdown="YES", padding="10x10", margin="10x10"}


rule_title = iup.gridbox{iup.label{title="Rule Name: "}, iup.text{alignment="ALEFT", visiblecolumns="10"}, padding="10x10", normalizesize="BOTH",
  numdiv="2",orientation="HORIZONTAL", alignment = "ALEFT", visible="NO"}

rand_num_min = iup.gridbox{iup.label{title="Minimum Value: "}, iup.text{alignment="ALEFT", visiblecolumns="10"}, alignment="ARIGHT", padding="10x10", normalizesize="BOTH",
  numdiv="2",orientation="HORIZONTAL"}
rand_num_max = iup.gridbox{iup.label{title="Maximum Value: "}, iup.text{alignment="ALEFT", visiblecolumns="10"}, alignment="ARIGHT", padding="10x10", normalizesize="BOTH",
  numdiv="2",orientation="HORIZONTAL"}

rand_list = iup.vbox{iup.label{title="List of Elements (One per line):"}, iup.text{multiline="YES", visiblecolumns="22", visiblelines="20", alignment="ALEFT"}, 
    padding="10x10",
    alignment="ACENTER",
    margin="0x10"
  }

max_seed_length = iup.gridbox{iup.label{title="Max Seed Length: "}, iup.text{alignment="ALEFT", visiblecolumns="10"}, alignment="ARIGHT", padding="10x10", normalizesize="BOTH",
  numdiv="2",orientation="HORIZONTAL"}

seed_valid_chars = iup.vbox{iup.label{title="List of Valid Characters (One per line):", padding="10x10"}, iup.text{multiline="YES", visiblecolumns="22", visiblelines="20", 
    alignment="ALEFT"}, 
    padding="10x10",
    alignment="ACENTER",
    margin="0x10"
  }

local blank = iup.fill{}

repetition_label = iup.label{title="Number of times to add this rule:", padding="5x5", tip = "Warning: This will append a number to the rule title"}
repetition_text = iup.text{value="1"}
repetition_panel = iup.vbox{repetition_label,repetition_text, padding="5x1"}

add_button = iup.button{title="Add Rule", alignment = "ACENTER", padding="5x15"}
add_button_panel = iup.hbox{add_button,repetition_panel,alignment="ACENTER", padding="5x10"}



iup.Append(create_rule_panel,instruction_label)
iup.Map(instruction_label)
iup.Refresh(create_rule_panel)

iup.Append(create_rule_panel,create_rule_dropdown_button)
iup.Map(create_rule_dropdown_button)
iup.Refresh(create_rule_panel)

iup.Append(create_rule_panel,rule_title)
iup.Map(rule_title)
iup.Refresh(create_rule_panel)

iup.Append(random_number_panel,rand_num_min)
iup.Map(rand_num_min)
iup.Refresh(random_number_panel)

iup.Append(random_number_panel,rand_num_max)
iup.Map(rand_num_max)
iup.Refresh(random_number_panel)

iup.Append(random_list_panel,rand_list)
iup.Map(rand_list)
iup.Refresh(random_list_panel)

iup.Append(seed_panel,max_seed_length)
iup.Map(max_seed_length)
iup.Refresh(seed_panel)

iup.Append(seed_panel,seed_valid_chars)
iup.Map(seed_valid_chars)
iup.Refresh(seed_panel)

iup.Append(create_rule_panel,layers)
iup.Map(layers)
iup.Refresh(create_rule_panel)

iup.Append(create_rule_panel,blank)
iup.Map(blank)
iup.Refresh(create_rule_panel)

iup.Append(create_rule_panel,add_button_panel)
iup.Map(add_button_panel)
iup.Refresh(create_rule_panel)

--Change panels based on dropdown
function create_rule_dropdown_button:action(str, index, state)
    if(index == 1 and state == 1) then
        rule_title.visible = "YES"
        random_number_panel.visible = "YES"
        random_list_panel.visible = "NO"
        seed_panel.visible = "NO"
        reset_inputs()
    elseif(index == 2 and state == 1) then
        rule_title.visible = "YES"
        random_number_panel.visible = "NO"
        random_list_panel.visible = "YES"
        seed_panel.visible = "NO"
        reset_inputs()
    elseif(index == 3 and state == 1) then 
        rule_title.visible = "YES"
        random_number_panel.visible = "NO"
        random_list_panel.visible = "NO"
        seed_panel.visible = "YES"
        reset_inputs()
        iup.GetChild(rule_title,1).value = "Seed"
    end
end

--String Splitting for Adding Lists (Found at https://stackoverflow.com/questions/1426954/split-string-in-lua)
function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

--Clear input fields
function reset_inputs()
  iup.GetChild(rand_list, 1).value = ""
  iup.GetChild(rand_num_min, 1).value = ""
  iup.GetChild(rand_num_max, 1).value = ""
  iup.GetChild(rule_title, 1).value = ""
  iup.GetChild(seed_valid_chars, 1).value = ""
  iup.GetChild(max_seed_length, 1).value = ""
  iup.GetChild(repetition_panel, 1).value = "1"
end

--Add Rule to Profile and Create buttons etc as needed
function add_button:action()
  local item_exists = false
  for k,v in ipairs(data) do
      if(v["args"][1] == iup.GetChild(rule_title,1).value) then
          item_exists = true
          break
      end
  end
  if(not item_exists) then
    local reps = tonumber(repetition_text.value)
    if(reps) then
        if(create_rule_dropdown_button.value == "1") then
            local min = tonumber(iup.GetChild(rand_num_min, 1).value)
            local max = tonumber(iup.GetChild(rand_num_max, 1).value)
            local orig_title = iup.GetChild(rule_title,1).value
            if((max and min) and (min <= max)) then
              for i=1,reps do
                if( reps > 1 ) then title= orig_title..tostring(i) else title = orig_title end
                generate_random_number(title,min, max, #data + 1)
                local tmp = {["func"] = "generate_random_number", ["args"] = {[1] = title, [2] = min, [3] = max}}
                table.insert(data,tmp)
              end
              reset_inputs()
            else
              iup.Message("Invalid Input", "Minimum and Maximum must both be numbers")
            end
        elseif(create_rule_dropdown_button.value == "2") then
          local entered = iup.GetChild(rand_list,1).value
          local lst = mysplit(entered, "\n")
          local orig_title = iup.GetChild(rule_title,1).value
          for i=1,reps do
            if( reps > 1 ) then title= orig_title..tostring(i)  else title = orig_title end
            generate_from_list(title, lst)
            local tmp = {["func"] = "generate_from_list", ["args"] = {[1] = title, [2] = lst}}
            table.insert(data,tmp)
          end
          reset_inputs()
        elseif(create_rule_dropdown_button.value == "3") then
          local entered = iup.GetChild(seed_valid_chars,1).value
          local lst = mysplit(entered, "\n")
          local orig_title = iup.GetChild(rule_title,1).value
          if(tonumber(iup.GetChild(max_seed_length,1).value)) then
            for i=1,reps do
              if( reps > 1 ) then title= orig_title..tostring(i)  else title = orig_title end
              generate_seed(title, lst, tonumber(iup.GetChild(max_seed_length,1).value))
              local tmp = {["func"] = "generate_seed", ["args"] = {[1] = title, [2] = lst, [3] = tonumber(iup.GetChild(max_seed_length,1).value)}}
              table.insert(data,tmp)
            end
            reset_inputs()
          end
        end
      end
    else
      iup.Message("Repeated Rule Name", "Please use a Unique Rule Name (That one exists already)")
    end
end

--[[ For Potential quick open menu support
function open_shortcut(fname)
    filedata = readfile(fname)
    debug("Filedata: ".. filedata)
    load(filedata)()
    current_file = fname
    main_win.title = current_file .. "- Randomizer"
    iup.Refresh(main_win)
    for k,v in ipairs(data) do
      local func = v["func"].."("
      for key, val in ipairs(v["args"]) do
          debug("Type of argument: "..type(val))
          if type(val) == "string" then
            func = func .."\"".. tostring(val).."\","
          else
            func = func .. val
          end
      end
      func = func..")"
      debug(func)
      load(func)()
  end
  debug(table.tostring(data))
end

--Available Scripts Panel (Easy Open Panel)
debug("Looking for scripts")
for file in lfs.dir("./Scripts") do
    if file ~= "." and file ~= ".." then
        local path = "./Scripts/"..file
        table.insert(available_scripts, path)
        print(path)
    end
end


function shortcut_button_action(v)
    open_shortcut(v)
end

for k,v in ipairs(available_scripts) do
  local comp = iup.flatbutton{title=v, action=shortcut_button_action(v)}
  iup.Append(available_scripts_panel, comp)
  iup.Map(comp)
  iup.Refresh(available_scripts_panel)
end
debug("Done looking for scripts")

]]--


main_win = iup.dialog{
  menu=menu,
  main_panel,
  title = "Randomizer",
  size="HALFxHALF",
  close_cb = exit_button.action
}

--Keybinds
function main_win:k_any(c)
  if (c == iup.K_cO) then --Ctrl O
    open_button:action()
  elseif (c == iup.K_cS) then --Ctrl S
    save_button:action()
  end

end

config:DialogShow(main_win, "MainWindow")

-- to be able to run this script inside another context (From IUP Documentation)
if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
  iup.Close()
end