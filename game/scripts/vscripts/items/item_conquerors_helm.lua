item_conquerors_helm = class({})

function item_conquerors_helm:GetIntrinsicModifierName()
	return "modifier_item_conquerors_helm_passive"
end

function item_conquerors_helm:GetCastRange( target, position )
	return self:GetSpecialValueFor("active_radius")
end

function item_conquerors_helm:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn( "LoneDruid_SpiritBear_IdleRoar", caster )
	self.chargeUp = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf", PATTACH_POINT_FOLLOW, caster)
end

function item_conquerors_helm:OnChannelFinish(bInterrupt)
	if not bInterrupt then
		local caster = self:GetCaster()
		local radius = self:GetSpecialValueFor("active_radius")
		local duration = self:GetSpecialValueFor("active_duration")
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
			enemy:AddNewModifier(caster, self, "modifier_item_conquerors_helm_fear", {duration = duration})
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_POINT_FOLLOW, caster)
		EmitSoundOn( "Hero_LoneDruid.SavageRoar.Cast", caster )
	end
	ParticleManager:ClearParticle( self.chargeUp )
	self.chargeUp = nil
end

modifier_item_conquerors_helm_fear = class({})
LinkLuaModifier("modifier_item_conquerors_helm_fear", "items/item_conquerors_helm", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_item_conquerors_helm_fear:OnCreated()
		self:StartIntervalThink(0.2)
	end
	
	function modifier_item_conquerors_helm_fear:OnIntervalThink()
		local direction = CalculateDirection(self:GetParent(), self:GetCaster())
		self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + direction * self:GetParent():GetIdealSpeed() * 0.2)
	end
end

function modifier_item_conquerors_helm_fear:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end

function modifier_item_conquerors_helm_fear:GetStatusEffectName()
	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function modifier_item_conquerors_helm_fear:StatusEffectPriority()
	return 10
end

function modifier_item_conquerors_helm_fear:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			}
end

modifier_item_conquerors_helm_passive = class({})
LinkLuaModifier("modifier_item_conquerors_helm_passive", "items/item_conquerors_helm", LUA_MODIFIER_MOTION_NONE)

function modifier_item_conquerors_helm_passive:OnCreated()
	self.regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.bonusHP = self:GetSpecialValueFor("bonus_health")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
	self.stat = self:GetSpecialValueFor("bonus_strength")
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_conquerors_helm_passive:IsHidden()
	return true
end

function modifier_item_conquerors_helm_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,	
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_EVENT_ON_TAKEDAMAGE
			}
end

function modifier_item_conquerors_helm_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local flHeal = params.damage * self.lifesteal
		if params.inflictor then ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self) end
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_conquerors_helm_passive:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_conquerors_helm_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_conquerors_helm_passive:GetModifierHealthBonus()
	return self:GetParent():GetStrength() * self.hpPerStr + self.bonusHP
end

function modifier_item_conquerors_helm_passive:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_item_conquerors_helm_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
