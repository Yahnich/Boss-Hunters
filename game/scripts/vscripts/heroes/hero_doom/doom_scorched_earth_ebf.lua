doom_scorched_earth_ebf = class({})

function doom_scorched_earth_ebf:IsStealable()
	return true
end

function doom_scorched_earth_ebf:IsHiddenWhenStolen()
	return false
end

function doom_scorched_earth_ebf:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_doom_scorched_earth_ebf_2") then
		return "modifier_doom_scorched_earth_talent"
	end
end

function doom_scorched_earth_ebf:OnTalentLearned()
	if self:GetCaster():HasTalent("special_bonus_unique_doom_scorched_earth_ebf_2") then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_doom_scorched_earth_talent", {} )
	end
end

function doom_scorched_earth_ebf:OnSpellStart()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doom_scorched_earth_aura", {duration = self:GetTalentSpecialValueFor("duration")})
	end
end

modifier_doom_scorched_earth_talent = class({})
LinkLuaModifier( "modifier_doom_scorched_earth_talent", "heroes/hero_doom/doom_scorched_earth_ebf" ,LUA_MODIFIER_MOTION_NONE )

function modifier_doom_scorched_earth_talent:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage_per_second") * self:GetCaster():FindTalentValue("special_bonus_unique_doom_scorched_earth_ebf_2", "damage") / 100
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_doom_scorched_earth_ebf_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_doom_scorched_earth_ebf_1") / 100
	self.talent1Minion = self:GetCaster():FindTalentValue("special_bonus_unique_doom_scorched_earth_ebf_1", "value2") / 100
	if IsServer() then
		self:StartIntervalThink( 1 )
		local nfx = ParticleManager:CreateParticle( "particles/econ/events/ti10/radiance_ti10.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt(nfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nfx, 25, Vector(0,255,255))
		self:AddEffect( nfx )
	end
end

function modifier_doom_scorched_earth_talent:OnRefresh()
	self:OnCreated()
end

function modifier_doom_scorched_earth_talent:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
		local damage = ability:DealDamage( caster, enemy, self.damage )
		if self.talent1 then
			local healing =  TernaryOperator( damage * self.talent1Val * self.talent1Minion, enemy:IsMinion(), damage * self.talent1Val )
			local heal = caster:HealEvent( healing, ability, caster, {heal_type = HEAL_TYPE_LIFESTEAL} )
		end
	end
end

function modifier_doom_scorched_earth_talent:IsPurgable()
    return false
end

function modifier_doom_scorched_earth_talent:IsHidden()
    return true
end

modifier_doom_scorched_earth_aura = class({})
LinkLuaModifier( "modifier_doom_scorched_earth_aura", "heroes/hero_doom/doom_scorched_earth_ebf" ,LUA_MODIFIER_MOTION_NONE )

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

LinkLuaModifier( "modifier_doom_scorched_earth_buff", "heroes/hero_doom/doom_scorched_earth_ebf" ,LUA_MODIFIER_MOTION_NONE )
modifier_doom_scorched_earth_buff = class({})

function modifier_doom_scorched_earth_buff:OnCreated()
	self.movespeed = self:GetAbility():GetTalentSpecialValueFor("bonus_movement_speed_pct")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("bonus_attack_speed")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_doom_scorched_earth_ebf_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_doom_scorched_earth_ebf_1") / 100
	self.talent1Minion = self:GetCaster():FindTalentValue("special_bonus_unique_doom_scorched_earth_ebf_1", "value2") / 100
	if self:GetParent() ~= self:GetCaster() then
		local pct = self:GetTalentSpecialValueFor("ally_pct") / 100
		self.movespeed = self.movespeed * pct
		self.attackspeed = self.attackspeed * pct
	end
	if not self:GetParent():IsSameTeam(self:GetCaster()) then
		self.movespeed = self.movespeed * -1
		self.attackspeed = self.attackspeed * -1
		self.damage = self:GetAbility():GetTalentSpecialValueFor("damage_per_second")
		if IsServer() then
			self:OnIntervalThink()
			self:StartIntervalThink(1)
		end
	end
end

function modifier_doom_scorched_earth_buff:OnRefresh()
	self:OnCreated()
end

function modifier_doom_scorched_earth_buff:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local damage = ability:DealDamage( caster, target, self.damage )
	if self.talent1 then
		local healing = TernaryOperator( damage * self.talent1Val * self.talent1Minion, target:IsMinion(), damage * self.talent1Val )
		local heal = caster:HealEvent( healing, ability, caster, {heal_type = HEAL_TYPE_LIFESTEAL} )
	end
end

function modifier_doom_scorched_earth_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
			}
	return funcs
end

function modifier_doom_scorched_earth_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_doom_scorched_earth_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_doom_scorched_earth_buff:GetEffectName()	
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf"
	else
		return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf"
	end
end

function modifier_doom_scorched_earth_buff:IsDebuff()
	return not self:GetParent():IsSameTeam(self:GetCaster())
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