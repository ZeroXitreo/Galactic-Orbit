local component = {}
component.namespace = "orbitalVote"
component.title = "Vote"
component.description = "Start a vote"
component.command = "vote"
component.tip = "<question> <option> <option> [...]"
component.permission = component.title

component.nStrStart = "StartVotation"
component.nStrEnd = "EndVotation"
component.nStrGetAnswer = "GetVotationAnswer"

component.questionTimer = 10

if SERVER then
	component.activeQuestion = false
	component.playersAnswers = {}
	component.question = ""
	component.answers = {}
	component.callback = nil
	component.timerIdentifier = "OrbVoteTimerIdentifier"

	component.dependencies = {"messages", "messages"}
else
	component.dependencies = {"theme"}
	component.ui = nil
end

function component:Constructor()
	if SERVER then
		util.AddNetworkString(component.nStrStart)
		util.AddNetworkString(component.nStrEnd)
		util.AddNetworkString(component.nStrGetAnswer)

		net.Receive(self.nStrGetAnswer, function(length, ply)
			self:RecievePlayerAnswer(ply, net.ReadUInt(8))
		end)
	else
		net.Receive(self.nStrStart, function(length)
			local question = net.ReadString()
			local args = {}

			for i = 1, net.ReadUInt(8) do
				table.insert(args, net.ReadString())
			end

			self:StartVotation(question, args)
		end)

		net.Receive(self.nStrEnd, function(length, ply)
			self:NetworkVoteEnd()
		end)
	end
end

function component:NetworkVoteEnd()
	if SERVER then
		net.Start(self.nStrEnd)
		net.Broadcast()
	else
		self:RemoveVotation()
	end
end

if SERVER then
	function component:Execute(ply, args)
		if not self.activeQuestion then
			if #player.GetAll() > 1 then
				if #args > 0 then
					if #args > 1 then
						if #args > 2 then
							local question = table.remove(args, 1)
							self:StartVotation(question, args)
							local announcement = {}
							table.insert(announcement, {"blue", ply:Nick()})
							table.insert(announcement, {"text", " has started a vote: "})
							table.insert(announcement, {"red", question})
							galactic.messages:Announce(unpack(announcement))
						else
							galactic.messages:Notify(ply, {"red", "There has to be at least two options"})
						end
					else
						galactic.messages:Notify(ply, {"red", "You haven't specified any options"})
					end
				else
					galactic.messages:Notify(ply, {"red", "You haven't specified a question"})
				end
			else
				galactic.messages:Notify(ply, {"red", "There aren't enough players to start a vote"})
			end
		else
			galactic.messages:Notify(ply, {"red", "You can't start a new vote until the current one has finished"})
		end
	end
end

if SERVER then
	function component:CallVote(ply, args, returnFunc)
		if returnFunc then
			self.callback = returnFunc
		end
		self:Execute(ply, args)
	end
end

if SERVER then
	function component:RecievePlayerAnswer(ply, answer)
		if not self.activeQuestion then return end

		self.playersAnswers[ply] = answer

		net.Start(self.nStrGetAnswer)

			net.WriteEntity(ply)
			net.WriteUInt(answer, 8)

		net.Broadcast()

		if table.Count(self.playersAnswers) == #player.GetHumans() then
			self:EndVotation()
		end
	end
end

if SERVER then
	function component:EndVotation()

		timer.Remove(self.timerIdentifier)

		if not self.activeQuestion then return end

		self.activeQuestion = false

		self:NetworkVoteEnd()

		local answerVotes = {}

		local announcement = {}
		table.insert(announcement, {"blue", self.question})
		table.insert(announcement, {"text", " results: "})

		for i, answer in ipairs(self.answers) do

			local totalVotes = 0
			local currentVotes = 0

			for _, plyAnswer in pairs(self.playersAnswers) do
				totalVotes = totalVotes + 1
				if plyAnswer == i then
					currentVotes = currentVotes + 1
				end
			end

			if totalVotes == 0 then
				totalVotes = 1
			end

			if i > 1 then
				if #self.answers == i then
					table.insert(announcement, {"text", " and "})
				else
					table.insert(announcement, {"text", ", "})
				end
			end

			table.insert(announcement, {"red", answer})
			table.insert(announcement, {"yellow", " (" .. currentVotes / totalVotes * 100 .. "%)"})

			answerVotes[i] = currentVotes
		end

		galactic.messages:Announce(unpack(announcement))

		if self.callback then
			self:callback(answerVotes)
			self.callback = nil
		end

	end

end

function component:StartVotation(question, answers)
	if SERVER then
		self.activeQuestion = true
		self.playersAnswers = {}
		self.question = question
		self.answers = answers

		net.Start(self.nStrStart)

			net.WriteString(question)
			net.WriteUInt(#answers, 8)

			for _, arg in ipairs(answers) do
				net.WriteString(arg)
			end

		net.Broadcast()

		timer.Create(self.timerIdentifier, self.questionTimer, 1, function() self:EndVotation() end)
	else
		self.ui = vgui.Create("DFrame")
		self.ui:Dock(FILL)
		self.ui:SetSize(ScrW(), ScrH())
		self.ui:MakePopup()
		self.ui:SetKeyboardInputEnabled(false)
		self.ui:SetMouseInputEnabled(true)
		self.ui:SetBackgroundBlur(true)
		self.ui:SetDraggable(false)
		self.ui:SetSizable(false)
		self.ui:ShowCloseButton(false)
		self.ui:SetTitle("")
		self.ui.title = question
		self.ui:SetDraggable(false)
		self.ui.Paint = function(pnl, w, h)


			local procentLeft = (self.ui.endTime - RealTime()) / self.questionTimer


			galactic.theme:DrawBlurRect(0, 0, ScrW(), ScrH(), 5)
			surface.SetDrawColor(galactic.theme.colors.blockFaint.r, galactic.theme.colors.blockFaint.g, galactic.theme.colors.blockFaint.b, 50)
			surface.DrawRect(0, 0, ScrW(), ScrH())
			local sizeStop = h/4
			local sizeStart = h/7
			w = w/2
			h = h/2
			//local answers = {"Monday","Tuesday","Well this isn't really a question, is it?","Thursday","Friday","Saturday","Sunday","Monday","Tuesday","Tuesday","Saturday","Sunday","Monday","Tuesday","Tuesday"}
			local curX, curY = input.GetCursorPos()
			local localX, localY = pnl:GetPos()
			curX = curX - localX
			curY = curY - localY

			a = curX - w
			b = h - curY
			c = math.sqrt(math.pow(a, 2) + math.pow(b, 2))
			angA = math.asin(a/c)
			local circularAngle

			if a >= 0 then
				if b >= 0 then
					circularAngle = angA
				else
					circularAngle = math.pi - angA
				end
			else
				if b >= 0 then
					circularAngle = math.pi * 2 + angA
				else
					circularAngle = math.pi - angA
				end
			end

			local angleProcent = circularAngle / math.pi / 2

			local hoveredAnswer = ""

			if not pnl.AnswerMovement then
				pnl.AnswerMovement = {}
			end

			draw.NoTexture()
			for i = 0, #answers - 1 do
				local answer = answers[i + 1]

				if not pnl.AnswerMovement[i] then
					pnl.AnswerMovement[i] = 0
				end

				local localSize = .9 + pnl.AnswerMovement[i] / 10

				local isInSize = false

				if c > sizeStart and c < sizeStop * localSize then
					isInSize = true
				end

				local procentage = i / #answers
				local procentageEnd = (i + 1) / #answers
				local dots = math.ceil(64 / #answers)

				local localSizeScale = 0
				local col = galactic.theme.colors.blockFaint

				if angleProcent >= procentage and angleProcent < procentageEnd and isInSize then
					localSizeScale = 1
					hoveredAnswer = answer
					col = galactic.theme.colors.blue
					pnl:SetCursor("hand")
					if input.IsMouseDown(MOUSE_LEFT) then
						self:SelectAnswer(i + 1)
					end
				end
				pnl.AnswerMovement[i] = galactic.theme:PredictNextMove(pnl.AnswerMovement[i], localSizeScale)

				surface.SetDrawColor(galactic.theme:Blend(galactic.theme.colors.blockFaint, galactic.theme.colors.blue, pnl.AnswerMovement[i]))
				galactic.theme:DrawArch(w, h, sizeStart, sizeStop * localSize, math.pi * 2 * procentage, math.pi * 2 * 1 / #answers, 64)
				
				local procentageCenter = ((procentageEnd - procentage)/2 + procentage)
				local textX = w + math.cos(-math.pi/2 + math.pi * 2 * procentageCenter) * (sizeStart * localSize + (sizeStop - sizeStart * localSize) / 2)
				local textY = h + math.sin(-math.pi/2 + math.pi * 2 * procentageCenter) * (sizeStart * localSize + (sizeStop - sizeStart * localSize) / 2)

				draw.SimpleText(string.sub(answer, 0, 3), "GalacticDefault", textX, textY, galactic.theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			surface.SetDrawColor(galactic.theme.colors.red:Unpack())
			galactic.theme:DrawArch(w, h, sizeStart * .9, sizeStart, 0, math.pi * 2 * (1 - procentLeft), 64)
			draw.SimpleText(pnl.title, "GalacticH1", w, h - sizeStop - galactic.theme.rem * 5, galactic.theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw.SimpleText(hoveredAnswer, "GalacticH1", w, h, galactic.theme.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		self.ui.endTime = RealTime() + self.questionTimer

		self.ui:Center()
	end
end

if CLIENT then
	function component:SelectAnswer(number)
		net.Start(self.nStrGetAnswer)
			net.WriteUInt(number, 8)
		net.SendToServer()
		self:RemoveVotation()
	end
end

if CLIENT then
	function component:RemoveVotation()
		if self.ui then
			self.ui:Remove()
		end
	end
end

galactic:Register(component)
