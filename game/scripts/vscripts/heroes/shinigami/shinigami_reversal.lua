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
		self:GetParent():PerformAttack(params.attacker,true,true,true,false,false,false,true)
		return -100
	end
end


function modifier_shinigami_reversal:GetEffectName()
	return "particles/heroes/shinigami/shinigami_reversal.vpcf"
end