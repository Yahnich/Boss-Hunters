boss15_peel_the_veil = class({})

function boss15_peel_the_veil:OnSpellStart()
	self.ghostCount = self.ghostCount or 0
	self.ghostLimit = self:GetSpecialValueFor("ghost_count")
	self.ghostSpawnDelay = self:GetChannelTime() / self:GetSpecialValueFor("ghost_count")
	self.ghostSpawner = 0
end

function boss15_peel_the_veil:OnChannelThink(dt)
	self.ghostSpawner = self.ghostSpawner + dt
	if self.ghostSpawner >= self.ghostSpawnDelay then
		self:CreateGhost()
		self.ghostSpawner = 0
	end
end

function boss15_peel_the_veil:CreateGhost()
	if self.ghostCount < self.ghostLimit then self.ghostCount = math.min(self.ghostCount + 1, self.ghostCount)
	else
		self:GetCaster():Interrupt()
	end
	local ghost = CreateUnitByName("npc_dota_boss22b", self:GetCaster():GetAbsOrigin() + ActualRandomVector(300, 200), true, nil, nil, self:GetTeam())
	ghost.hasBeenInitialized = true
	ghost:SetAverageBaseDamage(self:GetCaster():GetAverageBaseDamage() * self:GetSpecialValueFor("ghost_damage")/100, 25)
	ghost:SetBaseMaxHealth(self:GetCaster():GetBaseMaxHealth() * self:GetSpecialValueFor("ghost_health")/100)
	ghost:SetMaxHealth(self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("ghost_health")/100)
	ghost:SetHealth(ghost:GetMaxHealth())
	ghost:AddNewModifier(self:GetCaster(), self, "modifier_boss15_peel_the_veil_phased", {})
	Timers:CreateTimer(0.2, function()
		if not ghost:IsNull() and ghost:IsAlive() then
			return 0.2
		else
			self.ghostCount = self.ghostCount - 1
		end
	end)
end

function boss15_peel_the_veil:GetGhostCount()
	return self.ghostCount or 0
end

modifier_boss15_peel_the_veil_phased = class({})
LinkLuaModifier("modifier_boss15_peel_the_veil_phased", "bosses/boss15/boss15_peel_the_veil.lua", 0)

function modifier_boss15_peel_the_veil_phased:IsHidden()
	return true
end

function modifier_boss15_peel_the_veil_phased:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end