vengefulspirit_swap = class({})
LinkLuaModifier( "modifier_vengefulspirit_swap", "heroes/hero_vengeful/vengefulspirit_swap.lua",LUA_MODIFIER_MOTION_NONE )

function vengefulspirit_swap:IsStealable()
	return true
end

function vengefulspirit_swap:IsHiddenWhenStolen()
	return false
end

function vengefulspirit_swap:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_VengefulSpirit.NetherSwap", caster)

	local startPos = caster:GetAbsOrigin()
	local endPos = target:GetAbsOrigin()

	ParticleManager:FireRopeParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_POINT, caster, target, {})
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_POINT, target, caster, {})

	if target:GetTeam() ~= caster:GetTeam() then
		if not target:TriggerSpellAbsorb( self ) then
			FindClearSpaceForUnit(caster, endPos, true)
			FindClearSpaceForUnit(target, startPos, true)
		end
	else
		local threat = caster:GetThreat()
		caster:SetThreat(target:GetThreat())
		target:SetThreat(threat)
		caster:AddNewModifier(caster, self, "modifier_vengefulspirit_swap", {Duration = self:GetSpecialValueFor("duration")})
		target:AddNewModifier(caster, self, "modifier_vengefulspirit_swap", {Duration = self:GetSpecialValueFor("duration")})
		FindClearSpaceForUnit(caster, endPos, true)
		FindClearSpaceForUnit(target, startPos, true)
	end

	caster:StartGesture(ACT_DOTA_CHANNEL_END_ABILITY_4)
end

modifier_vengefulspirit_swap = class({})
function modifier_vengefulspirit_swap:CheckState()
	local state = {    [MODIFIER_STATE_INVULNERABLE]=true,
					   [MODIFIER_STATE_ATTACK_IMMUNE]=true,
					   [MODIFIER_STATE_MAGIC_IMMUNE]=true,
					   [MODIFIER_STATE_NO_UNIT_COLLISION]=true,
					}
	return state
end

function modifier_vengefulspirit_swap:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_vengefulspirit_swap:GetModifierMoveSpeedBonus_Percentage()
    return self:GetSpecialValueFor("speed")
end