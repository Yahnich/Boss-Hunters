legion_commander_war_fury = class({})

function legion_commander_war_fury:GetBehavior()
	if not self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_1") then
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA
	end
end

function legion_commander_war_fury:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_1") then
		return "modifier_legion_commander_war_fury_thinker"
	else
		return nil
	end
end

function legion_commander_war_fury:OnTalentLearned()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_legion_commander_war_fury_thinker", {})
end

function legion_commander_war_fury:GetAOERadius()
	return self:GetTalentSpecialValueFor( "radius" )
end

function legion_commander_war_fury:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	CreateModifierThinker(caster, self, "modifier_legion_commander_war_fury_thinker", {duration = duration}, target, caster:GetTeam(), false)
end

LinkLuaModifier( "modifier_legion_commander_war_fury_thinker", "heroes/hero_legion_commander/legion_commander_war_fury", LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_war_fury_thinker = class({})

function modifier_legion_commander_war_fury_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		EmitSoundOn("Hero_LegionCommander.WarFuryShout",self:GetCaster())
		EmitSoundOn("Hero_LegionCommander.Duel.Cast",self:GetCaster())
		EmitSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
		
		self.FXIndex = ParticleManager:CreateParticle( "particles/legion_war_fury_ring.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 5, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )
		ParticleManager:SetParticleControl( self.FXIndex, 6, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 7, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 10, self:GetParent():GetOrigin() )
		self:AddEffect( self.FXIndex )
		self:StartIntervalThink(3)
	end
end

function modifier_legion_commander_war_fury_thinker:OnDestroy( kv )
	if IsServer() then
		StopSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
		ParticleManager:ClearParticle(self.FXIndex)
	end
end


function modifier_legion_commander_war_fury_thinker:OnIntervalThink( kv )
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		EmitSoundOn("Hero_LegionCommander.Duel.Victory", self:GetCaster())
	end
end

function modifier_legion_commander_war_fury_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetModifierAura()
	return "modifier_legion_commander_war_fury_buff"
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_legion_commander_war_fury_thinker:IsPurgable()
    return false
end

LinkLuaModifier( "modifier_legion_commander_war_fury_buff", "heroes/hero_legion_commander/legion_commander_war_fury" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_war_fury_buff = class({})

function modifier_legion_commander_war_fury_buff:OnCreated()
	self.bonusDamage = self:GetAbility():GetTalentSpecialValueFor("bonus_damage_aura")
	self.lifesteal = self:GetAbility():GetTalentSpecialValueFor("lifesteal") / 100
	self.bonusArmor = self:GetAbility():GetTalentSpecialValueFor("armor")
end

function modifier_legion_commander_war_fury_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_legion_commander_war_fury_buff:GetModifierPreAttack_BonusDamage()
	return self.bonusDamage
end

function modifier_legion_commander_war_fury_buff:GetModifierPhysicalArmorBonus()
	return self.bonusArmor
end

function modifier_legion_commander_war_fury_buff:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
end

function modifier_legion_commander_war_fury_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_legion_commander_war_fury_buff:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetHealth() > 0 and self:GetParent():IsRealHero() and not params.inflictor then
			local flHeal = params.damage * self.lifesteal
			params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
		end
	end
end