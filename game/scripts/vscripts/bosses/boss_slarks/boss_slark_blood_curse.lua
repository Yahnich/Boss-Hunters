boss_slark_blood_curse	 = class({})


function boss_slark_blood_curse:IsStealable()
	return true
end

function boss_slark_blood_curse:IsHiddenWhenStolen()
	return false
end

function boss_slark_blood_curse:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_boss_slark_blood_curse_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_boss_slark_blood_curse_2") end
    return cooldown
end

function boss_slark_blood_curse:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", caster)
	EmitSoundOnLocationWithCaster(point, "hero_bloodseeker.bloodRite", caster)
	CreateModifierThinker(caster, self, "modifier_boss_slark_blood_curse", {Duration = self:GetSpecialValueFor("delay")}, point, caster:GetTeam(), false)
end

modifier_boss_slark_blood_curse = class({})
LinkLuaModifier("modifier_boss_slark_blood_curse", "bosses/boss_slarks/boss_slark_blood_curse", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_slark_blood_curse:OnCreated(table)
	if IsServer() then
		local radius = self:GetSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_spell_bloodbath_bubbles.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
		self:AttachEffect(nfx)
	end
end

function modifier_boss_slark_blood_curse:OnRemoved()
	if IsServer() then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
		if #enemies > 0 then
			ParticleManager:FireParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
		end
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				EmitSoundOn("hero_bloodseeker.bloodRite.silence", enemy)
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_boss_slark_blood_curse_amp", {Duration = self:GetSpecialValueFor("duration")})
			end
		end
	end
end


modifier_boss_slark_blood_curse_amp = class({})
LinkLuaModifier("modifier_boss_slark_blood_curse_amp", "bosses/boss_slarks/boss_slark_blood_curse", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_slark_blood_curse_amp:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_boss_slark_blood_curse_amp:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_slark_blood_curse_amp:GetModifierIncomingDamage_Percentage()
	return self:GetSpecialValueFor("damage_amp")
end

function modifier_boss_slark_blood_curse_amp:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_silenced.vpcf"
end

function modifier_boss_slark_blood_curse_amp:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end