chen_penitence_ebf = class({})
LinkLuaModifier( "modifier_chen_penitence_ebf", "heroes/hero_chen/chen_penitence_ebf.lua" ,LUA_MODIFIER_MOTION_NONE )

function chen_penitence_ebf:IsStealable()
	return true
end

function chen_penitence_ebf:IsHiddenWhenStolen()
	return false
end

function chen_penitence_ebf:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function chen_penitence_ebf:OnSpellStart()
	EmitSoundOn("Hero_Chen.PenitenceCast", self:GetCaster())

	self:FireTrackingProjectile("particles/units/heroes/hero_chen/chen_penitence_proj.vpcf", self:GetCursorTarget(), 2000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 200)

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCursorTarget():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		if enemy ~= self:GetCursorTarget() then
			self:FireTrackingProjectile("particles/units/heroes/hero_chen/chen_penitence_proj.vpcf", enemy, 2000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 200)
			break
		end
	end
end

function chen_penitence_ebf:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		EmitSoundOn("Hero_Chen.PenitenceImpact", self:GetCaster())
		
		ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_penitence.vpcf", PATTACH_POINT, hTarget, {})
		hTarget:AddNewModifier(caster, self, "modifier_chen_penitence_ebf", {Duration = self:GetTalentSpecialValueFor("duration")})

		if caster:HasTalent("special_bonus_unique_chen_penitence_ebf_2") then
			local damage = caster:GetAttackDamage()*caster:FindTalentValue("special_bonus_unique_chen_penitence_ebf_2")/100
			self:DealDamage(caster, hTarget, damage, {damage_type=DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end

modifier_chen_penitence_ebf = class({})

function modifier_chen_penitence_ebf:IsDebuff()
	return true
end

function modifier_chen_penitence_ebf:IsPurgable()
	return false
end

function modifier_chen_penitence_ebf:GetEffectName()
	return "particles/units/heroes/hero_chen/chen_penitence_debuff.vpcf"
end

function modifier_chen_penitence_ebf:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_chen_penitence_ebf:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("bonus_movement_speed")
end

function modifier_chen_penitence_ebf:GetModifierIncomingDamage_Percentage()
	return self:GetTalentSpecialValueFor("bonus_damage_taken")
end