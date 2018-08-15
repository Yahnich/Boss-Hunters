legion_commander_war_fury = class({})

function legion_commander_war_fury:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_1") then
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
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
	
	EmitSoundOn("Hero_LegionCommander.WarFuryShout",self:GetCaster())
	EmitSoundOn("Hero_LegionCommander.Duel.Cast",self:GetCaster())
	
	local duration = self:GetTalentSpecialValueFor("duration")
	if not caster:HasTalent("special_bonus_unique_legion_commander_war_fury_1") then
		CreateModifierThinker(caster, self, "modifier_legion_commander_war_fury_thinker", {duration = duration}, target, caster:GetTeam(), false)
	else
		caster:AddNewModifier(caster, self, "modifier_legion_commander_war_fury_amp", {duration = duration})
	end
	if caster:HasScepter() then
		caster:AddNewModifier(caster, self, "modifier_status_immunity", {duration = duration})
		caster:AddNewModifier(caster, self, "modifier_rune_haste", {duration = duration})
	end
end

LinkLuaModifier( "modifier_legion_commander_war_fury_amp", "heroes/hero_legion_commander/legion_commander_war_fury", LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_war_fury_amp = class({})

function modifier_legion_commander_war_fury_amp:OnCreated( kv )
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
		self.aura_radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
		local FXIndex = ParticleManager:CreateParticle( "particles/legion_war_fury_ring.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( FXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( FXIndex, 5, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )
		ParticleManager:SetParticleControl( FXIndex, 6, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( FXIndex, 7, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( FXIndex, 10, self:GetParent():GetOrigin() )
		self:AddEffect( FXIndex )
		self:StartIntervalThink(3)
	end
end

function modifier_legion_commander_war_fury_amp:OnDestroy( kv )
	if IsServer() then
		StopSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
		ParticleManager:ClearParticle(self.FXIndex)
	end
end


LinkLuaModifier( "modifier_legion_commander_war_fury_thinker", "heroes/hero_legion_commander/legion_commander_war_fury", LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_war_fury_thinker = class({})

function modifier_legion_commander_war_fury_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
	if IsServer() and self:GetParent() ~= self:GetCaster() then
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
	if self:GetParent() == self:GetCaster() and self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_1") then
		self.bonusDamage = self.bonusDamage / 2
		self.lifesteal = self.lifesteal / 2
		self.bonusArmor = self.bonusArmor / 2
	end
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
	local damage = self.bonusDamage
	if self:GetCaster():HasModifier("modifier_legion_commander_war_fury_amp") then damage = damage * 2 end
	return damage
end

function modifier_legion_commander_war_fury_buff:GetModifierPhysicalArmorBonus()
	local armor = self.bonusArmor
	if self:GetCaster():HasModifier("modifier_legion_commander_war_fury_amp") then armor = armor * 2 end
	return armor
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
			local lifesteal = self.lifesteal
			if self:GetCaster():HasModifier("modifier_legion_commander_war_fury_amp") then lifesteal = lifesteal * 2 end
			local flHeal = params.damage * lifesteal
			params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
		end
	end
end