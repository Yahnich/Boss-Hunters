legion_commander_war_fury = class({})

function legion_commander_war_fury:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_2") then
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
end

function legion_commander_war_fury:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_war_fury_2")
	return cd
end

function legion_commander_war_fury:OnTalentLearned()
	if self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_2") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_legion_commander_war_fury_thinker", {})
	else
		self:GetCaster():RemoveModifierByName("modifier_legion_commander_war_fury_thinker")
	end
end

function legion_commander_war_fury:GetAOERadius()
	return self:GetTalentSpecialValueFor( "radius" )
end

function legion_commander_war_fury:GetCastRange(  target, position 	)
	if self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_2") then
		return self:GetTalentSpecialValueFor( "radius" )
	else
		return self.BaseClass.GetCastRange( self, target, position )
	end
end

function legion_commander_war_fury:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	EmitSoundOn("Hero_LegionCommander.WarFuryShout",self:GetCaster())
	EmitSoundOn("Hero_LegionCommander.Duel.Cast",self:GetCaster())
	
	local duration = self:GetTalentSpecialValueFor("duration")
	if not caster:HasTalent("special_bonus_unique_legion_commander_war_fury_2") then
		CreateModifierThinker(caster, self, "modifier_legion_commander_war_fury_thinker", {duration = duration}, target, caster:GetTeam(), false)
	else
		caster:AddNewModifier(caster, self, "modifier_legion_commander_war_fury_thinker", {duration = duration})
	end
	if caster:HasScepter() then
		caster:AddNewModifier(caster, self, "modifier_status_immunity", {duration = duration})
		caster:AddNewModifier(caster, self, "modifier_rune_haste", {duration = duration})
	end
end

LinkLuaModifier( "modifier_legion_commander_war_fury_thinker", "heroes/hero_legion_commander/legion_commander_war_fury", LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_war_fury_thinker = class({})

function modifier_legion_commander_war_fury_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
		self:GetCaster().warFuryAuraEntity = self:GetParent()
		self.FXIndex = ParticleManager:CreateParticle( "particles/legion_war_fury_ring.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 1, Vector( self.aura_radius, 0, 0) )
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
	self.hp_regen = self:GetAbility():GetTalentSpecialValueFor("hp_regen")
	self.dmg_reduction = self:GetAbility():GetTalentSpecialValueFor("damage_resist")
	self.ally_bonus = self:GetAbility():GetTalentSpecialValueFor("ally_bonus") / 100
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_legion_commander_war_fury_1")
	if self:GetParent() ~= self:GetCaster() then
		self.bonusDamage = self.bonusDamage * self.ally_bonus
		self.hp_regen = self.hp_regen * self.ally_bonus
		self.dmg_reduction = self.dmg_reduction * self.ally_bonus
	elseif self.talent1 then
		self.radius = self:GetTalentSpecialValueFor("radius")
		self.damage_amp = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_war_fury_1")
		self.heal_amp = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_war_fury_1", "value2")
		if IsServer() then
			self:StartIntervalThink(0.33)
		end
	end
end

function modifier_legion_commander_war_fury_buff:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not caster.warFuryAuraEntity:IsNull() then
		local position = caster.warFuryAuraEntity:GetAbsOrigin()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, self.radius ) ) do
			enemy:Taunt(ability, caster, 0.5)
		end
	end
end

function modifier_legion_commander_war_fury_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
				MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			}
	return funcs
end

function modifier_legion_commander_war_fury_buff:GetModifierPreAttack_BonusDamage()
	return self.bonusDamage
end

function modifier_legion_commander_war_fury_buff:GetModifierIncomingDamage_Percentage()
	return self.dmg_reduction
end

function modifier_legion_commander_war_fury_buff:GetModifierTotalDamageOutgoing_Percentage()
	return self.damage_amp
end

function modifier_legion_commander_war_fury_buff:GetModifierHealAmplify_Percentage(params)
	if params.target == self:GetParent() then
		return self.heal_amp
	end
end

function modifier_legion_commander_war_fury_buff:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
end

function modifier_legion_commander_war_fury_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_legion_commander_war_fury_buff:GetModifierHealthRegenPercentage(params)
	return self.hp_regen
end