axe_cleave_strike = class({})

function axe_cleave_strike:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl)
end

function axe_cleave_strike:GetCastRange(target, position)
	return self:GetCaster():GetAttackRange() + self:GetTalentSpecialValueFor("bonus_range")
end

function axe_cleave_strike:GetIntrinsicModifierName()
	return "modifier_cleave_strike"
end

modifier_cleave_strike = class({})
LinkLuaModifier( "modifier_cleave_strike", "heroes/hero_axe/axe_cleave_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_cleave_strike:OnCreated()
	self:OnRefresh()
end

function modifier_cleave_strike:OnRefresh()
	self.bonus_damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.attack_damage = self:GetTalentSpecialValueFor("attack_damage")
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.chance = self:GetTalentSpecialValueFor("chance")
	self.attack_range = self:GetTalentSpecialValueFor("bonus_range")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_axe_cleave_strike_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_axe_cleave_strike_2")
end

function modifier_cleave_strike:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_cleave_strike:OnAttackLanded(params)
	if IsServer() then
		if (params.target == self:GetParent() or ( params.attacker == self:GetCaster() and self.talent2 ) ) 
		and ( self:GetAbility():IsCooldownReady() or params.attacker == self:GetCaster() )
		and self:GetParent():IsAlive()
		and RollPercentage(self.chance) 
		and not self:GetCaster():IsInAbilityAttackMode() then
			-- Ternary Operator x ? y: z; TernaryOperator(passvalue, checkvalue, defaultvalue); if checkvalue is true then passvalue else return defaultvalue
			local target = TernaryOperator(params.target, params.attacker == self:GetCaster(), params.attacker)
			self:Spin(target, params.attacker == self:GetCaster() )
		end
	end
end

function modifier_cleave_strike:Spin( target, ignoreCD )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	EmitSoundOn("Hero_Axe.CounterHelix_Blood_Chaser", caster)
	local bonusDamage = self.bonus_damage
	local damagePct = self.attack_damage - 100
	local nfx = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt( nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex(nfx)

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

	target:Taunt(ability, caster, self.duration)
	if self.talent1 then
		target:AddNewModifier( caster, ability, "modifier_cleave_strike_talent", {duration = self.duration})
	end

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange() + self.attack_range, {})
	for _,enemy in pairs(enemies) do
		caster:PerformAbilityAttack(enemy, true, ability, damagePct, true, false)
		ability:DealDamage( caster, enemy, bonusDamage )
	end
	if not ignoreCD then
		ability:SetCooldown()
	end
end

function modifier_cleave_strike:IsHidden()
	return true
end

modifier_cleave_strike_talent = class({})
LinkLuaModifier( "modifier_cleave_strike_talent", "heroes/hero_axe/axe_cleave_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_cleave_strike_talent:OnCreated()
	self:OnRefresh()
end

function modifier_cleave_strike_talent:OnRefresh()
	self.damage_reduction = self:GetCaster():FindTalentValue("special_bonus_unique_axe_cleave_strike_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_axe_cleave_strike_2")
end

function modifier_cleave_strike_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_cleave_strike_talent:GetModifierTotalDamageOutgoing_Percentage()
	return -self.damage_reduction
end