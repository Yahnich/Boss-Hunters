et_echo_stomp = class({})
LinkLuaModifier( "modifier_echo_stomp_spirit", "heroes/hero_et/et_echo_stomp.lua",LUA_MODIFIER_MOTION_NONE )

function et_echo_stomp:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_elder_spirit") or self:GetCaster():HasModifier("modifier_elder_spirit_check_out") then
		return "elder_titan_echo_stomp_spirit"
	end

	return "elder_titan_echo_stomp"
end

function et_echo_stomp:IsStealable()
	return true
end

function et_echo_stomp:IsHiddenWhenStolen()
	return false
end

function et_echo_stomp:OnAbilityPhaseStart()
   local caster = self:GetCaster()

   EmitSoundOn("Hero_ElderTitan.EchoStomp.Channel", caster)

   if not caster:HasModifier("modifier_elder_spirit") then
   		local spirits = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
		for _,spirit in pairs(spirits) do
			if spirit:HasModifier("modifier_elder_spirit") then
				spirit:AddNewModifier(caster, self, "modifier_echo_stomp_spirit", {})
				spirit:StartGesture(ACT_DOTA_CAST_ABILITY_1)
				ParticleManager:FireParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_cast_spirit_arc_pnt_ti7.vpcf", PATTACH_POINT, caster, {[0] = spirit:GetAbsOrigin()})
			end
		end

   		if caster:FindAbilityByName("et_elder_spirit") and caster:FindAbilityByName("et_elder_spirit"):IsTrained() then
   			if caster:HasModifier("modifier_elder_spirit_check") then
   				ParticleManager:FireParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_cast_combined_detail_ti7.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin()})
   				ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cast_combined.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin()})
   			else
   				ParticleManager:FireParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_cast_arc_pnt_ti7.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin()})
   			end
   		else
			ParticleManager:FireParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_cast_combined_detail_ti7.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin()})
			ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cast_combined.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin()})
   		end
   else
   		ParticleManager:FireParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_cast_spirit_arc_pnt_ti7.vpcf", PATTACH_POINT, caster, {[0] = caster:GetAbsOrigin()})
   end
   
   return true
end

function et_echo_stomp:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	EmitSoundOn("Hero_ElderTitan.EchoStomp", caster)

	local damage = self:GetSpecialValueFor("damage")

	if not caster:HasModifier("modifier_elder_spirit") then
		local spirits = caster:FindFriendlyUnitsInRadius(point, FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
		for _,spirit in pairs(spirits) do
			if spirit:HasModifier("modifier_elder_spirit") then
				spirit:RemoveModifierByName("modifier_echo_stomp_spirit")
				spirit:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

				spirit:FindAbilityByName(self:GetAbilityName()):CastSpell()

				spirit:FindAbilityByName(self:GetAbilityName()):StartCooldown(spirit:FindAbilityByName(self:GetAbilityName()):GetTrueCooldown())
			end
		end

		if caster:HasTalent("special_bonus_unique_et_echo_stomp_1") then
			damage = damage + damage*caster:FindTalentValue("special_bonus_unique_et_echo_stomp_1")/100
		end

   		if caster:FindAbilityByName("et_elder_spirit") and caster:FindAbilityByName("et_elder_spirit"):IsTrained() then
   			if caster:HasModifier("modifier_elder_spirit_check") then
   				ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf", PATTACH_POINT, caster, {[0] = point})

				local enemies = caster:FindEnemyUnitsInRadius(point, self:GetSpecialValueFor("radius"), {})
				for _,enemy in pairs(enemies) do
					self:Stun(enemy, self:GetSpecialValueFor("duration"), false)

					self:DealDamage(caster, enemy, damage/2, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
					self:DealDamage(caster, enemy, damage/2, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)

					if caster:HasTalent("special_bonus_unique_et_echo_stomp_2") then
						enemy:Taunt(self, caster, caster:FindTalentValue("special_bonus_unique_et_echo_stomp_2"))
					end
				end
   			else
   				ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf", PATTACH_POINT, caster:GetOwner(), {[0] = point})

				local enemies = caster:FindEnemyUnitsInRadius(point, self:GetSpecialValueFor("radius"), {})
				for _,enemy in pairs(enemies) do
					self:Stun(enemy, self:GetSpecialValueFor("duration"), false)

					self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)

					if caster:HasTalent("special_bonus_unique_et_echo_stomp_2") then
						enemy:Taunt(self, caster, caster:FindTalentValue("special_bonus_unique_et_echo_stomp_2"))
					end
				end
   			end
   		else
   			ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf", PATTACH_POINT, caster, {[0] = point})

			local enemies = caster:FindEnemyUnitsInRadius(point, self:GetSpecialValueFor("radius"), {})
			for _,enemy in pairs(enemies) do
				self:Stun(enemy, self:GetSpecialValueFor("duration"), false)

				self:DealDamage(caster, enemy, damage/2, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
				self:DealDamage(caster, enemy, damage/2, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)

				if caster:HasTalent("special_bonus_unique_et_echo_stomp_2") then
					enemy:Taunt(self, caster, caster:FindTalentValue("special_bonus_unique_et_echo_stomp_2"))
				end
			end
   		end
   else
   		if caster:GetOwner():HasTalent("special_bonus_unique_et_echo_stomp_1") then
			damage = damage + damage*caster:GetOwner():FindTalentValue("special_bonus_unique_et_echo_stomp_1")/100
		end

   		ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_magical.vpcf", PATTACH_POINT, caster, {[0] = point})

		local enemies = caster:FindEnemyUnitsInRadius(point, self:GetSpecialValueFor("radius"), {})
		for _,enemy in pairs(enemies) do
			self:Stun(enemy, self:GetSpecialValueFor("duration"), false)

			self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)

			if caster:GetOwner():HasTalent("special_bonus_unique_et_echo_stomp_2") then
				enemy:Taunt(self, caster:GetOwner(), caster:GetOwner():FindTalentValue("special_bonus_unique_et_echo_stomp_2"))
			end
		end
   end
end

modifier_echo_stomp_spirit = class({})
function modifier_echo_stomp_spirit:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_ROOTED] = true
					}
	return state
end

function modifier_echo_stomp_spirit:IsHidden()
	return true
end