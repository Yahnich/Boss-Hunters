skywrath_concussive = class({})
LinkLuaModifier( "modifier_skywrath_concussive","heroes/hero_skywrath/skywrath_concussive.lua",LUA_MODIFIER_MOTION_NONE )

function skywrath_concussive:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasTalent("special_bonus_unique_skywrath_concussive_1") then
		return 100000
	end
	return self:GetTalentSpecialValueFor("search_range")
end

function skywrath_concussive:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_SkywrathMage.ConcussiveShot.Cast", caster)

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange(), {order=FIND_CLOSEST})
	for _,enemy in pairs(enemies) do
		self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, self:GetTalentSpecialValueFor("vision"))
		if caster:HasScepter() then
	        local enemies2 = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange(), {order=FIND_CLOSEST})
	        for _,enemy2 in pairs(enemies2) do
	            if enemy2 ~= enemy then
	                self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf", enemy2, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, self:GetTalentSpecialValueFor("vision"))
	                break
	            end
	        end
	    end
		break
	end
end

function skywrath_concussive:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget then
    	EmitSoundOn("Hero_SkywrathMage.ConcussiveShot.Target", hTarget)
        local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
        	enemy:AddNewModifier(caster, self, "modifier_skywrath_concussive", {Duration = self:GetTalentSpecialValueFor("slow_duration")})
        	self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
        end
    end
end

modifier_skywrath_concussive = class({})
function modifier_skywrath_concussive:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return funcs
end

function modifier_skywrath_concussive:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetTalentSpecialValueFor("slow")
end

function modifier_skywrath_concussive:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_skywrath_concussive:GetEffectName()
    return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_slow_debuff.vpcf"
end

function modifier_skywrath_concussive:IsDebuff()
    return true
end