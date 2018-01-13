brd_cleave_strike = class({})
LinkLuaModifier( "modifier_cleave_strike", "heroes/hero_brd/brd_cleave_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function brd_cleave_strike:PiercesDisableResistance()
    return true
end

function brd_cleave_strike:GetIntrinsicModifierName()
	return "modifier_cleave_strike"
end

modifier_cleave_strike = class({})

function modifier_cleave_strike:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_cleave_strike:OnTakeDamage(params)
	if IsServer() then
		local armorDamage = self:GetCaster():GetPhysicalArmorValue() + self:GetCaster():GetPhysicalArmorValue() * self:GetSpecialValueFor("armor_to_damage")/100

		if params.unit == self:GetCaster() and self:GetAbility():IsCooldownReady() and RollPercentage(self:GetSpecialValueFor("chance")) then
			EmitSoundOn("Hero_Axe.CounterHelix_Blood_Chaser", self:GetCaster())

			local nfx = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt( nfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
			ParticleManager:ReleaseParticleIndex(nfx)

			self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)

			params.attacker:Taunt(self:GetAbility(), self:GetCaster(), self:GetSpecialValueFor("duration"))


			local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
			for _,enemy in pairs(enemies) do
				self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetCaster():GetAttackDamage()+ armorDamage, {}, 0)
			end

			self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
		end

		if self:GetCaster():HasTalent("special_bonus_unique_brd_cleave_strike_2") then
			if params.attacker == self:GetCaster() and self:GetAbility():IsCooldownReady() and RollPercentage(self:GetSpecialValueFor("chance")) then
				EmitSoundOn("Hero_Axe.CounterHelix_Blood_Chaser", self:GetCaster())

				local nfx = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
				ParticleManager:SetParticleControlEnt( nfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
				ParticleManager:ReleaseParticleIndex(nfx)

				self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)

				local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
				for _,enemy in pairs(enemies) do
					self:GetCaster():PerformAttack(enemy, true, true, true, false, false, false, true)
					self:GetAbility():DealDamage(self:GetCaster(), enemy, armorDamage, {}, 0)
				end

				self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
			end
		end
	end
end

function modifier_cleave_strike:IsHidden()
	return true
end
