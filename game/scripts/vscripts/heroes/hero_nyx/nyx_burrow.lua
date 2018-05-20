nyx_burrow = class({})
LinkLuaModifier( "modifier_nyx_burrow", "heroes/hero_nyx/nyx_burrow.lua" ,LUA_MODIFIER_MOTION_NONE )

function nyx_burrow:IsStealable()
	return false
end

function nyx_burrow:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_nyx_burrow") then
		return "nyx_assassin_unburrow"
	else
		return "nyx_assassin_burrow"
	end
end

function nyx_burrow:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_nyx_burrow") then
		return 0
	else
		return 0.75
	end
end

function nyx_burrow:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_4, 1.5 )
	EmitSoundOn("Hero_NyxAssassin.Burrow.In", caster)

	if not caster:HasModifier("modifier_nyx_burrow") then
		if caster:HasModifier("modifier_in_water") then
			ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_water.vpcf", PATTACH_POINT, caster, {})
		else
			ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow.vpcf", PATTACH_POINT, caster, {})
		end

		ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale_burrow_soil.vpcf", PATTACH_POINT, caster, {})
	end

	return true
end

function nyx_burrow:OnSpellStart()
	local caster = self:GetCaster()
	
	if caster:HasModifier("modifier_nyx_burrow") then
		caster:RemoveModifierByName("modifier_nyx_burrow")
	else
		caster:AddNewModifier(caster, self, "modifier_nyx_burrow", {})
	end
end

modifier_nyx_burrow = class({})
function modifier_nyx_burrow:GetTexture()
	return "nyx_assassin_burrow"
end

function modifier_nyx_burrow:CheckState()
	local state = { [MODIFIER_STATE_DISARMED] = true,
					[MODIFIER_STATE_ROOTED] = true}
					
	if self:GetParent():HasModifier("modifier_nyx_vendetta") then
		state = {[MODIFIER_STATE_ROOTED] = true}
	end

	return state
end

function modifier_nyx_burrow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		--MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_nyx_burrow:GetModifierModelChange()
	return "models/heroes/nerubian_assassin/mound.vmdl"
end

--[[function modifier_nyx_burrow:GetModifierDisableTurning()
	return 1
end]]

function modifier_nyx_burrow:GetModifierHealthRegenPercentage()
	return self:GetSpecialValueFor("regen")
end

function modifier_nyx_burrow:GetModifierPercentageManaRegen()
	return self:GetSpecialValueFor("regen")
end

function modifier_nyx_burrow:GetModifierIncomingDamage_Percentage()
	return self:GetSpecialValueFor("reduction")
end

function modifier_nyx_burrow:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_BURROW_END, rate=1})
		if caster:HasModifier("modifier_in_water") then
			EmitSoundOn("Hero_NyxAssassin.Burrow.Out.River", caster)
			ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_exit_water.vpcf", PATTACH_POINT, caster, {})
		else
			EmitSoundOn("Hero_NyxAssassin.Burrow.Out", caster)
			ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_exit.vpcf", PATTACH_POINT, caster, {})
		end
	end
end

function modifier_nyx_burrow:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_inground.vpcf"
end

function modifier_nyx_burrow:IsPurgable()
	return false
end

function modifier_nyx_burrow:IsPurgeException()
	return false
end