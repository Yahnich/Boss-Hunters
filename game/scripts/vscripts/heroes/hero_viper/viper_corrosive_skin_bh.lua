viper_corrosive_skin_bh = class({})

function viper_corrosive_skin_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_viper_corrosive_skin_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function viper_corrosive_skin_bh:GetCastRange( target, position )
	if self:GetCaster():HasTalent("special_bonus_unique_viper_corrosive_skin_1") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_viper_corrosive_skin_1")
	end
end

function viper_corrosive_skin_bh:GetCooldown( iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_viper_corrosive_skin_1") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_viper_corrosive_skin_1", "cd")
	end
end

function viper_corrosive_skin_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_viper_corrosive_skin_bh_active", {duration = caster:FindTalentValue("special_bonus_unique_viper_corrosive_skin_1", "duration")})
end

function viper_corrosive_skin_bh:GetIntrinsicModifierName()
	return "modifier_viper_corrosive_skin_bh"
end


modifier_viper_corrosive_skin_bh_active = class({})
LinkLuaModifier("modifier_viper_corrosive_skin_bh_active", "heroes/hero_viper/viper_corrosive_skin_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_corrosive_skin_bh_active:OnCreated(table)
    if IsServer() then
        local startFX = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf", PATTACH_POINT, self:GetCaster())
        ParticleManager:SetParticleControl(startFX, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(startFX)

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_corrosive_skin_flying.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(nfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_wing_barb_1", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_wing_barb_2", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_wing_barb_3", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(nfx, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_wing_barb_4", self:GetCaster():GetAbsOrigin(), true)
		self:AddEffect( nfx )
    end
end

function modifier_viper_corrosive_skin_bh_active:CheckState()
	return {[MODIFIER_STATE_FLYING] = true}
end

modifier_viper_corrosive_skin_bh = class({})
LinkLuaModifier("modifier_viper_corrosive_skin_bh", "heroes/hero_viper/viper_corrosive_skin_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_corrosive_skin_bh:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.maxRange = self:GetTalentSpecialValueFor("max_range_tooltip")
	self.mr = self:GetTalentSpecialValueFor("bonus_magic_resistance")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_viper_corrosive_skin_1")
	self.talentRadius = self:GetCaster():FindTalentValue("special_bonus_unique_viper_corrosive_skin_1")
end

function modifier_viper_corrosive_skin_bh:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.maxRange = self:GetTalentSpecialValueFor("max_range_tooltip")
	self.mr = self:GetTalentSpecialValueFor("bonus_magic_resistance")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_viper_corrosive_skin_1")
	self.talentRadius = self:GetCaster():FindTalentValue("special_bonus_unique_viper_corrosive_skin_1")
end

function modifier_viper_corrosive_skin_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE; MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_viper_corrosive_skin_bh:OnTakeDamage(params)
	if params.unit == self:GetParent() and not params.attacker:IsSameTeam( params.unit ) then
		params.attacker:EmitSound("hero_viper.CorrosiveSkin")
		params.attacker:AddNewModifier( params.unit, self:GetAbility(), "modifier_viper_corrosive_skin_bh_debuff", {duration = self.duration} )
	end
end

function modifier_viper_corrosive_skin_bh:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_viper_corrosive_skin_bh:IsAura()
	return self:GetCaster():HasModifier("modifier_viper_corrosive_skin_bh_active")
end

function modifier_viper_corrosive_skin_bh:GetModifierAura()
	return "modifier_viper_corrosive_skin_bh_debuff"
end

function modifier_viper_corrosive_skin_bh:GetAuraRadius()
	return self.talentRadius
end

function modifier_viper_corrosive_skin_bh:GetAuraDuration()
	return self.duration
end

function modifier_viper_corrosive_skin_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_viper_corrosive_skin_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_viper_corrosive_skin_bh:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_viper_corrosive_skin_bh:IsHidden()
	return true
end

modifier_viper_corrosive_skin_bh_debuff = class({})
LinkLuaModifier("modifier_viper_corrosive_skin_bh_debuff", "heroes/hero_viper/viper_corrosive_skin_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_corrosive_skin_bh_debuff:OnCreated()
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed") * (-1)
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.talent1Damage = self:GetCaster():FindTalentValue("special_bonus_unique_viper_corrosive_skin_1", "damage")
	if IsServer() then
		self.tick = ( self:GetDuration() / self:GetTalentSpecialValueFor("duration") ) * 1
		self:StartIntervalThink( self.tick )
	end
end

function modifier_viper_corrosive_skin_bh_debuff:OnRefresh()
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed") * (-1)
	self.damage = self:GetTalentSpecialValueFor("damage")
	if IsServer() then
		local tick = ( self:GetDuration() / self:GetTalentSpecialValueFor("duration") ) * 1
		if tick > self.tick then
			self.tick = tick
			self:StartIntervalThink( self.tick )
		end
	end
end

function modifier_viper_corrosive_skin_bh_debuff:OnIntervalThink()
	local damage = self.damage
	if self:GetCaster():HasModifier("modifier_viper_corrosive_skin_bh_active") then
		damage = damage * self.talent1Damage
	end
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
end

function modifier_viper_corrosive_skin_bh_debuff:DeclareFunctions()
	return {}
end

function modifier_viper_corrosive_skin_bh_debuff:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_viper_corrosive_skin_bh_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end