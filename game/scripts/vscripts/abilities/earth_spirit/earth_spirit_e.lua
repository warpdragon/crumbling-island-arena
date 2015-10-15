earth_spirit_e = class({})
LinkLuaModifier("modifier_earth_spirit_e", "abilities/earth_spirit/modifier_earth_spirit_e", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_e:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local hero = caster.hero
	local targetRemnant = hero:FindRemnantInArea(target, 200)
	local hadStand = false
	local facing = target - hero:GetPos()
	facing.z = 0

	if targetRemnant then
		target = targetRemnant:GetPos()
	end

	hero:AddNewModifier(hero, self, "modifier_earth_spirit_e", {})
	hero:SetFacing(facing)

	if hero:HasRemnantStand() then
		hadStand = true
		hero:RemoveRemnantStand()
	end

	local dashData = {}
	dashData.unit = caster
	dashData.to = target
	dashData.velocity = 600
	dashData.findClearSpace = false
	dashData.onArrival = 
		function (unit)
			hero:RemoveModifier("modifier_earth_spirit_e")

			if targetRemnant and not targetRemnant.destroyed then
				hero:SetRemnantStand(targetRemnant)
				hero:SetPos(Vector(target.x, target.y, target.z + 150))
			end
		end

	dashData.heightFunction = 
		function (from, to, result)
			local d = (from - to):Length2D()
			local x = (from - result):Length2D()
			local y0 = 0
			local y1 = 0

			if hadStand then
				y0 = 150
			end

			if targetRemnant and not targetRemnant.destroyed then
				y1 = 150
			end

			return ParabolaZ2(y0, y1, 100, d, x)
		end

	Spells:Dash(dashData)
end