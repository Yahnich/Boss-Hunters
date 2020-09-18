modifier_boss_attackspeed = class({})

function modifier_boss_attackspeed:IsHidden()
	return true
end

function modifier_boss_attackspeed:OnCreated()
	if IsServer() then
		self:SetStackCount(math.floor(GameRules.gameDifficulty + 0.5) + RoundManager:GetAscensions() * 2)
		self.thinkTime = 0
		self:StartIntervalThink(0.33)
		self.acc = math.min( 8 + self:GetStackCount() * 2 + RoundManager:GetZonesFinished() * 2.5, 65 )
		self.thinkLimit = 2.5 * self:GetStackCount()
		self.armor = self:GetParent():GetPhysicalArmorBaseValue() * 0.0625 * self:GetStackCount() + self:GetStackCount()
		if self:GetParent():IsRangedAttacker() then self.armor = self.armor / 2 end
	return 
	end
end

function modifier_boss_attackspeed:OnIntervalThink()
	local parent = self:GetParent()
	local position = self:GetParent():GetAbsOrigin()
	self.radius = self.radius or parent:GetHullRadius() + parent:GetCollisionPadding()
	if not parent:IsInvisible() then
		self.thinkTime = self.thinkTime + 0.33
		if self.thinkTime >= self.thinkLimit then
			self.thinkTime = 0
			AddFOWViewer(DOTA_TEAM_GOODGUYS, position, 516, 1, false)
		end
	end
	if parent:IsStunned() then
		parent:RemoveGesture(ACT_DOTA_ATTACK)
	end
	GridNav:DestroyTreesAroundPoint(position, self.radius, true)
end

function modifier_boss_attackspeed:GetAccuracy()
	return self.acc
end

function modifier_boss_attackspeed:GetPriority()
	return MODIFIER_PRIORITY_LOW
end


function modifier_boss_attackspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_START
	}
	return funcs
end
--------------------------------------------------------------------------------
function modifier_boss_attackspeed:GetModifierAttackSpeedBonus_Constant( params )
	return 100 + self:GetStackCount() * 25
end

function modifier_boss_attackspeed:GetModifierMoveSpeedBonus_Constant( params )
	return (self:GetStackCount() - 1) * 5
end

--[[function modifier_boss_attackspeed:GetModifierConstantManaRegen( params )
	return self:GetStackCount()*2.5
end

function modifier_boss_attackspeed:GetModifierManaBonus( params )
	return self:GetStackCount()*250
end]]

function modifier_boss_attackspeed:GetModifierPhysicalArmorBonus( params )
	return self.armor
end

function modifier_boss_attackspeed:GetModifierMagicalResistanceBonus( params )
	return math.min( 2.75 * self:GetStackCount(), 60 )
end

function modifier_boss_attackspeed:GetModifierBaseDamageOutgoing_Percentage( params )
	return 10 + 2.5 * self:GetStackCount()
end

function modifier_boss_attackspeed:OnAbilityStart( params )
	if params.unit == self:GetParent() then
		AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 516, 3, false)
	end
end

function modifier_boss_attackspeed:OnAbilityFullyCast( params )
	if params.unit == self:GetParent() then
		AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 516, 3, false)
	end
end

function modifier_boss_attackspeed:OnAttackStart( params )
	if params.attacker == self:GetParent() then
		params.attacker:RemoveGesture( ACT_DOTA_ATTACK )
		params.attacker:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 1 + ( params.attacker:GetIncreasedAttackSpeed() - (1 + self:GetStackCount() * 0.25) ) )
	end
end

function modifier_boss_attackspeed:IsPurgable()
	return false
end

function modifier_boss_attackspeed:AllowIllusionDuplicate()
	return true
end