doom_scorched_earth_ebf = class({})

function doom_scorched_earth_ebf:IsStealable()
	return true
end

function doom_scorched_earth_ebf:IsHiddenWhenStolen()
	return false
end

function doom_scorched_earth_ebf:OnSpellStart()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doom_scorched_earth_aura", {duration = self:GetTalentSpecialValueFor("duration")})
		if self:GetCaster():HasTalent("special_bonus_unique_doom_4") and not self:GetCaster():HasModifier("modifier_doom_scorched_earth_talent") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doom_scorched_earth_talent", {})
		end
	end
end

LinkLuaModifier( "modifier_doom_scorched_earth_aura", "heroes/hero_doom/doom_scorched_earth_ebf" ,LUA_MODIFIER_MOTION_NONE )
modifier_doom_scorched_earth_aura = class({})

function modifier_doom_scorched_earth_aura:OnCreated()
	self.aura_radius = self:GetAbility():GetTalentSpecialValueFor("radius")
	if IsServer() then
		EmitSoundOn("Hero_DoomBringer.ScorchedEarthAura", self:GetParent())
		self.FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( self.FXIndex, 1, Vector(self.aura_radius, 0, 0) )
	end
end

function modifier_doom_scorched_earth_aura:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_DoomBringer.ScorchedEarthAura", self:GetParent())
		ParticleManager:DestroyParticle(self.FXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.FXIndex)
	end
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetModifierAura(params)
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return "modifier_doom_scorched_earth_buff"
	else
		return "modifier_doom_scorched_earth_debuff"
	end
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_doom_scorched_earth_aura:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_doom_scorched_earth_aura:IsPurgable()
    return false
end

LinkLuaModifier( "modifier_doom_scorched_earth_talent", "heroes/hero_doom/doom_scorched_earth_ebf" ,LUA_MODIFIER_MOTION_NONE )
modifier_doom_scorched_earth_talent = class({})

function modifier_doom_scorched_earth_talent:IsHidden()
	return true
end

function modifier_doom_scorched_earth_talent:RemoveOnDeath()
	return false
end


LinkLuaModifier( "modifier_doom_scorched_earth_buff", "heroes/hero_doom/doom_scorched_earth_ebf" ,LUA_MODIFIER_MOTION_NONE )
modifier_doom_scorched_earth_buff = class({})

function modifier_doom_scorched_earth_buff:OnCreated()
	self.healthregen = self:GetAbility():GetTalentSpecialValueFor("damage_per_second")
	self.movespeed = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed_pct")
	self.healamp = self:GetCaster():FindTalentValue("special_bonus_unique_doom_scorched_earth_ebf_1")
	if not self:GetParent():IsSameTeam(self:GetCaster()) then
		self.healthregen = 0
		self.healamp = 0
		self.movespeed = self.movespeed * -1
		self.damage = self:GetAbility():GetTalentSpecialValueFor("damage_per_second")
		if IsServer() then
			ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
			self:StartIntervalThink(1)
		end
	end
end

function modifier_doom_scorched_earth_buff:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_doom_scorched_earth_buff:IsBuff()
	return self:GetParent():IsSameTeam(self:GetCaster())
end

function modifier_doom_scorched_earth_buff:IsHidden()
	if self:GetParent() == self:GetCaster() then
		return true
	else
		return false
	end
end

function modifier_doom_scorched_earth_buff:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_doom_scorched_earth_buff:GetEffectName()	
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf"
	else
		return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf"
	end
end

function modifier_doom_scorched_earth_buff:OnRefresh()
	self.healthregen = self:GetAbility():GetTalentSpecialValueFor("damage_per_second")
	self.movespeed = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed_pct")
	self.healamp = self:GetCaster():FindTalentValue("special_bonus_unique_doom_scorched_earth_ebf_1")
	if not self:GetParent():IsSameTeam(self:GetCaster()) then
		self.healthregen = 0
		self.healamp = self.healamp * (-0.5)
		self.movespeed = self.movespeed * -1
		self.damage = self:GetAbility():GetTalentSpecialValueFor("damage_per_second")
	end
end

function modifier_doom_scorched_earth_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE
			}
	return funcs
end

function modifier_doom_scorched_earth_buff:GetModifierConstantHealthRegen()
	return self.healthregen
end

function modifier_doom_scorched_earth_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end
function modifier_doom_scorched_earth_buff:GetModifierHealAmplify_Percentage()
	return self.healamp
end