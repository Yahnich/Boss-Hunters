item_mirrors_edge = class({})

function item_mirrors_edge:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	local ogPos = caster:GetAbsOrigin()
	
	local maxIllus = self:GetSpecialValueFor("illusion_count")
	
	for _, illusion in ipairs( caster.itemIllusionTable or {} ) do
		if not illusion:IsNull() and illusion:IsAlive() then
			illusion:ForceKill( true )
		end
	end
	caster.itemIllusionTable = {}
	
	local callback = (function(illusion, parent)
		illusion:SetThreat( parent:GetThreat() )
		table.insert( caster.itemIllusionTable, illusion )
	end)
	
	for i = 1, maxIllus do
		local illusion = caster:ConjureImage( ogPos + RandomVector(150), self:GetSpecialValueFor("duration"), -(100 - self:GetSpecialValueFor("illu_outgoing_damage")), self:GetSpecialValueFor("illu_incoming_damage") - 100, nil, self, true, caster, callback )
	end
end

function item_mirrors_edge:GetIntrinsicModifierName()
	return "modifier_item_mirrors_edge"
end

modifier_item_mirrors_edge = class(itemBaseClass)
LinkLuaModifier("modifier_item_mirrors_edge", "items/item_mirrors_edge", LUA_MODIFIER_MOTION_NONE)

function modifier_item_mirrors_edge:OnCreated()
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
end

function modifier_item_mirrors_edge:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			}
end

function modifier_item_mirrors_edge:GetModifierAttackSpeedBonus_Constant()
	return self.attackSpeed
end

function modifier_item_mirrors_edge:GetModifierBonusStats_Agility()
	return self.agility
end