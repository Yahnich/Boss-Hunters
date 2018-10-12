boss_reaper_necrotic_hail = class({})

function boss_reaper_necrotic_hail:OnAbilityPhaseStart()
	local radius = self:GetSpecialValueFor("radius")
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), radius)
	return true
end

function boss_reaper_necrotic_hail:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	
	local soundBites = 5
	Timers:CreateTimer(function()
		EmitSoundOnLocationWithCaster(target + RandomVector(radius), "Hero_Clinkz.SearingArrows.Impact", caster)
		soundBites = soundBites - 1
		if soundBites > 0 then
			return 0.05
		end
	end)
	ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_CUSTOMORIGIN, caster, {	[0] = target, 
																																			[4] = Vector(radius + 150,1,1),
																																			[5] = Vector(radius + 150,1,1)} )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target, radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL})
			enemy:AddNewModifier(caster, self, "modifier_boss_reaper_necrotic_hail", {duration = duration})
		end
	end
end

modifier_boss_reaper_necrotic_hail = class({})
LinkLuaModifier("modifier_boss_reaper_necrotic_hail", "bosses/boss_wk/boss_reaper_necrotic_hail", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_reaper_necrotic_hail:OnCreated()
	self.healRed = self:GetSpecialValueFor("heal_reduction")
	self.dmgAmp = self:GetSpecialValueFor("damage_amp")
end

function modifier_boss_reaper_necrotic_hail:OnCreated()
	self.healRed = self:GetSpecialValueFor("heal_reduction")
	self.dmgAmp = self:GetSpecialValueFor("damage_amp")
end

function modifier_boss_reaper_necrotic_hail:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_reaper_necrotic_hail:GetModifierHealAmplify_Percentage()
	return self.healRed
end

function modifier_boss_reaper_necrotic_hail:GetModifierIncomingDamage_Percentage()
	return self.dmgAmp
end