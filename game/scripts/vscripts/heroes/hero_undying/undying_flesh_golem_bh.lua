undying_flesh_golem_bh = class({})

function undying_flesh_golem_bh:GetCastRange(target, position)
	return self:GetSpecialValueFor("radius")
end

function undying_flesh_golem_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_undying_flesh_golem_bh", {duration = self:GetSpecialValueFor("duration")})
	caster:StartGesture( ACT_DOTA_SPAWN )
	EmitSoundOn("Hero_Undying.FleshGolem.Cast", caster )
end

modifier_undying_flesh_golem_bh = class({})
LinkLuaModifier("modifier_undying_flesh_golem_bh", "heroes/hero_undying/undying_flesh_golem_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_flesh_golem_bh:OnCreated()
	self:OnRefresh()
end

function modifier_undying_flesh_golem_bh:OnRefresh()
	local caster = self:GetCaster()
	self.bonus_strength = self:GetSpecialValueFor("bonus_strength")
	self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
	self.damage_amp = self:GetSpecialValueFor("damage_amp")
	self.duration = self:GetSpecialValueFor("debuff_duration")
	
	self.talent1Armor = caster:GetSpecialValueFor("bonus_armor")
	self.talent1MR = caster:GetSpecialValueFor("bonus_magic_resist")
	self.talent1Threat = caster:GetSpecialValueFor("bonus_threat")
	
	self.talent3Duration = caster:GetSpecialValueFor("zombie_duration")
	if self.talent3 then
		self.tombstone = caster:FindAbilityByName("undying_tombstone_bh")
		if not self.tombstone or self.tombstone:GetLevel() == 0 then -- disable talent if tombstone isn't leveled
			self.talent3 = false
		end
	end
	
	self.decay = caster:FindAbilityByName("undying_decay_bh")
	if not self.decay or self.decay:GetLevel() == 0 then -- disable talent if tombstone isn't leveled
		self.decay = false
	end
	
	self:GetCaster():HookInModifier("GetModifierStrengthBonusPercentage", self)
end

function modifier_undying_flesh_golem_bh:OnDestroy()
	self:GetCaster():HookOutModifier("GetModifierStrengthBonusPercentage", self)
	if IsServer() then
		EmitSoundOn( "Hero_Undying.FleshGolem.End", self:GetCaster() )
	end
end

function modifier_undying_flesh_golem_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_MODEL_CHANGE,
			}
end

function modifier_undying_flesh_golem_bh:OnTakeDamage(params)
	local countsAsAttack = ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE )
	if params.attacker == self:GetParent() and ( countsAsAttack or params.inflictor == self.decay ) then
		if countsAsAttack then
			if self.talent3Duration > 0 then
				self.tombstone:SummonZombie( params.unit, self.talent3Duration )
			end
		end
		params.unit:AddNewModifier( params.attacker, self:GetAbility(), "modifier_undying_flesh_golem_bh_debuff", {duration = self.duration} )
	end
end

function modifier_undying_flesh_golem_bh:GetModifierStrengthBonusPercentage()
	return self.bonus_strength
end

function modifier_undying_flesh_golem_bh:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_undying_flesh_golem_bh:GetModifierPhysicalArmorBonus()
	return self.talent1Armor
end

function modifier_undying_flesh_golem_bh:GetModifierMagicalResistanceBonus()
	return self.talent1MR
end

function modifier_undying_flesh_golem_bh:Bonus_ThreatGain()
	return self.talent1Threat
end

function modifier_undying_flesh_golem_bh:GetModifierModelChange()
	return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function modifier_undying_flesh_golem_bh:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end

modifier_undying_flesh_golem_bh_debuff = class({})
LinkLuaModifier("modifier_undying_flesh_golem_bh_debuff", "heroes/hero_undying/undying_flesh_golem_bh", LUA_MODIFIER_MOTION_NONE)


function modifier_undying_flesh_golem_bh_debuff:OnCreated()
	self:OnRefresh()
end

function modifier_undying_flesh_golem_bh_debuff:OnRefresh()
	self.damage_amp = self:GetSpecialValueFor("damage_amp")
end


function modifier_undying_flesh_golem_bh_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE ,
			}
end

function modifier_undying_flesh_golem_bh_debuff:GetModifierIncomingDamage_Percentage()
	return self.damage_amp
end