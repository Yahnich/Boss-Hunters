night_stalker_crippling_fear_bh = class({})

function night_stalker_crippling_fear_bh:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function night_stalker_crippling_fear_bh:GetCooldown(nLvl)
	if GameRules:IsDaytime() then
		return self:GetTalentSpecialValueFor("cooldown_day")
	else
		return self:GetTalentSpecialValueFor("cooldown_night")
	end
end

function night_stalker_crippling_fear_bh:GetCastRange( position, target )
	if GameRules:IsDaytime() then
		return self:GetTalentSpecialValueFor("radius_day")
	else
		return self:GetTalentSpecialValueFor("radius_night")
	end
end

function night_stalker_crippling_fear_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Nightstalker.Trickling_Fear", caster)
	caster:AddNewModifier(caster, self, "modifier_night_stalker_crippling_fear_bh", {duration = duration})
end

modifier_night_stalker_crippling_fear_bh = class({})
LinkLuaModifier("modifier_night_stalker_crippling_fear_bh", "heroes/hero_night_stalker/night_stalker_crippling_fear_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_crippling_fear_bh:OnCreated()
	self.radius = TernaryOperator( self:GetTalentSpecialValueFor("radius_day"), GameRules:IsDaytime(), self:GetTalentSpecialValueFor("radius_night") )
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
		local sFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(sFX, 2, Vector(self.radius,self.radius,self.radius) )
		self:AddEffect(sFX)
	end
end

function modifier_night_stalker_crippling_fear_bh:OnRefresh()
	self.radius = TernaryOperator( self:GetTalentSpecialValueFor("radius_day"), GameRules:IsDaytime(), self:GetTalentSpecialValueFor("radius_night") )
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_night_stalker_crippling_fear_bh:OnDestroy()
	if IsServer() then
		EmitSoundOn("Hero_Nightstalker.Trickling_Fear_end", self:GetParent() )
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_night_stalker_crippling_fear_bh:IsAura()
	return true
end

function modifier_night_stalker_crippling_fear_bh:GetModifierAura()
	return "modifier_night_stalker_crippling_fear_bh_silence"
end

function modifier_night_stalker_crippling_fear_bh:GetAuraRadius()
	return self.radius
end

function modifier_night_stalker_crippling_fear_bh:GetAuraDuration()
	return 0.5
end

function modifier_night_stalker_crippling_fear_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_night_stalker_crippling_fear_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_night_stalker_crippling_fear_bh_silence = class({})
LinkLuaModifier("modifier_night_stalker_crippling_fear_bh_silence", "heroes/hero_night_stalker/night_stalker_crippling_fear_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_crippling_fear_bh_silence:OnCreated()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_night_stalker_crippling_fear_2")
end

function modifier_night_stalker_crippling_fear_bh_silence:OnRefresh()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_night_stalker_crippling_fear_2")
end

function modifier_night_stalker_crippling_fear_bh_silence:GetEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear.vpcf"
end

function modifier_night_stalker_crippling_fear_bh_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_night_stalker_crippling_fear_bh_silence:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_night_stalker_crippling_fear_bh_silence:GetModifierAttackSpeedBonus_Constant()
	return self.slow
end

function modifier_night_stalker_crippling_fear_bh_silence:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end