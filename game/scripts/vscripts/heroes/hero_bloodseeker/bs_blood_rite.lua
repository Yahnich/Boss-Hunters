bs_blood_rite = class({})
LinkLuaModifier("modifier_bs_blood_rite", "heroes/hero_bloodseeker/bs_blood_rite", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bs_bloodrage", "heroes/hero_bloodseeker/bs_bloodrage", LUA_MODIFIER_MOTION_NONE)

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
	CreateModifierThinker(caster, self, "modifier_bs_blood_rite", {Duration = self:GetTalentSpecialValueFor("delay")}, point, caster:GetTeam(), false)
end

modifier_bs_blood_rite = class({})

function modifier_bs_blood_rite:OnCreated(table)
	if IsServer() then
		local radius = self:GetTalentSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_spell_bloodbath_bubbles.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
		self:AttachEffect(nfx)
	end
end

function modifier_bs_blood_rite:OnRemoved()
	if IsServer() then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
		if #enemies > 0 then
			ParticleManager:FireParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
		end
		for _,enemy in pairs(enemies) do
			if enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				EmitSoundOn("hero_bloodseeker.bloodRite.silence", enemy)
				enemy:Silence(self:GetAbility(), self:GetCaster(), self:GetTalentSpecialValueFor("duration"), false)
				if self:GetCaster():HasTalent("special_bonus_unique_bs_blood_rite_1") then
					local ability = self:GetCaster():FindAbilityByName("bs_bloodrage")
					enemy:AddNewModifier(self:GetCaster(), ability, "modifier_bs_bloodrage", {Duration = ability:GetTalentSpecialValueFor("duration")})
				end
				self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
			end
		end
	end
end