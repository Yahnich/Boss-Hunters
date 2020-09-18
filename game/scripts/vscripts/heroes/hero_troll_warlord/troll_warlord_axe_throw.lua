troll_warlord_axe_throw = class({})

function troll_warlord_axe_throw:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_whirling_axes_1") then
		return "modifier_troll_warlord_whirling_axes_talent"
	end
end

function troll_warlord_axe_throw:OnTalentLearned(talent)
	if self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_whirling_axes_1") then 
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_troll_warlord_whirling_axes_talent", {} )
	else
		self:GetCaster():RemoveModifierByName("modifier_troll_warlord_whirling_axes_talent")
	end
end

function troll_warlord_axe_throw:OnSpellStart()
	local caster = self:GetCaster()
	
	local initPos = self:GetCursorPosition()
	local direction = CalculateDirection( initPos , caster )
	
	local axes = self:GetTalentSpecialValueFor("axe_count")
	local speed = self:GetTalentSpecialValueFor("axe_speed")
	local distance = self:GetTalentSpecialValueFor("axe_range")
	local width = self:GetTalentSpecialValueFor("axe_width")
	local angle = self:GetTalentSpecialValueFor("axe_spread") / 2
	
	for i = 1, axes do
		local divider = 0
		if (axes % 2) == 0 then
			divider = angle / 2
		end
		local newAngle = math.abs( math.ceil( ( i - ( (axes % 2) ) ) / 2 ) * (angle) - divider ) * (-1)^i ;
		local newInit = RotatePosition(caster:GetAbsOrigin(), QAngle(0, newAngle, 0), initPos)
		local newDir = CalculateDirection(newInit, caster)
		self:AxeThrow( newDir, speed, distance, width)
	end
	caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Ranged")
end

function troll_warlord_axe_throw:AxeThrow(direction, fSpeed, fDistance, fWidth)
	local speed = fSpeed or self:GetTalentSpecialValueFor("axe_speed")
	local distance = fDistance or self:GetTalentSpecialValueFor("axe_range")
	local width = fWidth or self:GetTalentSpecialValueFor("axe_width")
	self:FireLinearProjectile("particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf", direction * speed, distance, width, nil, false, true, width)
end

function troll_warlord_axe_throw:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("axe_damage")
		local slowDur = self:GetTalentSpecialValueFor("axe_slow_duration")
		self:DealDamage( caster, target, damage )
		target:AddNewModifier( caster, self, "modifier_troll_warlord_axe_throw", {duration = slowDur})
		
		target:EmitSound("Hero_TrollWarlord.WhirlingAxes.Target")
	end
end

modifier_troll_warlord_axe_throw = class({})
LinkLuaModifier( "modifier_troll_warlord_axe_throw", "heroes/hero_troll_warlord/troll_warlord_axe_throw", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_axe_throw:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("movement_speed") * (-1)
end

function modifier_troll_warlord_axe_throw:OnRefresh()
	self.slow = self:GetTalentSpecialValueFor("movement_speed") * (-1)
end

function modifier_troll_warlord_axe_throw:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_troll_warlord_axe_throw:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

modifier_troll_warlord_whirling_axes_talent = class({})
LinkLuaModifier( "modifier_troll_warlord_whirling_axes_talent", "heroes/hero_troll_warlord/troll_warlord_axe_throw", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_whirling_axes_talent:OnCreated()
	if IsServer() then
		self.chance = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_whirling_axes_1")
		self.axes = self:GetCaster():FindAbilityByName("troll_warlord_whirling_axes")
	end
end

function modifier_troll_warlord_whirling_axes_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_troll_warlord_whirling_axes_talent:OnAttackLanded(params)
	local parent = self:GetParent()
	if params.attacker == parent and parent:HasModifier("modifier_troll_warlord_berserkers_rage_bh_melee") then
		if self:RollPRNG(self.chance) then
			self:GetAbility():AxeThrow( parent:GetForwardVector() )
		end
		if self.axes:RollPRNG(self.chance) then
			self.axes:SummonWhirlingAxe( 1.75 )
		end
	end
end

function modifier_troll_warlord_whirling_axes_talent:IsHidden()
	return true
end