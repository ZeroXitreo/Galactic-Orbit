local component = {}
component.dependencies = {"messages", "messages", "roleManager"}
component.title = "Rocket"
component.description = "Rockets a player into the sky"
component.command = "rocket"
component.tip = "[players]"
component.permission = component.title
component.category = "Punishment"
component.guide = {}

component.flyTimer = "orbitRocket"
component.flySound = "weapons/rpg/rocket1.wav"
component.explosionSound = "ambient/explosions/explode_8.wav"

function component:Execute(ply, args)
	local players = galactic.messages:GetPlayers(ply, args)
	players = ply:GetLower(players)

	if #players > 0 then
		for _, pl in ipairs(players) do
			ParticleEffectAttach("Rocket_Smoke_Trail", PATTACH_ABSORIGIN_FOLLOW, pl, 0)
			pl:SetMoveType(MOVETYPE_WALK)
			pl:SetVelocity(Vector(math.Rand(-100, 100), math.Rand(-100, 100), 500))
			pl:EmitSound(component.flySound, 75, 75, .1)

			timer.Simple(.5, function()
				timer.Create(component.flyTimer .. pl:UserID(), 0, 0, function()
					self:Fly(pl)
				end)
			end)

			timer.Simple(2, function()
				self:Explode(pl)
			end)
		end
		galactic.messages:Announce({"blue", ply:Nick()}, {"text", " has made "}, {"red", galactic.messages:PlayersToString(players)}, {"text", " into a rocket"})
	else
		galactic.messages:Notify(ply, {"red", galactic.messages.noPlayersFound})
	end
end

function component:Fly(ply)
	ply:ExitVehicle()
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetVelocity(Vector(ply:GetVelocity().x / 100, ply:GetVelocity().y / 100, 50))
end

function component:Explode(ply)
	ply:StopParticles()
	ply:StopSound(component.flySound)
	ply:EmitSound(component.explosionSound, 511, 100)
	ParticleEffectAttach("explosion_huge_c", PATTACH_ABSORIGIN, ply, 0)
	ParticleEffectAttach("explosion_huge_d", PATTACH_ABSORIGIN, ply, 0)
	ParticleEffectAttach("explosion_huge_g", PATTACH_ABSORIGIN, ply, 0)
	ply:Kill()
	timer.Stop(component.flyTimer .. ply:UserID())
end

galactic:Register(component)