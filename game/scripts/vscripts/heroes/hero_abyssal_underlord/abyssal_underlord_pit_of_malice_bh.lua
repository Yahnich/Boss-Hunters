abyssal_underlord_pit_of_malice_bh = class({})
LinkLuaModifier( "modifier_abyssal_underlord_pit_of_malice_bh", "heroes/hero_abyssal_underlord/abyssal_underlord_pit_of_malice_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_abyssal_underlord_pit_of_malice_bh_root_handle", "heroes/hero_abyssal_underlord/abyssal_underlord_pit_of_malice_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_abyssal_underlord_pit_of_malice_bh_root", "heroes/hero_abyssal_underlord/abyssal_underlord_pit_of_malice_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_abyssal_underlord_pit_of_malice_bh_talent", "heroes/hero_abyssal_underlord/abyssal_underlord_pit_of_malice_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function abyssal_underlord_pit_of_malice_bh:IsStealable()
    return true
end

function abyssal_underlord_pit_of_malice_bh:IsHiddenWhenStolen()
    return false
end

function abyssal_underlord_pit_of_malice_bh:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function abyssal_underlord_pit_of_malice_bh:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local radius = self:GetTalentSpecialValueFor("radius")
	caster:EmitSound("Hero_AbyssalUnderlord.PitOfMalice.Start")
	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_pitofmalice_pre.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(self.nfx, 0, point)
                ParticleManager:SetParticleControl(self.nfx, 1, Vector(radius, radius, radius))

    return true
end

function abyssal_underlord_pit_of_malice_bh:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.nfx)
	caster:StopSound("Hero_AbyssalUnderlord.PitOfMalice.Start")
end

function abyssal_underlord_pit_of_malice_bh:OnSpellStart()
	local caster = self:GetCaster()
    local point = self:GetCursorPosition()
	
	if self.nfx then
		ParticleManager:ClearParticle(self.nfx)
	end
	
	caster:EmitSound("Hero_AbyssalUnderlord.PitOfMalice")
    CreateModifierThinker(caster, self, "modifier_abyssal_underlord_pit_of_malice_bh", {Duration = self:GetTalentSpecialValueFor("duration")}, point, caster:GetTeam(), false)
end

modifier_abyssal_underlord_pit_of_malice_bh = class({})
function modifier_abyssal_underlord_pit_of_malice_bh:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        local point = self:GetParent():GetAbsOrigin()

        local radius = self:GetSpecialValueFor("radius")
        local duration = self:GetDuration()

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_pitofmalice.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(nfx, 0, point)
                    ParticleManager:SetParticleControl(nfx, 1, Vector(radius, 10, radius))
                    ParticleManager:SetParticleControl(nfx, 2, Vector(duration, 0, 0))
        self:AttachEffect(nfx)
    end
end

function modifier_abyssal_underlord_pit_of_malice_bh:IsAura()
    return true
end

function modifier_abyssal_underlord_pit_of_malice_bh:GetAuraDuration()
    return 0.1
end

function modifier_abyssal_underlord_pit_of_malice_bh:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_abyssal_underlord_pit_of_malice_bh:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_abyssal_underlord_pit_of_malice_bh:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_abyssal_underlord_pit_of_malice_bh:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_abyssal_underlord_pit_of_malice_bh:GetModifierAura()
    return "modifier_abyssal_underlord_pit_of_malice_bh_root_handle"
end


modifier_abyssal_underlord_pit_of_malice_bh_root_handle = class({})
function modifier_abyssal_underlord_pit_of_malice_bh_root_handle:IsHidden()
    return true
end

function modifier_abyssal_underlord_pit_of_malice_bh_root_handle:OnCreated(table)
    if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = caster:FindAbilityByName("abyssal_underlord_pit_of_malice_bh")
		
		if caster:IsSameTeam(parent) then
			if caster == parent and caster:HasTalent("special_bonus_unique_abyssal_underlord_pit_of_malice_1") then
				parent:AddNewModifier( caster, ability, "modifier_abyssal_underlord_pit_of_malice_bh_talent", {})
			end
		else
			local duration = self:GetSpecialValueFor("ensnare_duration")

			parent:AddNewModifier(caster, ability, "modifier_abyssal_underlord_pit_of_malice_bh_root", {Duration = duration})
			self:StartIntervalThink( self:GetTalentSpecialValueFor("interval") )
		end
    end
end

function modifier_abyssal_underlord_pit_of_malice_bh_root_handle:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_abyssal_underlord_pit_of_malice_bh_talent")
	end
end

function modifier_abyssal_underlord_pit_of_malice_bh_root_handle:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = caster:FindAbilityByName("abyssal_underlord_pit_of_malice_bh")

    local duration = self:GetSpecialValueFor("ensnare_duration")

    parent:AddNewModifier(caster, ability, "modifier_abyssal_underlord_pit_of_malice_bh_root", {Duration = duration})
end

modifier_abyssal_underlord_pit_of_malice_bh_root = class({})
function modifier_abyssal_underlord_pit_of_malice_bh_root:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()

        local damage = self:GetSpecialValueFor("damage")
		parent:EmitSound("Hero_AbyssalUnderlord.Pit.TargetHero")
        ability:DealDamage(caster, parent, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		if caster:HasTalent("special_bonus_unique_abyssal_underlord_pit_of_malice_2") then
			self.dmg = caster:GetAverageTrueAttackDamage(caster) * caster:FindTalentValue("special_bonus_unique_abyssal_underlord_pit_of_malice_2") / 100
			local ticks = math.floor( self:GetRemainingTime() / 0.49 )
			self.dmg = self.dmg / math.max( ticks, 1 )
			if ticks > 0 then
				self:StartIntervalThink(0.49)
			else
				self:OnIntervalThink()
			end
		end
    end
end

function modifier_abyssal_underlord_pit_of_malice_bh_root:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	ability:DealDamage( caster, parent, self.dmg, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end

function modifier_abyssal_underlord_pit_of_malice_bh_root:IsDebuff()
    return true
end

function modifier_abyssal_underlord_pit_of_malice_bh_root:GetEffectName()
    return "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf"
end

function modifier_abyssal_underlord_pit_of_malice_bh_root:CheckState()
    local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVISIBLE] = false}
    return state
end

modifier_abyssal_underlord_pit_of_malice_bh_talent = class({})

function modifier_abyssal_underlord_pit_of_malice_bh_talent:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_pit_of_malice_1", "as")
	self.dmg = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_pit_of_malice_1", "dmg")
end

function modifier_abyssal_underlord_pit_of_malice_bh_talent:DeclareFunctions()
	return {  MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_abyssal_underlord_pit_of_malice_bh_talent:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_abyssal_underlord_pit_of_malice_bh_talent:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg
end