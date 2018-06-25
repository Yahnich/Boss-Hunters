ogre_magi_ignite_bh = class({})
LinkLuaModifier("modifier_ogre_magi_ignite_bh", "heroes/hero_ogre_magi/ogre_magi_ignite_bh", LUA_MODIFIER_MOTION_NONE)

function ogre_magi_ignite_bh:IsStealable()
	return true
end

function ogre_magi_ignite_bh:IsHiddenWhenStolen()
	return false
end

function ogre_magi_ignite_bh:OnSpellStart()
	self:Ignite()
end

function ogre_magi_ignite_bh:Ignite()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_OgreMagi.Ignite.Cast", caster)
	self:FireTrackingProjectile("particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf", target, 1000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_3, true, true, 100)
end

function ogre_magi_ignite_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_OgreMagi.Ignite.Target", hTarget)
		hTarget:AddNewModifier(caster, self, "modifier_ogre_magi_ignite_bh", {Duration = self:GetSpecialValueFor("duration")})
		if RollPercentage(self:GetSpecialValueFor("chance")) then
			local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetSpecialValueFor("ignite_aoe"))
			for _,enemy in pairs(enemies) do
				if enemy ~= hTarget then
					enemy:AddNewModifier(caster, self, "modifier_ogre_magi_ignite_bh", {Duration = self:GetSpecialValueFor("duration")})
				end
			end
		end
	end
end

modifier_ogre_magi_ignite_bh = class({})
function modifier_ogre_magi_ignite_bh:OnCreated(table)
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_ogre_magi_ignite_bh:OnIntervalThink()
	EmitSoundOn("Hero_OgreMagi.Ignite.Damage", self:GetParent())
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("damage"), {}, 0)
end

function modifier_ogre_magi_ignite_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_ogre_magi_ignite_bh:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("slow_pct")
end

function modifier_ogre_magi_ignite_bh:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf"
end

function modifier_ogre_magi_ignite_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_ogre_magi_ignite_bh:StatusEffectPriority()
	return 10
end

function modifier_ogre_magi_ignite_bh:IsDebuff()
	return true
end