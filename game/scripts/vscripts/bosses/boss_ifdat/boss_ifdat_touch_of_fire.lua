boss_ifdat_touch_of_fire = class({})

function boss_ifdat_touch_of_fire:GetIntrinsicModifierName()
	return "modifier_boss_ifdat_touch_of_fire"
end

modifier_boss_ifdat_touch_of_fire = class({})
LinkLuaModifier( "modifier_boss_ifdat_touch_of_fire", "bosses/boss_ifdat/boss_ifdat_touch_of_fire", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ifdat_touch_of_fire:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_ifdat_touch_of_fire:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit and params.inflictor ~= self:GetAbility() then
		params.unit:AddNewModifier( params.attacker, self:GetAbility(), "modifier_boss_ifdat_touch_of_fire_debuff", {} )
	end
end

function modifier_boss_ifdat_touch_of_fire:IsHidden()
	return true
end

modifier_boss_ifdat_touch_of_fire_debuff = class({})
LinkLuaModifier( "modifier_boss_ifdat_touch_of_fire_debuff", "bosses/boss_ifdat/boss_ifdat_touch_of_fire", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ifdat_touch_of_fire_debuff:OnCreated()
	self.damage = self:GetSpecialValueFor("damage_per_sec")
	self.reduction = 1 - self:GetSpecialValueFor("water_dmg_red") / 100
	self:GetCaster().touchOfFireTable = self:GetCaster().touchOfFireTable or {}
	table.insert( self:GetCaster().touchOfFireTable, self )
	if IsServer() then
		self:StartIntervalThink(1)
		self:SetStackCount(1)
	end
end

function modifier_boss_ifdat_touch_of_fire_debuff:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage_per_sec")
	self.reduction = 1 - self:GetSpecialValueFor("water_dmg_red") / 100
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_boss_ifdat_touch_of_fire_debuff:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local damage = self.damage * self:GetStackCount()
	if not caster:IsAlive() then
		self:Destroy()
		return
	end
	if parent:InWater() then
		damage = damage * self.reduction
	end
	self:GetAbility():DealDamage( caster, parent, damage )
end

function modifier_boss_ifdat_touch_of_fire_debuff:IsPurgable()
	return false
end

function modifier_boss_ifdat_touch_of_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end