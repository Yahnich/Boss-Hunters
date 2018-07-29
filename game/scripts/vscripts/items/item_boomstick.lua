item_boomstick = class({})
function item_boomstick:GetIntrinsicModifierName()
	return "modifier_item_boomstick_handle"
end

function item_boomstick:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local direction = CalculateDirection(target, caster)
	local distance = self:GetSpecialValueFor("active_distance")
	local duration = self:GetSpecialValueFor("active_duration")
	local speed = 3000
	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + direction * distance
	local shotFX = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(shotFX, 0, startPos + Vector(0,0,128) )
	ParticleManager:SetParticleControl(shotFX, 1, endPos + Vector(0,0,128))
	ParticleManager:SetParticleControl(shotFX, 2, Vector(speed, 0, 0) )
	Timers:CreateTimer(distance/speed, function()
		ParticleManager:ClearParticle(shotFX)
	end)
	caster:AddNewModifier(caster, self, "modifier_item_boomstick_crit", {})
	for _, enemy in ipairs( caster:FindEnemyUnitsInLine(startPos, endPos, 128) ) do
		enemy:AddNewModifier(caster, self, "modifier_boomstick_active_debuff", {duration = duration})
		caster:PerformAbilityAttack(enemy, true, self)
	end
	caster:RemoveModifierByName("modifier_item_boomstick_crit")
end

modifier_item_boomstick_handle = class({})
LinkLuaModifier( "modifier_item_boomstick_handle", "items/item_boomstick.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_boomstick_handle:OnCreated()
	self.crit_damage = self:GetSpecialValueFor("critical_damage")
	self.crit_chance = self:GetSpecialValueFor("critical_chance")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.range = self:GetSpecialValueFor("bonus_range")
	self.accuracy = self:GetSpecialValueFor("bonus_accuracy")
end

function modifier_item_boomstick_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_boomstick_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_EVENT_ON_ATTACK_LANDED
			}
end

function modifier_item_boomstick_handle:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = self:RollPRNG(self.accuracy)}
end

function modifier_item_boomstick_handle:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_boomstick_debuff", {Duration = self:GetAbility():GetSpecialValueFor("shred_duration")})
		end
	end
end

function modifier_item_boomstick_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_boomstick_handle:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then return self.range end
end

function modifier_item_boomstick_handle:GetModifierPreAttack_CriticalStrike()
	if RollPercentage( self.crit_chance ) then
		return self.crit_damage
	end
end

function modifier_item_boomstick_handle:IsHidden()
	return true
end

function modifier_item_boomstick_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_boomstick_debuff", "items/item_boomstick.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_boomstick_debuff = class({})

function modifier_boomstick_debuff:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_shred")
end

function modifier_boomstick_debuff:OnRefresh()
	self.armor = math.min(self.armor, self:GetAbility():GetSpecialValueFor("armor_shred"))
end

function modifier_boomstick_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boomstick_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

LinkLuaModifier( "modifier_boomstick_active_debuff", "items/item_boomstick.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_boomstick_active_debuff = class({})

function modifier_boomstick_active_debuff:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("active_shred")
end

function modifier_boomstick_active_debuff:OnRefresh()
	self.armor = math.min(self.armor, self:GetAbility():GetSpecialValueFor("active_shred"))
end

function modifier_boomstick_active_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boomstick_active_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

modifier_item_boomstick_crit = class({})
LinkLuaModifier( "modifier_item_boomstick_crit", "items/item_boomstick.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_boomstick_crit:OnCreated()
	self.crit_damage = self:GetSpecialValueFor("active_crit")
end

function modifier_item_boomstick_crit:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_boomstick_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
			}
end

function modifier_item_boomstick_crit:GetModifierPreAttack_CriticalStrike()
	return self.crit_damage
end

function modifier_item_boomstick_crit:IsHidden()
	return true
end