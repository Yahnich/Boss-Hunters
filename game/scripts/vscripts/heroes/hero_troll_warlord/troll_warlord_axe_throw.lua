troll_warlord_axe_throw = class({})

function troll_warlord_axe_throw:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasScepter() then
		cd = cd + self:GetTalentSpecialValueFor("scepter_cdr")
	end
	return cd
end

function troll_warlord_axe_throw:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("axe_range")
end

function troll_warlord_axe_throw:GetManaCost( iLvl )
	if self:GetCaster():HasScepter() then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

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
	local distance = self:GetTrueCastRange( )
	local width = self:GetTalentSpecialValueFor("axe_width")
	local angle = self:GetTalentSpecialValueFor("axe_spread") / 2
	
	self.castIndex = (self.castIndex or 0) + 1
	if self.castIndex > 10 then
		self.castIndex = 0
	end
	self.axes = {}
	self.casts = {}
	self.casts[self.castIndex] = {}
	
	for i = 1, axes do
		local divider = 0
		if (axes % 2) == 0 then
			divider = angle / 2
		end
		local newAngle = math.abs( math.ceil( ( i - ( (axes % 2) ) ) / 2 ) * (angle) - divider ) * (-1)^i ;
		local newInit = RotatePosition(caster:GetAbsOrigin(), QAngle(0, newAngle, 0), initPos)
		local newDir = CalculateDirection(newInit, caster)
		
		local projID = self:AxeThrow( newDir, speed, distance, width)
		self.axes[projID] = self.castIndex
	end
	caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Ranged")
end

function troll_warlord_axe_throw:AxeThrow(direction, fSpeed, fDistance, fWidth)
	local speed = fSpeed or self:GetTalentSpecialValueFor("axe_speed")
	local distance = fDistance or self:GetTrueCastRange( )
	local width = fWidth or self:GetTalentSpecialValueFor("axe_width")
	return self:FireLinearProjectile("particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf", direction * speed, distance, width, nil, false, true, width)
end

function troll_warlord_axe_throw:OnProjectileHitHandle( target, position, projID )
	if target and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("axe_damage")
		local slowDur = self:GetTalentSpecialValueFor("axe_slow_duration")
		if not self.axes[projID] or not self.casts[self.axes[projID]][target] then
			self:DealDamage( caster, target, damage )
			target:AddNewModifier( caster, self, "modifier_troll_warlord_axe_throw", {duration = slowDur})
			
			if caster:HasScepter() then target:Dispel() end
			if self.axes[projID] then self.casts[self.axes[projID]][target] = true end
		end
		
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
	if params.attacker == parent then
		if parent:IsRangedAttacker() and self:RollPRNG(self.chance) then
			self:GetAbility():AxeThrow( parent:GetForwardVector() )
		elseif not parent:IsRangedAttacker() and self:RollPRNG(self.chance) then
			self.axes:SummonWhirlingAxe( 1.75 )
		end
	end
end

function modifier_troll_warlord_whirling_axes_talent:IsHidden()
	return true
end