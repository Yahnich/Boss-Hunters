sven_valiant_charge = class({})

function sven_valiant_charge:GetCastRange(target, position)
	return 0
end

function sven_valiant_charge:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local distance = CalculateDistance(position, caster)
	local endPosition = caster:GetAbsOrigin() + CalculateDirection(position, caster) * math.min( distance, self:GetTalentSpecialValueFor("distance") + caster:GetBonusCastRange() )
	caster:MoveToPosition( endPosition )
	caster:AddNewModifier(caster, self, "modifier_sven_valiant_charge", {duration = distance/( caster:GetIdealSpeed() * self:GetTalentSpecialValueFor("movespeed") / 100 ) })
	caster:EmitSound("Hero_Sven.WarCry.Signet")
end

modifier_sven_valiant_charge = class({})
LinkLuaModifier("modifier_sven_valiant_charge", "heroes/hero_sven/sven_valiant_charge", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_valiant_charge:OnCreated()
	self.movespeed = self:GetParent():GetIdealSpeed() * self:GetTalentSpecialValueFor("movespeed") / 100
	self.damage = self:GetTalentSpecialValueFor("armor_damage")
	self.knockback = self:GetTalentSpecialValueFor("knockback")
	self.daze_duration = self:GetTalentSpecialValueFor("daze_duration")
	if IsServer() then
		local parent = self:GetParent()
		self.targets = {}
		self.talent = parent:HasTalent("special_bonus_unique_sven_valiant_charge_1")
		self.stunDur = parent:FindTalentValue("special_bonus_unique_sven_valiant_charge_1")
		self:StartIntervalThink(0)
	end
end

function modifier_sven_valiant_charge:OnIntervalThink()
	local parent = self:GetParent()
	for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), parent:GetHullRadius() + parent:GetCollisionPadding() + 64 ) ) do
		if not self.targets[enemy:entindex()] then
			self.targets[enemy:entindex()] = true;
			self:GetAbility():DealDamage( parent, enemy, self.damage * parent:GetPhysicalArmorValue() )
			if self.talent then
				self:GetAbility():Stun( enemy, self.stunDur )
			else
				enemy:ApplyKnockBack( parent:GetAbsOrigin(), 0.6, 0.6, self.knockback, 150, parent, self:GetAbility() )
			end
		end
	end
end

function modifier_sven_valiant_charge:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if parent:HasTalent("special_bonus_unique_sven_valiant_charge_2") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_sven_valiant_charge_talent", {duration = parent:FindTalentValue("special_bonus_unique_sven_valiant_charge_2")})
		end
	end
end

function modifier_sven_valiant_charge:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_sven_valiant_charge:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_sven_valiant_charge:GetModifierMoveSpeed_AbsoluteMin()
	return self.movespeed
end

function modifier_sven_valiant_charge:GetEffectName()
	return "particles/units/heroes/hero_earthshaker/earthshaker_totem_leap_blur_b.vpcf"
end

modifier_sven_valiant_charge_talent = class({})
LinkLuaModifier("modifier_sven_valiant_charge_talent", "heroes/hero_sven/sven_valiant_charge", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_valiant_charge_talent:OnCreated()
	self.movespeed = self:GetTalentSpecialValueFor("movespeed")
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