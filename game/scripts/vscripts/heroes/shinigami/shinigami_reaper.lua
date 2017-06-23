shinigami_reaper = class({})

function shinigami_reaper:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_shinigami_reaper_buff", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_PhantomAssassin.Arcana_Layer", caster)
	EmitSoundOn("Hero_Treant.Overgrowth.CastAnim", caster)
	
	if caster:HasTalent("shinigami_reaper_talent_1") then
		caster:RefreshAllCooldowns(false)
	end
	self:UseResources(false, false, true)
end

LinkLuaModifier("modifier_shinigami_reaper_buff", "heroes/shinigami/shinigami_reaper.lua", 0)
modifier_shinigami_reaper_buff = class({})


function modifier_shinigami_reaper_buff:OnCreated()
	self.crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
	self.crit_damage = self:GetAbility():GetSpecialValueFor("crit_amount")
	self.BAT = self:GetAbility():GetSpecialValueFor("base_attack_time")
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	self.lifesteal = self:GetAbility():GetSpecialValueFor("deep_wounds_lifesteal") / 100
end


function modifier_shinigami_reaper_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
				MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, 
				MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_MODEL_SCALE,
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_shinigami_reaper_buff:GetModifierBaseAttackTimeConstant()
	return self.BAT
end

function modifier_shinigami_reaper_buff:GetModifierModelScale()
	return 35
end

function modifier_shinigami_reaper_buff:GetModifierMoveSpeedBonus_Constant()
	return self.movespeed
end

function modifier_shinigami_reaper_buff:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(self.crit_chance) then
		return self.crit_damage
	end
	return nil
end

function modifier_shinigami_reaper_buff:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.target:HasModifier("modifier_shinigami_deep_wounds_stacks") then
			local modifier = params.target:FindModifierByName("modifier_shinigami_deep_wounds_stacks")
			local heal_pct = self.lifesteal * modifier:GetStackCount() * (100 - params.target:GetPhysicalArmorReduction())/100
			local heal = params.damage * heal_pct
			params.attacker:HealEvent(heal, params.attacker, {})
		end
	end
end

function modifier_shinigami_reaper_buff:GetEffectName()
	return "particles/heroes/shinigami/shinigami_reaper_buff_effect.vpcf"
end

function modifier_shinigami_reaper_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_electrical.vpcf"
end

function modifier_shinigami_reaper_buff:StatusEffectPriority()
	return 10
end