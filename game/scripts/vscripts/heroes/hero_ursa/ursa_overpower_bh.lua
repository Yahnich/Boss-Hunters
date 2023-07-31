ursa_overpower_bh = class({})

function ursa_overpower_bh:IsStealable()
	return true
end

function ursa_overpower_bh:IsHiddenWhenStolen()
	return false
end

function ursa_overpower_bh:GetIntrinsicModifierName()
	return "modifier_ursa_overpower_autocast"
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

modifier_ursa_overpower_autocast = class({})
LinkLuaModifier("modifier_ursa_overpower_autocast", "heroes/hero_ursa/ursa_overpower_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_ursa_overpower_autocast:OnCreated()
	if IsServer() then self:StartIntervalThink( 0.25 ) end
end

function modifier_ursa_overpower_autocast:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if ability:GetAutoCastState() and ability:IsFullyCastable() and caster:IsAttacking() then
		caster:CastAbilityNoTarget( ability, caster:GetPlayerID() )
	end
end

function modifier_ursa_overpower_autocast:IsHidden()
	return true
end

modifier_ursa_overpower_bh = class({})
LinkLuaModifier("modifier_ursa_overpower_bh", "heroes/hero_ursa/ursa_overpower_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_ursa_overpower_bh:OnCreated(table)
	self.attack_speed = self:GetTalentSpecialValueFor("attack_speed_bonus_pct")
	if IsServer() then
		local caster = self:GetCaster()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_ursa_overpower_bh:DeclareFunctions()
	return {
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			}
end

function modifier_ursa_overpower_bh:GetActivityTranslationModifiers()
	return "overpower" .. self:GetStackCount()
end

function modifier_ursa_overpower_bh:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_ursa_overpower_bh:OnAttack(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		local ability = self:GetAbility()

		if caster == attacker then

			if caster:HasTalent("special_bonus_unique_ursa_overpower_1") then
				local damage = caster:GetAttackDamage() * caster:FindTalentValue("special_bonus_unique_ursa_overpower_1")/100
				ability:Cleave(target, damage, 150, 330, caster:GetAttackRange()*3, "particles/units/heroes/hero_sven/sven_spell_great_cleave_gods_strength.vpcf" )
				local enemies = caster:FindEnemyUnitsInCone(caster:GetForwardVector(), caster:GetAbsOrigin(), 330, caster:GetAttackRange()*3, {})
				for _,enemy in pairs(enemies) do
					if enemy ~= target then
						local ability = caster:FindAbilityByName("ursa_fury_swipes_bh")
						enemy:AddNewModifier(caster, ability, "modifier_ursa_fury_swipes_bh", {duration = ability:GetTalentSpecialValueFor("duration")}):IncrementStackCount()
					end
				end
			end

			if caster:HasTalent("special_bonus_unique_ursa_overpower_2") then
				target:Paralyze(ability, caster, caster:FindTalentValue("special_bonus_unique_ursa_overpower_2"))
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