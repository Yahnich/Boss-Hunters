ogre_magi_bloodlust_bh = class({})
LinkLuaModifier( "modifier_ogre_magi_bloodlust_bh", "heroes/hero_ogre_magi/ogre_magi_bloodlust_bh.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ogre_magi_bloodlust_bh_buff", "heroes/hero_ogre_magi/ogre_magi_bloodlust_bh.lua",LUA_MODIFIER_MOTION_NONE )

function ogre_magi_bloodlust_bh:GetIntrinsicModifierName()
	return "modifier_ogre_magi_bloodlust_bh"
end

function ogre_magi_bloodlust_bh:IsStealable()
	return true
end

function ogre_magi_bloodlust_bh:IsHiddenWhenStolen()
	return false
end

function ogre_magi_bloodlust_bh:OnAbilityPhaseStart()
	EmitSoundOn("Hero_OgreMagi.Bloodlust.Cast", self:GetCaster())	
	return true
end

function ogre_magi_bloodlust_bh:GetCooldown(nLevel)
    local cooldown = self.BaseClass.GetCooldown( self, nLevel )
    if self.newCoolDown then
    	cooldown = cooldown - self.newCoolDown
    end
    return cooldown
end

function ogre_magi_bloodlust_bh:OnSpellStart()
	self:Bloodlust()
end

function ogre_magi_bloodlust_bh:Bloodlust()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_OgreMagi.Bloodlust.Target", target)
	EmitSoundOn("Hero_OgreMagi.Bloodlust.Target.FP", target)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack3", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 2, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 3, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)
	
	target:AddNewModifier(caster, self, "modifier_ogre_magi_bloodlust_bh_buff", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_ogre_magi_bloodlust_bh = class({})

if IsServer() then
	function modifier_ogre_magi_bloodlust_bh:OnCreated(kv)
		self:StartIntervalThink(0.1)
	end

	function modifier_ogre_magi_bloodlust_bh:OnRemoved()
		StopSoundOn("Hero_Bristleback.QuillSpray.Cast", self:GetCaster())
	end

	function modifier_ogre_magi_bloodlust_bh:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if ability:GetAutoCastState() and caster:IsAlive() and ability:IsCooldownReady() and ability:IsOwnersManaEnough() and not ability:IsInAbilityPhase() then
			local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetAbility():GetCastRange(caster:GetAbsOrigin(), caster), {order = FIND_CLOSEST})
			for _,friend in pairs(friends) do
				if not friend:HasModifier("modifier_ogre_magi_bloodlust_bh_buff") then
					caster:SetCursorCastTarget(friend)
					caster:CastAbilityOnTarget(friend, ability, caster:GetPlayerOwnerID() )
				end
			end
		elseif not ability:IsOwnersManaEnough() and ability:GetAutoCastState() then
			ability:ToggleAutoCast()
		end
	end
end

function modifier_ogre_magi_bloodlust_bh:IsHidden() return true end

modifier_ogre_magi_bloodlust_bh_buff = class({})

function modifier_ogre_magi_bloodlust_bh_buff:OnCreated(table)
	if self:GetCaster():HasTalent("special_bonus_unique_ogre_magi_bloodlust_bh_2") then
		self.str = self:GetCaster():FindTalentValue("special_bonus_unique_ogre_magi_bloodlust_bh_2")
	end
end

function modifier_ogre_magi_bloodlust_bh_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
	return funcs
end

function modifier_ogre_magi_bloodlust_bh_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("bonus_movement_speed")
end

function modifier_ogre_magi_bloodlust_bh_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("bonus_attack_speed")
end

function modifier_ogre_magi_bloodlust_bh_buff:GetModifierModelScale()
	return self:GetSpecialValueFor("modelscale")
end

function modifier_ogre_magi_bloodlust_bh_buff:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_ogre_magi_bloodlust_bh_buff:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_ogre_magi_bloodlust_bh_buff:IsDebuff()
	return false
end