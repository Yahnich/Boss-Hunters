chen_god_hand = class({})
LinkLuaModifier( "modifier_chen_god_hand", "heroes/hero_chen/chen_god_hand.lua" ,LUA_MODIFIER_MOTION_NONE )

function chen_god_hand:IsStealable()
	return true
end

function chen_god_hand:IsHiddenWhenStolen()
	return false
end

function chen_god_hand:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	local friends = caster:FindFriendlyUnitsInRadius(point, FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
	for _,friend in pairs(friends) do
		EmitSoundOn("Hero_Chen.HandOfGodHealHero", friend)

		friend:RemoveModifierByName("modifier_chen_god_hand")
		ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_loadout.vpcf", PATTACH_POINT, friend, {[0]=point,[1]=Vector(radius,radius,radius)})

		friend:HealEvent(friend:GetMaxHealth(), self, caster)
		friend:AddNewModifier(caster, self, "modifier_chen_god_hand", {Duration = self:GetSpecialValueFor("duration")})

		if caster:HasTalent("special_bonus_unique_chen_god_hand_1") then
			caster:AddNewModifier(caster, self, "modifier_magicimmune", {Duration = self:GetSpecialValueFor("duration")})
		end

		if caster:HasTalent("special_bonus_unique_chen_god_hand_2") then
			EmitSoundOn("Hero_Omniknight.Purification", friend)
			
			local radius = caster:FindTalentValue("special_bonus_unique_chen_god_hand_2", "radius")

			ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT, friend, {[0]=friend:GetAbsOrigin(),[1]=Vector(radius,radius,radius)})

			local enemies = caster:FindEnemyUnitsInRadius(friend:GetAbsOrigin(), radius, {})
			for _,enemy in pairs(enemies) do
				local damage = caster:GetIntellect()*caster:FindTalentValue("special_bonus_unique_chen_god_hand_2")/100
				self:DealDamage(caster, enemy, damage, {damage_type=DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_DAMAGE)
			end
		end
	end
end

modifier_chen_god_hand = class({})
function modifier_chen_god_hand:CheckState()
	local state = { [MODIFIER_STATE_INVULNERABLE] = true}
	return state
end