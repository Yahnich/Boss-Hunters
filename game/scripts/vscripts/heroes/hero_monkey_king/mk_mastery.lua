mk_mastery = class({})
LinkLuaModifier("modifier_mk_mastery_handle", "heroes/hero_monkey_king/mk_mastery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mk_mastery_debuff", "heroes/hero_monkey_king/mk_mastery", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mk_mastery_hits", "heroes/hero_monkey_king/mk_mastery", LUA_MODIFIER_MOTION_NONE)

function mk_mastery:IsStealable()
	return false
end

function mk_mastery:IsHiddenWhenStolen()
	return false
end

function mk_mastery:GetIntrinsicModifierName()
	return "modifier_mk_mastery_handle"
end

function mk_mastery:GetCooldown(iLevel)
	if self:GetCaster():HasTalent("special_bonus_unique_mk_mastery_2") then
		return 20
	end
end

function mk_mastery:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_mk_mastery_2") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function mk_mastery:OnSpellStart()
	local caster = self:GetCaster()

	local mod = caster:AddNewModifier(caster, self, "modifier_mk_mastery_hits", {Duration = self:GetSpecialValueFor("max_duration")})
	mod:SetStackCount(self:GetSpecialValueFor("charges"))
end

modifier_mk_mastery_handle = class({})

function modifier_mk_mastery_handle:OnCreated(table)
	self:StartIntervalThink(0.5)
end

function modifier_mk_mastery_handle:OnIntervalThink()
	if self:GetCaster():HasScepter() then
		self.bonusDamage = self:GetSpecialValueFor("bonus_damage")/4

		if IsServer() then
			self.lifesteal = self:GetSpecialValueFor("lifesteal")/4
		end
	else
		self.bonusDamage = 0

		if IsServer() then
			self.lifesteal = 0
		end
	end
end

function modifier_mk_mastery_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return funcs
end

function modifier_mk_mastery_handle:GetModifierPreAttack_BonusDamage()
	return self.bonusDamage
end

function modifier_mk_mastery_handle:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker

		if caster == attacker and not caster:HasModifier("modifier_mk_mastery_hits") then
			local duration = self:GetSpecialValueFor("counter_duration")
			local enemyCheckerMod = "modifier_mk_mastery_debuff"

			if caster:HasScepter() then
				caster:Lifesteal(self:GetAbility(), self.lifesteal, params.damage)
			end

			if not caster:IsInAbilityAttackMode() then
				if target:HasModifier( enemyCheckerMod ) then
					
					target:AddNewModifier(caster, self:GetAbility(), enemyCheckerMod, {Duration = duration}):IncrementStackCount()
					
					if target:FindModifierByName( enemyCheckerMod ):GetStackCount() >= self:GetSpecialValueFor("required_hits") then
						
						EmitSoundOn("Hero_MonkeyKing.IronCudgel", caster)

						local mod = caster:AddNewModifier(caster, self:GetAbility(), "modifier_mk_mastery_hits", {Duration = self:GetSpecialValueFor("max_duration")})
						mod:SetStackCount(self:GetSpecialValueFor("charges"))

						if caster:HasScepter() then
							local damage = params.damage * 2
							self:GetAbility():Cleave(target, damage, 150, 330, 625, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf" )
						end

						target:RemoveModifierByName( enemyCheckerMod )
					end
				else
					local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
					for _,enemy in pairs(enemies) do
						if enemy:HasModifier( enemyCheckerMod ) then
							enemy:RemoveModifierByName( enemyCheckerMod )
						end
					end
					target:AddNewModifier(caster, self:GetAbility(), enemyCheckerMod, {Duration = duration}):IncrementStackCount()
				end
			end
		end
	end
end

function modifier_mk_mastery_handle:IsHidden()
	return true
end

modifier_mk_mastery_debuff = class({})
function modifier_mk_mastery_debuff:IsDebuff() return true end

modifier_mk_mastery_hits = class({})

function modifier_mk_mastery_hits:OnCreated(table)
    self.bonus_Ad = self:GetSpecialValueFor("bonus_damage")

    if IsServer() then
    	local caster = self:GetParent()

    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_start.vpcf", PATTACH_POINT, caster)
    				ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
    				ParticleManager:ReleaseParticleIndex(nfx)

    	local buffFx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_tap_buff.vpcf", PATTACH_POINT_FOLLOW, caster)
    				ParticleManager:SetParticleControlEnt(buffFx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    				ParticleManager:SetParticleControlEnt(buffFx, 2, caster, PATTACH_POINT_FOLLOW, "attach_top", caster:GetAbsOrigin(), true)
    				ParticleManager:SetParticleControlEnt(buffFx, 3, caster, PATTACH_POINT_FOLLOW, "attach_bot", caster:GetAbsOrigin(), true)
    	self:AttachEffect(buffFx)
    				

    	self.lifesteal = self:GetSpecialValueFor("lifesteal")
    end
end

function modifier_mk_mastery_hits:OnRefresh(table)
    self.bonus_Ad = self:GetSpecialValueFor("bonus_damage")

    if IsServer() then
    	self.lifesteal = self:GetSpecialValueFor("lifesteal")
    end
end

function modifier_mk_mastery_hits:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return funcs
end

function modifier_mk_mastery_hits:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker

		if caster == attacker then
			if not caster:IsInAbilityAttackMode() then
				if self:GetStackCount() > 1 then
					caster:Lifesteal(self:GetAbility(), self.lifesteal, params.damage)
					self:DecrementStackCount()
				else
					self:Destroy()
				end
			end
		end
	end
end

function modifier_mk_mastery_hits:GetModifierPreAttack_BonusDamage()
	return self.bonus_Ad
end

function modifier_mk_mastery_hits:IsDebuff()
	return false
end

function modifier_mk_mastery_hits:GetEffectName()
	return "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf"
end

function modifier_mk_mastery_hits:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end