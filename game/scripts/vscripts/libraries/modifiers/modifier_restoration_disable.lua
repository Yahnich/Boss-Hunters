modifier_restoration_disable = class({})

function modifier_restoration_disable:OnCreated()
	if IsServer() and self:GetParent():IsRealHero() then
		self.mana = self:GetParent():GetMana()
		self.hp = self:GetParent():GetHealth()
		self:StartIntervalThink(0)
	end
end

function modifier_restoration_disable:OnIntervalThink()
	self:GetParent():SetMana( self.mana )
	if self:GetParent():IsAlive() and self.hp > 0 then
		self:GetParent():SetHealth( self.hp )
	end
end

function modifier_restoration_disable:GetTexture()
    return "custom/healing_disabled"
end

function modifier_restoration_disable:IsDebuff()
	return true
end

function modifier_restoration_disable:IsHidden()
	return false
end

function modifier_restoration_disable:IsPurgable()
	return false
end