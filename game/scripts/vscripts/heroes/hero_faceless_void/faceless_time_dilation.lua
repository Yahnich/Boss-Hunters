faceless_time_dilation = class({})

function faceless_time_dilation:IsStealable()
	return true
end

function faceless_time_dilation:IsHiddenWhenStolen()
	return false
end

function faceless_time_dilation:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_FacelessVoid.TimeDilation.Cast", caster)
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	
	caster:AddNewModifier( caster, self, "modifier_faceless_time_dilation_handle", {duration = duration} )
	if caster:HasScepter() then
		caster:AddNewModifier( caster, self, "modifier_faceless_time_dilation_handle_ally", {duration = duration} )
	else
		caster:AddNewModifier( caster, self, "modifier_faceless_time_dilation_buff", {duration = duration} )
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector(radius, radius, radius)} )
	if caster:HasTalent("special_bonus_unique_faceless_time_dilation_2") then
		local chrono = caster:FindAbilityByName("faceless_chrono")
		if chrono then
			chrono:CreateChronosphere( caster:GetAbsOrigin(), nil, caster:FindTalentValue("special_bonus_unique_faceless_time_dilation_2") )
		end
	end
end

modifier_faceless_time_dilation_handle_ally = class({})
LinkLuaModifier( "modifier_faceless_time_dilation_handle_ally", "heroes/hero_faceless_void/faceless_time_dilation.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_faceless_time_dilation_handle_ally:OnCreated(kv)
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_faceless_time_dilation_handle_ally:IsAura()
    return self:GetCaster():HasScepter()
end

function modifier_faceless_time_dilation_handle_ally:GetAuraDuration()
    return 0.1
end

function modifier_faceless_time_dilation_handle_ally:GetAuraRadius()
    return self.radius
end

function modifier_faceless_time_dilation_handle_ally:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_faceless_time_dilation_handle_ally:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_faceless_time_dilation_handle_ally:GetModifierAura()
    return "modifier_faceless_time_dilation_buff"
end

function modifier_faceless_time_dilation_handle_ally:IsHidden()
	return true
end

modifier_faceless_time_dilation_buff = class({})
LinkLuaModifier( "modifier_faceless_time_dilation_buff", "heroes/hero_faceless_void/faceless_time_dilation.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_faceless_time_dilation_buff:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("attack_speed_buff")
	self.cdr = (self:GetSpecialValueFor("cdr_buff")/100) * 0.1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_faceless_time_dilation_buff:OnIntervalThink()
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() - 1 do
		local ability = parent:GetAbilityByIndex( i )
		if ability and not ability:IsCooldownReady() then
			ability:ModifyCooldown( -self.cdr  )
		end
	end
end

function modifier_faceless_time_dilation_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_faceless_time_dilation_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end
function modifier_faceless_time_dilation_buff:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_time_walk_slow.vpcf"
end

modifier_faceless_time_dilation_handle = class({})
LinkLuaModifier( "modifier_faceless_time_dilation_handle", "heroes/hero_faceless_void/faceless_time_dilation.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_faceless_time_dilation_handle:OnCreated(kv)
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_faceless_time_dilation_handle:IsAura()
    return true
end

function modifier_faceless_time_dilation_handle:GetAuraDuration()
    return 0.1
end

function modifier_faceless_time_dilation_handle:GetAuraRadius()
    return self.radius
end

function modifier_faceless_time_dilation_handle:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_faceless_time_dilation_handle:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_faceless_time_dilation_handle:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_faceless_time_dilation_handle:GetModifierAura()
    return "modifier_faceless_time_dilation_debuff"
end

function modifier_faceless_time_dilation_handle:IsHidden()
	return not self:GetCaster():HasScepter()
end

modifier_faceless_time_dilation_debuff = class({})
LinkLuaModifier( "modifier_faceless_time_dilation_debuff", "heroes/hero_faceless_void/faceless_time_dilation.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_faceless_time_dilation_debuff:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("attack_speed_debuff")
	self.cdr = (self:GetSpecialValueFor("cdr_debuff")/100) * 0.1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_faceless_time_dilation_debuff:OnIntervalThink()
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() - 1 do
		local ability = parent:GetAbilityByIndex( i )
		if ability and not ability:IsCooldownReady() then
			ability:ModifyCooldown( self.cdr  )
		end
	end
end

function modifier_faceless_time_dilation_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_faceless_time_dilation_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_faceless_time_dilation_debuff:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_time_walk_slow.vpcf"
end