ursa_overpower_bh = class({})
LinkLuaModifier("modifier_ursa_overpower_bh", "heroes/hero_ursa/ursa_overpower_bh", LUA_MODIFIER_MOTION_NONE)

function ursa_overpower_bh:IsStealable()
	return true
end

function ursa_overpower_bh:IsHiddenWhenStolen()
	return false
end

function ursa_overpower_bh:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
	return true
end

function ursa_overpower_bh:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Ursa.Overpower", caster)

	caster:AddNewModifier(caster, self, "modifier_ursa_overpower_bh", {Duration = self:GetTalentSpecialValueFor("duration")}):SetStackCount(self:GetTalentSpecialValueFor("max_attacks"))
end

modifier_ursa_overpower_bh = class({})

function modifier_ursa_overpower_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_ursa_overpower_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
			}
end

function modifier_ursa_overpower_bh:GetActivityTranslationModifiers()
	return "overpower" .. self:GetStackCount()
end

function modifier_ursa_overpower_bh:GetModifierAttackSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("attack_speed_bonus_pct")
end

function modifier_ursa_overpower_bh:OnAttack(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		local ability = self:GetAbility()

		if caster == attacker then

			if caster:HasTalent("special_bonus_unique_ursa_overpower_bh_1") then
				local damage = caster:GetAttackDamage() * caster:FindTalentValue("special_bonus_unique_ursa_overpower_bh_1")/100
				ability:Cleave(target, damage, 150, 330, caster:GetAttackRange()*3, "particles/units/heroes/hero_sven/sven_spell_great_cleave_gods_strength.vpcf" )
				local enemies = caster:FindEnemyUnitsInCone(caster:GetForwardVector(), caster:GetAbsOrigin(), 330, caster:GetAttackRange()*3, {})
				for _,enemy in pairs(enemies) do
					if enemy ~= target then
						local ability = caster:FindAbilityByName("ursa_fury_swipes_bh")
						enemy:AddNewModifier(caster, ability, "modifier_ursa_fury_swipes_bh", {duration = ability:GetTalentSpecialValueFor("duration")}):IncrementStackCount()
					end
				end
			end

			if caster:HasTalent("special_bonus_unique_ursa_overpower_bh_2") then
				target:Paralyze(ability, caster, caster:FindTalentValue("special_bonus_unique_ursa_overpower_bh_2"))
			end

			if self:GetStackCount() > 1 then
				self:DecrementStackCount()
			else
				self:Destroy()
			end
		end
	end
end

function modifier_ursa_overpower_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_overpower.vpcf"
end

function modifier_ursa_overpower_bh:StatusEffectPriority()
	return 10
end

function modifier_ursa_overpower_bh:IsDebuff()
	return false
end