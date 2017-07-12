shinigami_reversal = class({})

function shinigami_reversal:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_shinigami_reversal", {duration = self:GetTalentSpecialValueFor("duration")})
	EmitSoundOn("Hero_Weaver.Shukuchi", caster)
end


modifier_shinigami_reversal = class({})
LinkLuaModifier("modifier_shinigami_reversal", "heroes/shinigami/shinigami_reversal.lua", 0)

function modifier_shinigami_reversal:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
	return funcs
end

if IsServer() then
	function modifier_shinigami_reversal:GetModifierIncomingDamage_Percentage(params)
		local dmgPct = self:GetAbility():GetTalentSpecialValueFor("bonus_damage") / 100
		local caster = self:GetCaster()
		local bonusDamage = caster:GetAverageTrueAttackDamage(caster) * dmgPct
		if caster:HasTalent("shinigami_reversal_talent_1") then
			caster:HealEvent(params.damage, caster, {})
		end
		caster:AddNewModifier(caster, self, "modifier_shinigami_reversal_bonusdamage", {}):SetStackCount(bonusDamage)
		caster:PerformAbilityAttack(params.attacker, true)
		caster:RemoveModifierByName("modifier_shinigami_reversal_bonusdamage")
		return -100
	end
end


function modifier_shinigami_reversal:GetEffectName()
	return "particles/heroes/shinigami/shinigami_reversal.vpcf"
end

modifier_shinigami_reversal_bonusdamage = class({})
LinkLuaModifier("modifier_shinigami_reversal_bonusdamage", "heroes/shinigami/shinigami_reversal.lua", 0)

function modifier_shinigami_reversal_bonusdamage:IsHidden()
	return true
end

function modifier_shinigami_reversal_bonusdamage:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			}
	return funcs
end

function modifier_shinigami_reversal_bonusdamage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end