skywrath_concussive = class({})

function skywrath_concussive:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasTalent("special_bonus_unique_skywrath_concussive_1") then
		return -1
	end
	return self:GetSpecialValueFor("search_range")
end

function skywrath_concussive:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_SkywrathMage.ConcussiveShot.Cast", caster)

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange(), {order=FIND_CLOSEST})
	for _,enemy in pairs(enemies) do
		self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf", enemy, self:GetSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, self:GetSpecialValueFor("vision"))
		if caster:HasScepter() then
	        local enemies2 = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange(), {order=FIND_CLOSEST})
	        for _,enemy2 in pairs(enemies2) do
	            if enemy2 ~= enemy then
	                self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf", enemy2, self:GetSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, self:GetSpecialValueFor("vision"))
	                break
	            end
	        end
	    end
		break
	end
end

function skywrath_concussive:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
    	EmitSoundOn("Hero_SkywrathMage.ConcussiveShot.Target", hTarget)
		local radius = self:GetSpecialValueFor("radius")
        local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), radius)
		local damage = self:GetSpecialValueFor("damage")
		local minion_mult = self:GetSpecialValueFor("minion_damage") / 100
        for _,enemy in pairs(enemies) do
        	enemy:AddNewModifier(caster, self, "modifier_skywrath_concussive", {Duration = self:GetSpecialValueFor("slow_duration")})
			local endDamage = damage
			if enemy:IsMinion() then
				endDamage = damage * (1 + minion_mult)
			end
        	self:DealDamage(caster, enemy, endDamage, {}, 0)
        end
		if caster:HasTalent("special_bonus_unique_skywrath_concussive_2") then
			local talentRadius = radius * caster:FindTalentValue("special_bonus_unique_skywrath_concussive_2")
			local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), talentRadius)
			for _,enemy in pairs(enemies) do
				local distance = CalculateDistance( enemy, hTarget )
				local buffer = enemy:GetHullRadius() + hTarget:GetHullRadius() + enemy:GetCollisionPadding() + hTarget:GetCollisionPadding()
				enemy:ApplyKnockBack(hTarget:GetAbsOrigin(), 0.75, 0.75, -math.max( 0, (distance - buffer) ), 0, caster, self, false)
			end
		end
    end
end

modifier_skywrath_concussive = class({})
LinkLuaModifier( "modifier_skywrath_concussive","heroes/hero_skywrath/skywrath_concussive.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_skywrath_concussive:OnCreated()
	self:OnRefresh()
end

function modifier_skywrath_concussive:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow")
	if self:GetParent():IsMinion() then
		self.slow = self.slow + self:GetSpecialValueFor("minion_slow")
	end
end

function modifier_skywrath_concussive:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return funcs
end

function modifier_skywrath_concussive:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
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