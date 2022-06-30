sven_valiant_charge = class({})

function sven_valiant_charge:GetCastRange(target, position)
	if IsClient() then
		return 0
	elseif IsServer() then
		return self:GetTalentSpecialValueFor("distance")
	end
end

function sven_valiant_charge:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_sven_valiant_charge_2")
end

function sven_valiant_charge:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	caster:RemoveModifierByName("modifier_sven_valiant_charge")
	caster:RemoveModifierByName("modifier_sven_valiant_charge_talent")
	
	
	caster:EmitSound("Hero_Sven.WarCry.Signet")
	caster:MoveToPosition( position )
	Timers:CreateTimer( function() caster:AddNewModifier(caster, self, "modifier_sven_valiant_charge", {duration = self:GetTalentSpecialValueFor("max_duration")}) end )
end

modifier_sven_valiant_charge = class({})
LinkLuaModifier("modifier_sven_valiant_charge", "heroes/hero_sven/sven_valiant_charge", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_valiant_charge:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_sven_valiant_charge:OnRefresh()
	self.movespeed = self:GetParent():GetIdealSpeedNoSlows() * self:GetTalentSpecialValueFor("movespeed") / 100
	self.damage = self:GetTalentSpecialValueFor("armor_damage")
	self.knockback = self:GetTalentSpecialValueFor("knockback")
	self.daze_duration = self:GetTalentSpecialValueFor("daze_duration")
	if IsServer() then
		local parent = self:GetParent()
		self.targets = {}
		self.talent = parent:HasTalent("special_bonus_unique_sven_valiant_charge_1")
		self.stunDur = parent:FindTalentValue("special_bonus_unique_sven_valiant_charge_1")
		
		self.distance = self:GetAbility():GetTrueCastRange()
		self.lastPos = parent:GetAbsOrigin()
	end
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_sven_valiant_charge:OnIntervalThink()
	local parent = self:GetParent()
	local position = parent:GetAbsOrigin()
	local radius = (parent:GetHullRadius() * 2 + parent:GetCollisionPadding() * 2) * parent:GetModelScale() + 64
	GridNav:DestroyTreesAroundPoint( position, radius, true ) 
	for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( position, radius ) ) do
		if not self.targets[enemy:entindex()] then
			self.targets[enemy:entindex()] = true
			if not enemy:TriggerSpellAbsorb( self ) then
				self:GetAbility():DealDamage( parent, enemy, self.damage * parent:GetPhysicalArmorValue(false) )
				enemy:ApplyKnockBack( position, 0.6, 0.6, self.knockback, 150, parent, self:GetAbility(), false )
				enemy:Daze(self:GetAbility(), parent, self.daze_duration)
				if self.talent then
					self:GetAbility():Stun( enemy, self.stunDur + 0.6 )
				end
			end
		end
	end
	self.distance = self.distance - CalculateDistance( self.lastPos, position )
	self.lastPos = position
	if self.distance <= 0 then
		self:Destroy()
	end
end

function modifier_sven_valiant_charge:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if parent:HasTalent("special_bonus_unique_sven_valiant_charge_2") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_sven_valiant_charge_talent", {duration = parent:FindTalentValue("special_bonus_unique_sven_valiant_charge_2", "duration")})
		end
	end
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_sven_valiant_charge:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_sven_valiant_charge:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT }
end

function modifier_sven_valiant_charge:GetModifierMoveSpeed_AbsoluteMin()
	return self.movespeed
end

function modifier_sven_valiant_charge:GetMoveSpeedLimitBonus()
	return -1
end

function modifier_sven_valiant_charge:GetEffectName()
	return "particles/units/heroes/hero_earthshaker/earthshaker_totem_leap_blur_b.vpcf"
end

modifier_sven_valiant_charge_talent = class({})
LinkLuaModifier("modifier_sven_valiant_charge_talent", "heroes/hero_sven/sven_valiant_charge", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_valiant_charge_talent:OnCreated()
	self.movespeed = 550
end

function modifier_sven_valiant_charge_talent:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_sven_valiant_charge_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_sven_valiant_charge_talent:GetModifierMoveSpeed_AbsoluteMin()
	return self.movespeed
end

function modifier_sven_valiant_charge_talent:GetEffectName()
	return "particles/units/heroes/hero_earthshaker/earthshaker_totem_leap_blur_b.vpcf"
end