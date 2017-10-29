--[[
 *	The MIT License (MIT)
 *
 *	Copyright (c) 2014 Devilotte
 *	
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to 
 *	deal in the Software without restriction, including without limitation the 
 *	rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 *	sell copies of the Software, and to permit persons to whom the Software is 
 *	furnished to do so, subject to the following conditions:
 *	
 *	The above copyright notice and this permission notice shall be included in 
 *	all copies or substantial portions of the Software.
 *	
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 *	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 *	DEALINGS IN THE SOFTWARE.
]]--



_addon.author   = 'devilotte';
_addon.name     = 'AbysRef';
_addon.version  = '1.0';

--Required Files
require 'common'
require 'imguidef'
require 'abysrefintro'
require 'AbysRefLuaTable'

--tables
id_list = {}
staging_list = {}
output_list = {}

--imgui.CreateVar for imgui.InputText
name_keyitem_v = imgui.CreateVar(ImGuiVar_CDSTRING, 64);

--Various Flags
item_button_flag = false;
atma_button_flag = false;
tier_button_flag = false;
intro_window_flag = true;
search_not_found_flag = false;
staging_list_successful_flag = false
user_input_insuficient_flag = false
related_mobs_button_created_flag = false
output_mobs_button_created_flag = false
output_string_updated = false
atma_flag = false

------------------------------------------------------------------	
--intro window
--press start to get to next window
------------------------------------------------------------------
local function ShowIntroWindow()
	--color settings
	imgui.PushStyleColor(ImGuiCol_TitleBgActive,  1, .4, 0, 1);
	imgui.PushStyleColor(ImGuiCol_WindowBg, 0, 0, 0, 1.7);
	imgui.PushStyleColor(ImGuiCol_Button, 1, .4, 0, 1);

	--set main window
	imgui.Begin('Abyssea Reference Intro', 1, 0)
	imgui.SetWindowSize(290, 510);
	imgui.SetWindowPos(450, 200);
	--print intro graphic
		for i = 1, 25 do
			line = abysrefintro[i];
			imgui.Text(string.format('%s', line));
		end	
	imgui.TextColored(1, .4, 0, 1, 'Developer: Devilotte of LegionDark');
	imgui.TextColored(1, .4, 0, 1, 'Spreadsheet: Meyrink Kairo Uzi Lavrik');
	--start button
	imgui.Indent(60);
	if imgui.Button('START',150,20) then 
		intro_window_flag = false; 
	end
	imgui.End();
	imgui.PopStyleColor();
	imgui.PopStyleColor();
	imgui.PopStyleColor();
end

------------------------------------------------------------------	
--Finds first available from mob_id{} by search_input
------------------------------------------------------------------
function FindFirstIDbySearch(user_input, id_list)
	for iterator = 1, #mob_id do
		--user_input finds name, droppedki, tierzero, atma
		if mob_id[iterator].name:contains(user_input) or mob_id[iterator].droppedki:contains(user_input) 
		or mob_id[iterator].atma:contains(user_input) or mob_id[iterator].tierzero:contains(user_input) then
			table.insert(id_list,iterator);
			return id_list
		end
	end
	return id_list
end

------------------------------------------------------------------	
--if id_list is empty, search_not_found_flag on, else not on
------------------------------------------------------------------
function CheckIsOrNotFound(id_list)
	--search_not_found_flag on
	if (#id_list == 0) then
		search_not_found_flag = true
		return rotating_id
	--set rotating_id and return
	elseif (#id_list >= 1) then
		local rotating_id = id_list[1]
		return rotating_id
	end		
end

------------------------------------------------------------------	
--from search_input found ID, checks next tier for kipop not ""
--if not "" contain next tier name and loop
------------------------------------------------------------------
function GetHighestTierMobID(id_list)
	--set name for loop
	new_name_search = mob_id[id_list[1]].kipops
	for x = 1, 2 do
		--top of tier found, early return
		if (mob_id[id_list[1]].kipops == "") then
			return id_list
		end
		for iterator = 1, #mob_id do
			--set next new name
			if new_name_search == mob_id[iterator].name then
				new_name_search = mob_id[iterator].kipops
					--top of tier found, late return
					if mob_id[iterator].kipops == "" then
						id_list[1] = iterator
						return id_list
					end
			end
		end
	end
end

------------------------------------------------------------------	
--Top of Tier ID rotates down the Tier grabbing PIreq items
--each mob found by PIreq, id_list{} contains each found ID
------------------------------------------------------------------
function GetLowerTiersFromUpper(id_list)
	local id_list_iterator = 1
	--iteration for id_list, id_list growth can be > 3 elements per loop. rotating_id loops through each one.
	while id_list[id_list_iterator] do
		local rotating_id = id_list[id_list_iterator];
		id_list_iterator = id_list_iterator + 1;
			--iteration for main table
			for iterator = 1, #mob_id do
				--if rotating_id PI iteration is not blank and main table iteration droppedKI equals rotating_IDs PI then insert ID to id_list{}
				if (mob_id[rotating_id].popitemrq ~= "" and mob_id[iterator].droppedki == mob_id[rotating_id].popitemrq) then
					table.insert(id_list,iterator)
				elseif (mob_id[rotating_id].popitemrq2 ~= "" and mob_id[iterator].droppedki == mob_id[rotating_id].popitemrq2) then
					table.insert(id_list,iterator)
				elseif (mob_id[rotating_id].popitemrq3 ~= "" and mob_id[iterator].droppedki == mob_id[rotating_id].popitemrq3) then
					table.insert(id_list,iterator)
				elseif (mob_id[rotating_id].popitemrq4 ~= "" and mob_id[iterator].droppedki == mob_id[rotating_id].popitemrq4) then
					table.insert(id_list,iterator)					
				elseif (mob_id[rotating_id].popitemrq5 ~= "" and mob_id[iterator].droppedki == mob_id[rotating_id].popitemrq5) then
					table.insert(id_list,iterator)	
				end
			end
	end
	return id_list
end
------------------------------------------------------------------	
--Fills staging_list{} by mob_id id_list iterator
------------------------------------------------------------------
function SetOutput(id_list)
	local staging_list = {}
	local iterator = 1
	for iterator = 1, #id_list do
		table.insert(staging_list,{
		mob_id[id_list[iterator]].name,			--1
		mob_id[id_list[iterator]].position, 	--2
		mob_id[id_list[iterator]].conflux,		--3
		mob_id[id_list[iterator]].droppedki, 	--4
		mob_id[id_list[iterator]].popitemrq, 	--5
		mob_id[id_list[iterator]].popitemrq2, 	--6
		mob_id[id_list[iterator]].popitemrq3,	--7
		mob_id[id_list[iterator]].popitemrq4, 	--8
		mob_id[id_list[iterator]].popitemrq5, 	--9
		mob_id[id_list[iterator]].kipops,		--10
		mob_id[id_list[iterator]].tierzero,		--11
		mob_id[id_list[iterator]].atma,			--12
		mob_id[id_list[iterator]].zone			--13
		})
	end
return staging_list
end
------------------------------------------------------------------	
--Removes staging_list elements by output_list matches
------------------------------------------------------------------
function RemoveAlreadyOutput(staging_list)
	if #output_list == 1 then
		if output_list[1][1] == staging_list[1][1] then
			staging_list = {}
			return staging_list
		end
	end
	for iterator1 = 1, #output_list do
		for iterator2 = 1, #staging_list do
			if output_list[iterator1][1] == staging_list[iterator2][1] then
				table.remove(staging_list,iterator2)
				break
			end
		end
	end
	return staging_list
end
------------------------------------------------------------------	
--Fill staging_list{} by search_input. If initial check not found,
--early return. If PIreq1 is zerostring, early return.
--returns staging list filled or empty
------------------------------------------------------------------
function CreateFoundList(user_input)
	id_list = FindFirstIDbySearch(user_input, id_list)
	local rotating_id = CheckIsOrNotFound(id_list)
		if (not rotating_id) then 
			return staging_list 
		end
	id_list = GetHighestTierMobID(id_list)
		if (mob_id[id_list[1]].popitemrq == "") then 
			staging_list = SetOutput(id_list)
			staging_list = RemoveAlreadyOutput(staging_list)
			return staging_list;
		end
	id_list = GetLowerTiersFromUpper(id_list)
	staging_list = SetOutput(id_list)
	if #output_list > 0 then
		staging_list = RemoveAlreadyOutput(staging_list)
	end
	return staging_list;	
end		

------------------------------------------------------------------	
--Create and concatenate string for text output with output_list{}
------------------------------------------------------------------	
function SetListToStringArr(output_list)
	local final_string = ""
	local output_string = ""
	
	--loop through output_list
	for iterator = 1, #output_list do
		--Name, position, conflux, zone
		local output_string = string.format('\n%s is popped at %s near conflux %i in %s.',
		output_list[iterator][1],output_list[iterator][2],output_list[iterator][3],output_list[iterator][13])
			--if available, key item
			if output_list[iterator][4] ~= "" then
				output_string = (output_string .. string.format('\nIt drops the key item %s which pops %s.', output_list[iterator][4],output_list[iterator][10]))
			end
			--if available, pop items
			if output_list[iterator][5] ~= "" then
				output_string = (output_string .. string.format('\nrequired pop items for %s are: %s %s',output_list[iterator][1], output_list[iterator][5],
				output_list[iterator][6]))
			end
			--if available, remaining pop items
			if output_list[iterator][7] ~= "" then
				output_string = (output_string .. string.format('\n%s %s', output_list[iterator][7],output_list[iterator][8],output_list[iterator][9]))
			end
			--if available, tierzero
			if output_list[iterator][11] ~= "" then
				output_string = (output_string .. string.format('\n%s pop item drops from the regular monster %s', output_list[iterator][1], output_list[iterator][11]))
			end
			--if available, atma
			if (output_list[iterator][12] ~= "") then
				output_string = (output_string .. string.format('\nit also drops the atma: %s', output_list[iterator][12]))
			end
			--if item flag
			--if atma flag
			if (atma_flag == true) then
			--if output_list name is atma name and outputlist atma is not blank
				for atma_iterator = 1, 99 do
					if (output_list[iterator][12] ~= "" and output_list[iterator][12] == mob_atma[atma_iterator].atma_name) then
						output_string = (output_string .. string.format('\n%s', mob_atma[atma_iterator].atma_stats))
					end
				end
			end
			--check if final string is blank
			if (final_string == "") then
				final_string = output_string
			end
			--if output_string loop is different from final, concatenate strings with return carriage
			if output_string ~= final_string then
				final_string = final_string .. '\n' ..  output_string
			end
			--if end of loop, return
			if iterator == #output_list then
				return final_string 
			end
	end
end
----------------------------------
--func: ShowAbysRefWindow
----------------------------------

local function ShowAbysRefWindow()
	--set main
	imgui.PushStyleColor(ImGuiCol_TitleBgActive,  1, .4, 0, 1);
	imgui.PushStyleColor(ImGuiCol_WindowBg, 0, 0, 0, 1.7);
	imgui.PushStyleColor(ImGuiCol_Button, 1, .4, 0, 1);
	imgui.PushStyleColor(ImGuiCol_ChildWindowBg, 0, 0, 1, .3)
	imgui.SetNextWindowSize(800, 420);
	imgui.SetNextWindowPos(200, 200);
	imgui.Begin('AbysReference')
	imgui.PushItemWidth(50);
	imgui.PopItemWidth();
	--start Related Mobs child
	imgui.BeginChild('RelatedMobs', 200, 380, true);
	imgui.Indent(40);
	imgui.TextColored(1, .4, 0, 1, 'Related Monsters');
	imgui.Unindent(40);
	imgui.Separator();
	--staging_list was created, create buttons for relatedmobs child
	if staging_list_successful_flag then
		for button_iterator = 1, #staging_list do
			but_title = staging_list[button_iterator][1]
				if but_title then
					if imgui.Button(but_title, 190, 0) then
						table.insert(output_list, staging_list[button_iterator])
						table.remove(staging_list, button_iterator)
						output_string_updated = false
						break
					end
				end
		end
	end
	--related mobs child end
	imgui.EndChild();
	
	--start group
	imgui.SameLine();
	imgui.BeginGroup();
	--start OutputText child, handles searchnotfound, insuficient, and final output
	imgui.BeginChild('OutputText', 0, 210);
	--output_list is available, 
	if (#output_list > 0) then
		--check if output update needed
		if not output_string_updated then
			output_string = SetListToStringArr(output_list)
			output_string_updated = true
		end
		--display output if updated
		if output_string_updated then 
			imgui.TextColored(1, .4, 0, 1, output_string);
		end
	end
	imgui.EndChild();
	
	--start 2nd child
	imgui.BeginChild('OutputButtons', 0, 80 );
	--user_input insuficient text catcher
	if user_input and #user_input <= 3 then
		imgui.TextColored(1, .4, 0, 1, msgs.input_insuficient_length);
		search_not_found_input = user_input;
		user_input_insuficient_flag = true
			--user_input change tracker, stop insuficient message/flag, reset user_input
			if imgui.GetVarValue(name_keyitem_v) ~= search_not_found_input then
				user_input = nil
				user_input_insuficient_flag = false
			end
		end
			
	--search_not_found catcher
	if(search_not_found_flag)then				
		imgui.TextColored(1, .4, 0, 1, msgs.search_not_found);
		search_not_found_input = user_input;
			--user_input change tracker, stop search_not_found message/flag, reset user_input
			if imgui.GetVarValue(name_keyitem_v) ~= search_not_found_input then
				user_input = nil
				search_not_found_flag = false
			end
	end
	--flags for stopping long loops from function
	if not search_not_found_flag and not user_input_insuficient_flag and user_input and not staging_list_successful_flag then
		staging_list = CreateFoundList(user_input);
			--staging filled successfully
			if #staging_list > 0 then 
				staging_list_successful_flag = true
			end
	end
	--output_list available
	if (#output_list > 0) then
		for button_iterator2 = 1, #output_list do
			but_title2 = output_list[button_iterator2][1]
				--create buttons
				if but_title2 then
					if button_iterator2 % 3 ~= 1 then 
						imgui.SameLine() 
					end
					--remove/insert for buttons, flag for updating output
					if imgui.Button(but_title2, 200, 0) then
						table.insert(staging_list, output_list[button_iterator2])
						table.remove(output_list, button_iterator2)
						output_string_updated = false
						break
					end
				end
		end
	end
	imgui.EndChild();
		
	imgui.Indent(20);
		--resets all
		if imgui.Button('Reset Search', 120, 0) then
			user_input = ""
			output_string = nil
			staging_list = {}
			output_list = {}
			id_list = {}
			staging_list_successful_flag = false
			atma_flag = false
		end
		
	
	imgui.SameLine();
		if imgui.Button('Atma' , 120, 0) then
			if (atma_flag == false) then
				atma_flag = true
				else atma_flag = false
			end
			if (#output_list > 0) then
				output_string_updated = false
			end
		end
	imgui.SameLine();
		--New Search, resets staging list/buttons, leaves current output string/button
		if imgui.Button('New Search', 150, 0) then
			id_list = {}
			staging_list = {}
			staging_list_successful_flag = false
			user_input = ""
		end
	imgui.Unindent(20);
		
	imgui.PushItemWidth(397);
		--input box, enter to assign user_input
		if (imgui.InputText('', name_keyitem_v, 64, ImGuiInputTextFlags_EnterReturnsTrue)) then 
			user_input = imgui.GetVarValue(name_keyitem_v);
		end
	imgui.PopItemWidth();
		
	imgui.SameLine();
		--alternative to enter key, assigns search_input
		if imgui.Button('Search',150,0) then
			user_input = imgui.GetVarValue(name_keyitem_v)
		end
		
	imgui.EndGroup();
	imgui.End();
	imgui.PopStyleColor();
	imgui.PopStyleColor();
	imgui.PopStyleColor();
	imgui.PopStyleColor();
end

ashita.register_event('load', function()

end);

ashita.register_event('unload', function()

end);

ashita.register_event('render', function()
if (intro_window_flag) then ShowIntroWindow()
else ShowAbysRefWindow();
end

end);


