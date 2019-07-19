chen_penitence_bh = class({})

function chen_penitence_bh:IsStealable()
	return true
end

function chen_penitence_bh:IsHiddenWhenStolen()
	return false
end

function chen_penitence_bh:OnSpellStart()
	EmitSoundOn("Hero_Chen.PenitenceCast", self:GetCaster())

	self:FireTrackingProjectile("particles/units/heroes/hero_chen/chen_penitence_proj.vpcf", self:GetCursorTarget(), 2000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 200)

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCursorTarget():GetAbsOrigin(), self:GetTrueCastRange(), {})
	for _,enemy in pairs(enemies) do
		if enemy ~= self:GetCursorTarget() and enemy:IsMinion() then
			self:FireTrackingProjectile("particles/units/heroes/hero_chen/chen_penitence_proj.vpcf", enemy, 2000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 200)
		end
	end
end

function chen_penitence_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		EmitSoundOn("Hero_Chen.PenitenceImpact", self:GetCaster())
		
		ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_penitence.vpcf", PATTACH_POINT, hTarget, {})
		hTarget:AddNewModifier(caster, self, "modifier_chen_penitence_bh", {Duration = self:GetTalentSpecialValueFor("duration")})

		if caster:HasTalent("special_bonus_unique_chen_penitence_bh_2") then
			local damage = caster:GetAttackDamage()*caster:FindTalentValue("special_bonus_unique_chen_penitence_bh_2")/100
			self:DealDamage(caster, hTarget, damage, {damage_type=DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end

modifier_chen_penitence_bh = class({})
LinkLuaModifier( "modifier_chen_penitence_bh", "heroes/hero_chen/chen_penitence_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_chen_penitence_bh:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("buff_duration")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
end

function modifier_chen_penitence_bh:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("buff_duration")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
end

function modifier_chen_penitence_bh:GetEffectName()
	return "particles/units/heroes/hero_chen/chen_penitence_debuff.vpcf"
end

function modifier_chen_penitence_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_chen_penitence_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_chen_penitence_bh:OnAttackLanded(params)
	if self:GetParent() == params.target then
		params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_chen_penitence_bh_buff", {duration = self.duration})
	end
end

function modifier_chen_penitence_bh:IsDebuff()
	return true
end

modifier_chen_penitence_bh_buff = class({})
LinkLuaModifier( "modifier_chen_penitence_bh_buff", "heroes/hero_chen/chen_penitence_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_chen_penitence_bh_buff:OnCreated()
	self.as = self:GetTalentSpecialValueFor("bonus_as")
end

function modifier_chen_penitence_bh_buff:OnRefresh()
	self.as = self:GetTalentSpecialValueFor("bonus_as")
end

function modifier_chen_penitence_bh_buff:GetModifierAttackSpeedBonus()
	return self.as
end