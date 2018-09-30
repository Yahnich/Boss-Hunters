boss16m_heal_aura = class({})

function boss16m_heal_aura:GetIntrinsicModifierName()
	return "modifier_boss16m_heal_aura"
end

modifier_boss16m_heal_aura = class({})
LinkLuaModifier("modifier_boss16m_heal_aura", "bosses/boss16/boss16m_heal_aura.lua", 0)

if IsServer() then
	function modifier_boss16m_heal_aura:OnCreated()
		self.heal = self:GetSpecialValueFor("heal_amount") / 100
		self:StartIntervalThink(0.3)
	end
	
	function modifier_boss16m_heal_aura:OnIntervalThink()
		local dragon = self:GetCaster().owningDragon
		if self:GetParent():PassivesDisabled() then return end
		if not dragon or dragon:IsNull() then
			self:StartIntervalThink(-1)
			return -1
		end
		local hpHeal = self.heal * dragon:GetMaxHealth() * 0.3
		dragon:HealEvent(hpHeal, self:GetAbility(), self:GetCaster())
	end
end	

function modifier_boss16m_heal_aura:IsHidden()
	return true
end