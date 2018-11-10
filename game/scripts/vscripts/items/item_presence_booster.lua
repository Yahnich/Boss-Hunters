item_presence_booster = class({})

function item_presence_booster:GetIntrinsicModifierName()
	return "modifier_item_presence_booster_passive"
end

function item_presence_booster:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local distance = CalculateDistance( targetPos, caster )
	local direction = CalculateDirection( targetPos, caster )
	if distance > self:GetSpecialValueFor("blink_range") then
		targetPos = caster:GetAbsOrigin() + direction * self:GetSpecialValueFor("blink_range")
	end
	caster:Blink(targetPos)
	local consumedThreat = 0
	local threatRed = self:GetSpecialValueFor("threat_consume")
	local stunDuration = self:GetSpecialValueFor("bash_duration")
	local effectRadius = self:GetSpecialValueFor("active_radius")
	for _, unit in ipairs( caster:FindAllUnitsInRadius( targetPos, effectRadius ) ) do
		if unit:IsSameTeam( caster ) then
			unit:ModifyThreat( threatRed )
			consumedThreat = consumedThreat + threatRed
		else
			self:Stun(unit, stunDuration)
		end
	end
	ParticleManager:FireParticle("particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf", PATTACH_POINT_FOLLOW, caster, { [2] = Vector(effectRadius, 0, 0) })
	caster:ModifyThreat( self:GetSpecialValueFor("active_threat") + consumedThreat )
end

modifier_item_presence_booster_passive = class(itemBaseClass)
LinkLuaModifier( "modifier_item_presence_booster_passive", "items/item_presence_booster.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_presence_booster_passive:OnCreated()
	self.bonusThreat = self:GetSpecialValueFor("bonus_threat")
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.damage = self:GetSpecialValueFor("bonus_damage")
end


function modifier_item_presence_booster_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE 
			}
end

function modifier_item_presence_booster_passive:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_presence_booster_passive:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_presence_booster_passive:Bonus_ThreatGain()
	return self.bonusThreat
end