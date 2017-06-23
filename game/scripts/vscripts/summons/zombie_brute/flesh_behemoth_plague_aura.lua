flesh_behemoth_plague_aura = class({})

function flesh_behemoth_plague_aura:GetIntrinsicModifierName()
	return "modifier_flesh_behemoth_plague_aura"
end

LinkLuaModifier( "modifier_flesh_behemoth_plague_aura", "summons/zombie_brute/flesh_behemoth_plague_aura.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_flesh_behemoth_plague_aura = class({})

if IsServer() then
	function modifier_flesh_behemoth_plague_aura:OnCreated()
		self:StartIntervalThink(1)
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
	end

	function modifier_flesh_behemoth_plague_aura:OnIntervalThink()
		local parent = self:GetParent()
		parent:DealMaxHPAOEDamage(parent:GetAbsOrigin(), self.radius, self:GetAbility():GetSpecialValueFor("damage"), DAMAGE_TYPE_MAGICAL)
	end
end

function modifier_flesh_behemoth_plague_aura:GetEffectName()
	return "particles/heroes/puppeteer/flesh_behemoth_plague_aura.vpcf"
end

function modifier_flesh_behemoth_plague_aura:IsHidden()
	return true
end