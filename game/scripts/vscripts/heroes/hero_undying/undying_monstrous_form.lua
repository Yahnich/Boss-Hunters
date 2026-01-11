undying_monstrous_form = class({})

function undying_monstrous_form:GetCastRange(target, position)
	return self:GetSpecialValueFor("radius")
end

function undying_monstrous_form:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_undying_monstrous_form", {duration = self:GetSpecialValueFor("duration")})
	caster:StartGesture( ACT_DOTA_SPAWN )
	EmitSoundOn("Hero_Undying.FleshGolem.Cast", caster )
end

modifier_undying_monstrous_form = class({})
LinkLuaModifier("modifier_undying_monstrous_form", "heroes/hero_undying/undying_monstrous_form", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_monstrous_form:OnCreated()
	self:OnRefresh()
end

function modifier_undying_monstrous_form:OnRefresh()
	local caster = self:GetCaster()
	self.bonus_strength = self:GetSpecialValueFor("bonus_strength")
	self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
	self.duration = self:GetSpecialValueFor("debuff_duration")
	
	self.flesh_golems = self:GetSpecialValueFor("golem_multiplier") > 0
	
	self.talent1Armor = caster:GetSpecialValueFor("bonus_armor")
	self.talent1MR = caster:GetSpecialValueFor("bonus_magic_resist")
	self.talent1Threat = caster:GetSpecialValueFor("bonus_threat")
	
	self.talent3Duration = caster:GetSpecialValueFor("zombie_duration")
	if self.talent3 then
		self.tombstone = caster:FindAbilityByName("undying_necropolis")
		if not self.tombstone or self.tombstone:GetLevel() == 0 then -- disable talent if tombstone isn't leveled
			self.talent3 = false
		end
	end
	
	self:GetCaster():HookInModifier("GetModifierStrengthBonusPercentage", self)
end

function modifier_undying_monstrous_form:OnDestroy()
	self:GetCaster():HookOutModifier("GetModifierStrengthBonusPercentage", self)
	if IsServer() then
		EmitSoundOn( "Hero_Undying.FleshGolem.End", self:GetCaster() )
	end
end

function modifier_undying_monstrous_form:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_MODEL_CHANGE,
			}
end

function modifier_undying_monstrous_form:OnTakeDamage(params)
	local countsAsAttack = ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE )
	if params.attacker ~= self:GetParent() then return end
	if countsAsAttack then
		if self.talent3Duration > 0 then
			self.tombstone:SummonZombie( params.unit, self.talent3Duration )
		end
	end
	params.unit:AddNewModifier( params.attacker, self:GetAbility(), "modifier_undying_monstrous_form_debuff", {duration = self.duration} 
end

function modifier_undying_monstrous_form:GetModifierStrengthBonusPercentage()
	return self.bonus_strength
end

function modifier_undying_monstrous_form:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_undying_monstrous_form:GetModifierPhysicalArmorBonus()
	return self.talent1Armor
end

function modifier_undying_monstrous_form:GetModifierMagicalResistanceBonus()
	return self.talent1MR
end

function modifier_undying_monstrous_form:Bonus_ThreatGain()
	return self.talent1Threat
end

function modifier_undying_monstrous_form:GetModifierModelChange()
	return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function modifier_undying_monstrous_form:IsAura()
	return self.flesh_golems
end

function modifier_undying_monstrous_form:GetModifierAura()
	return "modifier_undying_monstrous_form_flesh_golem"
end

function undying_necropolis_tombstone:GetAuraRadius()
	return 1200
end

function undying_necropolis_tombstone:GetAuraDuration()
	return 0.5
end

function undying_necropolis_tombstone:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function undying_necropolis_tombstone:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC
end

function undying_necropolis_tombstone:GetAuraEntityReject( unit )    
	return unit:GetUnitName() ~= "npc_dota_unit_undying_zombie"
end

function modifier_undying_monstrous_form:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end

modifier_undying_monstrous_form_flesh_golem = class({})
LinkLuaModifier("modifier_undying_monstrous_form_flesh_golem", "heroes/hero_undying/undying_monstrous_form", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_monstrous_form_flesh_golem:OnCreated()
	self.bonus_hp = self:GetParent():GetMaxHealth() * self:GetSpecialValueFor("golem_multiplier") - 1
	self.bonus_damage = (self:GetSpecialValueFor("golem_multiplier") - 1) * 100
end

function modifier_undying_monstrous_form_flesh_golem:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_BONUSDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_undying_monstrous_form_flesh_golem:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_undying_monstrous_form_flesh_golem:GetModifierBonusDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_undying_monstrous_form_flesh_golem:GetModifierModelScale()
	return self.bonus_damage
end

modifier_undying_monstrous_form_debuff = class({})
LinkLuaModifier("modifier_undying_monstrous_form_debuff", "heroes/hero_undying/undying_monstrous_form", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_monstrous_form_debuff:OnCreated()
	self:OnRefresh()
end

function modifier_undying_monstrous_form_debuff:OnRefresh()
	self.damage_amp = self:GetSpecialValueFor("damage_amp")
	self.damage_red = -self.damage_amp * self:GetSpecialValueFor("damage_reduction") / 100
end

function modifier_undying_monstrous_form_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE ,
			MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_undying_monstrous_form_debuff:GetModifierIncomingDamage_Percentage()
	return self.damage_amp
end

function modifier_undying_monstrous_form_debuff:GetModifierTotalDamageOutgoing_Percentage()
	return self.damage_red
end