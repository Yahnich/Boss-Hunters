lycan_shapeshift_bh = class({})

function lycan_shapeshift_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local transformation = self:GetSpecialValueFor("transformation_time")
	self:Stun(caster, transformation)
	
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_lycan_shapeshift_bh", {duration = duration + transformation})
	caster:AddNewModifier(caster, self, "modifier_lycan_shapeshift_bh_wolf", {duration = duration + transformation})
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	for _, summon in ipairs( caster:GetSummons() ) do
		summon:AddNewModifier(caster, self, "modifier_lycan_shapeshift_bh", {duration = duration})
		ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_POINT_FOLLOW, summon)
	end
end

modifier_lycan_shapeshift_bh = class({})
LinkLuaModifier("modifier_lycan_shapeshift_bh", "heroes/hero_lycan/lycan_shapeshift_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_shapeshift_bh:OnCreated()
	self.bonus_ms = self:GetSpecialValueFor("speed")
	self.vision = self:GetSpecialValueFor("bonus_night_vision")
	self.bat = self:GetSpecialValueFor("bat_reduction")
	
	self:GetParent():HookInModifier("GetBaseAttackTime_Bonus", self)
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		self:AddEffect(nFXIndex)
		
		self:StartIntervalThink(0.5)
	end
end

function modifier_lycan_shapeshift_bh:OnDestroy()
	self:GetParent():HookOutModifier("GetBaseAttackTime_Bonus", self)
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_lycan_shapeshift_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	for _, summon in ipairs( caster:GetSummons() ) do
		if not summon:HasModifier("modifier_lycan_shapeshift_bh") then
			summon:AddNewModifier(caster, ability, "modifier_lycan_shapeshift_bh", {duration = self:GetRemainingTime() })
			ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_POINT_FOLLOW, summon)
		end
	end
end


function modifier_lycan_shapeshift_bh:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] =  true}
end

function modifier_lycan_shapeshift_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
			MODIFIER_PROPERTY_BONUS_NIGHT_VISION}
end

function modifier_lycan_shapeshift_bh:GetModifierMoveSpeed_AbsoluteMin()
	return self.bonus_ms
end

function modifier_lycan_shapeshift_bh:GetMoveSpeedLimitBonus()
	return self.bonus_ms - 550
end

function modifier_lycan_shapeshift_bh:GetBonusNightVision()
	return self.vision
end

function modifier_lycan_shapeshift_bh:GetBaseAttackTime_Bonus()
	return self.bat
end

function modifier_lycan_shapeshift_bh:IsPurgable()
	return false
end

modifier_lycan_shapeshift_bh_wolf = class({})
LinkLuaModifier("modifier_lycan_shapeshift_bh_wolf", "heroes/hero_lycan/lycan_shapeshift_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_shapeshift_bh_wolf:OnCreated()
	if IsServer() and self:GetCaster():HasTalent("special_bonus_unique_lycan_shapeshift_1") then
		GameRules:BeginTemporaryNight( self:GetRemainingTime() )
	end
end

function modifier_lycan_shapeshift_bh_wolf:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_CHANGE}
end

function modifier_lycan_shapeshift_bh_wolf:GetModifierModelChange()
	return "models/heroes/lycan/lycan_wolf.vmdl"
end

function modifier_lycan_shapeshift_bh_wolf:IsHidden()
	return true
end

function modifier_lycan_shapeshift_bh_wolf:IsPurgable()
	return false
end