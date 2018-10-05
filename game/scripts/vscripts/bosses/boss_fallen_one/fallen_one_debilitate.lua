fallen_one_debilitate = class({})


function fallen_one_debilitate:OnAbilityPhaseStart()
	local startPos = self:GetCaster():GetAbsOrigin()
	local endPos = startPos + CalculateDirection( self:GetCursorPosition(), startPos ) * self:GetSpecialValueFor("distance")
	ParticleManager:FireLinearWarningParticle( startPos, endPos, self:GetSpecialValueFor("radius") )
	return true
end

function fallen_one_debilitate:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local direction = CalculateDirection( target, caster )
	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("radius")
	local distance = self:GetSpecialValueFor("distance")
	self:FireLinearProjectile("", direction * speed, distance, width)
end

function fallen_one_debilitate:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		if target:TriggerSpellAbsorb( self ) then return true end
		local damage = self:GetSpecialValueFor("damage")
		local duration = self:GetSpecialValueFor("duration")
		self:DealDamage( caster, target, damage )
		target:AddNewModifier( caster, self, "modifier_fallen_one_debilitate", {duration = duration})
	end
end

modifier_fallen_one_debilitate = class({})
LinkLuaModifier( "modifier_fallen_one_debilitate", "bosses/boss_fallen_one/fallen_one_debilitate", LUA_MODIFIER_MOTION_NONE )

function modifier_fallen_one_debilitate:OnCreated()
	self.armor = self:GetSpecialValueFor("minus_armor")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_fallen_one_debilitate:OnRefresh()
	self.armor = self:GetSpecialValueFor("minus_armor")
	if IsServer() then
		self:AddIndependentStack()
	end
end

function modifier_fallen_one_debilitate:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_fallen_one_debilitate:GetModifierPhysicalArmorBonus()
	return self.armor * self:GetStackCount()
end