axe_cleave_strike = class({})
LinkLuaModifier( "modifier_cleave_strike", "heroes/hero_axe/axe_cleave_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function axe_cleave_strike:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl) - self:GetCaster():FindTalentValue("special_bonus_unique_axe_cleave_strike_1")
end

function axe_cleave_strike:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function axe_cleave_strike:GetIntrinsicModifierName()
	return "modifier_cleave_strike"
end

modifier_cleave_strike = class({})

function modifier_cleave_strike:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_cleave_strike:OnAttackLanded(params)
	if IsServer() then
		if (params.target == self:GetParent() or ( params.attacker == self:GetCaster() and self:GetCaster():HasTalent("special_bonus_unique_axe_cleave_strike_2") ) ) 
		and self:GetAbility():IsCooldownReady() 
		and self:GetParent():IsAlive()
		and RollPercentage(self:GetTalentSpecialValueFor("chance")) 
		and not self.procsDisabled then
			-- Ternary Operator x ? y: z; TernaryOperator(passvalue, checkvalue, defaultvalue); if checkvalue is true then passvalue else return defaultvalue
			local target = TernaryOperator(params.target, params.attacker == self:GetCaster(), params.attacker)
			self:Spin(target)
		end
	end
end

function modifier_cleave_strike:Spin(target)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	EmitSoundOn("Hero_Axe.CounterHelix_Blood_Chaser", caster)
	local armorDamage = caster:GetStrength() * self:GetTalentSpecialValueFor("str_to_damage")/100
	local nfx = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt( nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex(nfx)

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

	target:Taunt(ability, caster, self:GetTalentSpecialValueFor("duration"))

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	self.procsDisabled = true
	for _,enemy in pairs(enemies) do
		caster:PerformAbilityAttack(enemy, true, ability, armorDamage, false, false)
	end
	self.procsDisabled = false
	ability:SetCooldown()
end

function modifier_cleave_strike:IsHidden()
	return true
end