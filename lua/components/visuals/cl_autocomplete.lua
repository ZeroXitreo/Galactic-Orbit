local component = {}
component.dependencies = {"anchor", "theme", "roleManager", "permissionManager"}
component.title = "Chat Autocomplete"
component.description = "Provides autocomplete for chat functionality"

component.chatOpen = false
component.suggestions = {}
component.prefix = ""

function component:HUDPaint()
	if ( self.chatOpen ) then
		local chatW, chatH = chat.GetChatBoxSize()
		local chatX, chatY = chat.GetChatBoxPos()
		x = chatX + chatW + galactic.theme.rem
		y = chatY
		
		for _, suggestion in ipairs(self.suggestions) do
			local sx, sy = draw.SimpleText(component.prefix .. suggestion.command, "GalacticDefault", x, y, galactic.theme.colors.yellow)
			if suggestion.tip then
				draw.SimpleText(" " .. suggestion.tip, "GalacticDefault", x + sx, y, galactic.theme.colors.text)
			end
			y = y + sy
			if y + sy >= chatY + chatH then
				break
			end
		end
	end
end

function component:ChatTextChanged(str)
	if type(str) == "table" then str = str[1] end
	local prefixes = {"/", "!", "@"}
	self.suggestions = {}
	self.prefix = str:Left(1)
	if table.HasValue(prefixes, string.Left(str, 1)) then
		local com = string.sub( str, 2, ( string.find( str, " " ) or ( #str + 1 ) ) - 1 )
		for _, v in pairs(galactic.permissionManager.permissions) do
			if v.commands then
				for command, properties in pairs(v.commands) do
					if LocalPlayer():HasPermission(v.permission) and string.sub(command, 0, #com) == com:lower() then
						table.insert(self.suggestions, {command = command, tip = properties.tip or ""})
					end
				end
			end
		end
		table.SortByMember(self.suggestions, "command", true)
	end
end

function component:OnChatTab(str)

	local str = str:Trim()

	if #str:Split(' ') == 1 and not table.IsEmpty(self.suggestions) then

		local commandStr = str:Right(#str - 1)
		print(commandStr)

		local position = 1
		for i, v in ipairs(self.suggestions) do
			if v.command == commandStr then
				if #self.suggestions > i then
					position = i + 1
				else
					position = 1
				end
			end
		end

		return str:Left(1) .. self.suggestions[position].command .. " "
	end
end

function component:StartChat()
	self.chatOpen = true
end

function component:FinishChat()
	self.chatOpen = false
end

galactic:Register( component )
