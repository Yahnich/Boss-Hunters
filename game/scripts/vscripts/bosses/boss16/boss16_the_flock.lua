boss16_the_flock = class({})

function boss16_the_flock:GetIntrinsicModifierName()
	return "modifier_boss16_the_flock_manager"
end

function boss16_the_flock:OnSpellStart()
	self.drakeCount = self.drakeCount or {}
	self.drakeLimit = self:GetSpecialValueFor("drake_count")
	self:ReplaceDrakes()
	for i = 1, self.drakeLimit do
		self:CreateDrake()
	end
	EmitSoundOn("Hero_DragonKnight.ElderDragonForm", self:GetCaster())
end

function boss16_the_flock:ReplaceDrakes()
	for _, drake in ipairs(self.drakeCount) do
		if drake then drake:ForceKill(false) end
	end
	self.drakeCount = {}
end

function boss16_the_flock:CreateDrake()
	local drake = CreateUnitByName("npc_dota_boss23_m", self:GetCaster():GetAbsOrigin() + ActualRandomVector(600, 400), true, drake, drake, self:GetCaster():GetTeam())
	drake:SetAverageBaseDamage(self:GetCaster():GetAverageBaseDamage() * self:GetSpecialValueFor("drake_damage")/100, 25)
	drake:SetBaseMaxHealth(self:GetCaster():GetBaseMaxHealth() * self:GetSpecialValueFor("drake_health")/100)
	drake:SetMaxHealth(self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("drake_health")/100)
	drake:SetHealth(drake:GetMaxHealth())
	ParticleManager:FireParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_POINT_FOLLOW, drake)
	drake.owningDragon = self:GetCaster()
	table.insert(self.drakeCount, drake)
	if self:GetCaster():GetHealthPercent() < 66 then
		drake:AddAbility("boss16_conflagration"):SetLevel( self:GetLevel() )
	end
	if self:GetCaster():GetHealthPercent() < 33 then
		drake:AddAbility("boss16_dragonfire"):SetLevel( self:GetLevel() )
	end
end

function boss16_the_flock:GetDrakeCount()
	self.drakeCount = self.drakeCount or {}
	return #self.drakeCount or 0
end


modifier_boss16_the_flock_manager = class({})
LinkLuaModifier("modifier_boss16_the_flock_manager", "bosses/boss16/boss16_the_flock.lua", 0)

function modifier_boss16_the_flock_manager:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss16_the_flock_manager:OnDeath(params)
	if params.unit == self:GetParent() then
		local dragon
		for id, drake in ipairs(self:GetAbility().drakeCount) do
			if not drake:IsNull() and drake:IsAlive() then
				drake:ForceKill(false)
				dragon = CreateUnitByName("npc_dota_boss23", drake:GetAbsOrigin(), true, nil, nil, drake:GetTeam())
				self:GetAbility().drakeCount[id] = nil
				break
			end
		end
		local dragonAb = dragon:FindAbilityByName("boss16_the_flock")
		dragonAb.drakeCount = {}
		for _, drake in pairs(self:GetAbility().drakeCount) do
			drake.owningDragon = dragon
			table.insert(dragonAb.drakeCount, drake)
		end
		dragonAb:StartCooldown(5)
	end
end