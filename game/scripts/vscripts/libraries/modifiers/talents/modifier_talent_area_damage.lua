modifier_talent_area_damage = class(talentBaseClass)

function modifier_talent_area_damage:OnCreated()
	self:GetParent():HookInModifier( "GetModifierAreaDamage", self )
end

function modifier_talent_area_damage:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "AREA_DAMAGE", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_area_damage:OnDestroy()
	self:GetParent():HookOutModifier( "GetModifierAreaDamage", self )
end

function modifier_talent_area_damage:GetModifierAreaDamage()
	return self.value
end