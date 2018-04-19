boss_doom_demonic_servants = class({})

function boss_doom_demonic_servants:GetIntrinsicModifierName()
	return "modifier_boss_doom_demonic_servants_handler"
end

function boss_doom_demonic_servants:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle(self:GetCaster())
	return true
end

function boss_doom_demonic_servants:OnSpellStart()
	self.servants = self:GetSpecialValueFor("servants")
	self.servant_delay = self:GetChannelTime() / self.servants
	self.channelThink = self.servant_delay
	self.angle = 0
	self.radians = 360 / self.servants
end

function boss_doom_demonic_servants:OnChannelThink(dt)
	self.channelThink = self.channelThink + dt
	if self.channelThink > self.servant_delay then
		local caster = self:GetCaster()
		local range = self:GetSpecialValueFor("break_radius") / 2
		self.channelThink = 0
		local position = caster:GetAbsOrigin() + RotateVector2D( caster:GetRightVector(), ToRadians(self.angle) ) * range
		self.angle = self.angle + self.radians
		self:CreateServant(position)
	end
end

function boss_doom_demonic_servants:CreateServant(position)
	local caster = self:GetCaster()
	local servant = CreateUnitByName( "npc_dota_boss35b", position, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
	EmitSoundOn("Hero_DragonKnight.ElderDragonForm", servant)
	ParticleManager:FireParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_POINT_FOLLOW, servant)
end

modifier_boss_doom_demonic_servants_handler = class({})
LinkLuaModifier("modifier_boss_doom_demonic_servants_handler", "bosses/boss_doom/boss_doom_demonic_servants", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_doom_demonic_servants_handler:OnCreated()
	self.dmg = self:GetSpecialValueFor("max_bonus_damage") / self:GetSpecialValueFor("servants")
	self.red = self:GetSpecialValueFor("max_damage_reduction") / self:GetSpecialValueFor("servants")
	
	self.max_dmg = self:GetSpecialValueFor("max_bonus_damage")
	self.max_red = self:GetSpecialValueFor("max_damage_reduction")
	
	self.range = self:GetSpecialValueFor("break_radius")
	if IsServer() then
		self:StartIntervalThink(0.3)
	end
end

function modifier_boss_doom_demonic_servants_handler:OnRefresh()
	self.dmg = self:GetSpecialValueFor("max_bonus_damage") / self:GetSpecialValueFor("servants")
	self.red = self:GetSpecialValueFor("max_damage_reduction") / self:GetSpecialValueFor("servants")
	
	self.max_dmg = self:GetSpecialValueFor("max_bonus_damage")
	self.max_red = self:GetSpecialValueFor("max_damage_reduction")
	
	self.range = self:GetSpecialValueFor("break_radius")
end

function modifier_boss_doom_demonic_servants_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local servants = 0
	for _, servant in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		if servant:GetUnitName() == "npc_dota_boss35b" and servant:HasModifier("modifier_boss_doom_demonic_servants_checker") then
			servants = servants + 1
		end
	end
	self:SetStackCount(servants)
end

function modifier_boss_doom_demonic_servants_handler:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_boss_doom_demonic_servants_handler:GetModifierAura()
	return "modifier_boss_doom_demonic_servants_checker"
end

--------------------------------------------------------------------------------

function modifier_boss_doom_demonic_servants_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_boss_doom_demonic_servants_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_boss_doom_demonic_servants_handler:GetAuraEntityReject(entity)
	return entity == self:GetCaster()
end

--------------------------------------------------------------------------------

function modifier_boss_doom_demonic_servants_handler:GetAuraRadius()
	return self.range
end

function modifier_boss_doom_demonic_servants_handler:GetAuraDuration()
	return 0.5
end

--------------------------------------------------------------------------------
function modifier_boss_doom_demonic_servants_handler:IsPurgeable()
    return false
end

function modifier_boss_doom_demonic_servants_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_doom_demonic_servants_handler:GetModifierDamageOutgoing_Percentage()
	return self.dmg * self:GetStackCount()
end

function modifier_boss_doom_demonic_servants_handler:GetModifierIncomingDamage_Percentage()
	return self.red * self:GetStackCount() * (-1)
end

function modifier_boss_doom_demonic_servants_handler:IsHidden()
    return self:GetStackCount() == 0
end


modifier_boss_doom_demonic_servants_checker = class({})
LinkLuaModifier("modifier_boss_doom_demonic_servants_checker", "bosses/boss_doom/boss_doom_demonic_servants", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_doom_demonic_servants_checker:OnCreated()
	if IsServer() then
		local FX = ParticleManager:CreateParticle("particles/bosses/boss_doom/boss_doom_demonic_servants_link.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(FX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		
		ParticleManager:SetParticleControlEnt(FX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(FX)
	end
end