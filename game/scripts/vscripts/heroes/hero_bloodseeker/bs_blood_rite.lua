bs_blood_rite = class({})

function bs_blood_rite:IsStealable()
	return true
end

function bs_blood_rite:IsHiddenWhenStolen()
	return false
end

function bs_blood_rite:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_bs_blood_rite_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_bs_blood_rite_2") end
    return cooldown
end

function bs_blood_rite:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", caster)
	EmitSoundOnLocationWithCaster(point, "hero_bloodseeker.bloodRite", caster)
	CreateModifierThinker(caster, self, "modifier_bs_blood_rite", {Duration = self:GetSpecialValueFor("delay")}, point, caster:GetTeam(), false)
end

modifier_bs_blood_rite = class({})
LinkLuaModifier("modifier_bs_blood_rite", "heroes/hero_bloodseeker/bs_blood_rite", LUA_MODIFIER_MOTION_NONE)

function modifier_bs_blood_rite:OnCreated(table)
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("duration")
	self.damage = self:GetSpecialValueFor("damage")
	if IsServer() then

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_spell_bloodbath_bubbles.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius,self.radius,self.radius))
		self:AttachEffect(nfx)
	end
end

function modifier_bs_blood_rite:OnRemoved()
	if IsServer() then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
		if #enemies > 0 then
			ParticleManager:FireParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
		end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( ability ) then
				EmitSoundOn("hero_bloodseeker.bloodRite.silence", enemy)
				enemy:AddNewModifier( caster, ability, "modifier_bs_blood_rite_silence", {duration = self.duration})
				ability:DealDamage(self:GetCaster(), enemy, self.damage, {}, 0)
			end
		end
	end
end

modifier_bs_blood_rite_silence = class({})
LinkLuaModifier("modifier_bs_blood_rite_silence", "heroes/hero_bloodseeker/bs_blood_rite", LUA_MODIFIER_MOTION_NONE)

function modifier_bs_blood_rite_silence:OnCreated(kv)
	self:OnRefresh()
end

function modifier_bs_blood_rite_silence:OnRefresh(kv)
	self.attackspeed = self:GetCaster():FindTalentValue("special_bonus_unique_bs_blood_rite_1")
end

function modifier_bs_blood_rite_silence:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_bs_blood_rite_silence:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_bs_blood_rite_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_bs_blood_rite_silence:IsHidden()
	return false
end

function modifier_bs_blood_rite_silence:CheckState()
	local state = { [MODIFIER_STATE_SILENCED] = true}
	return state
end

function modifier_bs_blood_rite_silence:IsPurgable()
	return true
end

function modifier_bs_blood_rite_silence:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_silenced.vpcf"
end