disruptor_tesla_field = class({})

function disruptor_tesla_field:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_disruptor_tesla_field_2") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function disruptor_tesla_field:GetCooldown( iLvl )
	return self:GetCaster():FindTalentValue("special_bonus_unique_disruptor_tesla_field_2", "cd")
end

function disruptor_tesla_field:GetManaCost( iLvl )
	return self:GetCaster():FindTalentValue("special_bonus_unique_disruptor_tesla_field_2", "mana")
end

function disruptor_tesla_field:OnSpellStart()
end

function disruptor_tesla_field:GetIntrinsicModifierName()
	return "modifier_disruptor_tesla_field"
end

modifier_disruptor_tesla_field = class({})
LinkLuaModifier("modifier_disruptor_tesla_field", "heroes/hero_disruptor/disruptor_tesla_field", LUA_MODIFIER_MOTION_NONE)

function modifier_disruptor_tesla_field:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("silence_duration")
	self.damage = self:GetSpecialValueFor("damage")
	self.chance = self:GetSpecialValueFor("chance")
	self.cooldown = self:GetSpecialValueFor("cooldown")
end

function modifier_disruptor_tesla_field:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("silence_duration")
	self.damage = self:GetSpecialValueFor("damage")
	self.chance = self:GetSpecialValueFor("chance")
	self.cooldown = self:GetSpecialValueFor("cooldown")
end

function modifier_disruptor_tesla_field:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_disruptor_tesla_field:OnTakeDamage(params)
	if params.attacker == self:GetParent() then
		if params.damage <= 0 or params.unit:HasModifier("modifier_disruptor_tesla_field_debuff") then return end
		local talentActivated = false --( self:GetParent():HasTalent("special_bonus_unique_disruptor_kinetic_charge_1") and params.unit:HasModifier("modifier_disruptor_kinetic_charge_pull") )
		local roll = RollPercentage( self.chance )
		local talent1 = self:GetCaster():HasTalent("special_bonus_unique_disruptor_tesla_field_1")
		if ( ( CalculateDistance( params.attacker, params.unit ) < self.radius or talent1) and roll and modifier_disruptor_tesla_field_debuff) or talentActivated then
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			if params.inflictor == ability then return end
			local enemy = params.unit
			ability:DealDamage( caster, enemy, self.damage )
			enemy:Silence(ability, caster, self.duration)
			enemy:Root(ability, caster, self.duration)
			params.unit:AddNewModifier(caster, ability, "modifier_disruptor_tesla_field_debuff", {duration = self.cooldown})
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_rhasta/rhasta_spell_forked_lightning.vpcf", PATTACH_POINT_FOLLOW , caster, enemy)
		end
	end
end

function modifier_disruptor_tesla_field:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.ability:GetCooldown(-1) > 1 then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
			ability:DealDamage( caster, enemy, self.damage )
			enemy:Silence(ability, caster, self.duration)
			enemy:Root(ability, caster, self.duration)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_rhasta/rhasta_spell_forked_lightning.vpcf", PATTACH_POINT_FOLLOW , caster, enemy)
		end
	end
end

function modifier_disruptor_tesla_field:IsHidden()
	return true
end

modifier_disruptor_tesla_field_debuff = class({})
LinkLuaModifier("modifier_disruptor_tesla_field_debuff", "heroes/hero_disruptor/disruptor_tesla_field", LUA_MODIFIER_MOTION_NONE)