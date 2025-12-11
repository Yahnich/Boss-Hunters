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
		ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_hand_of_god.vpcf", PATTACH_POINT, friend, {[0]=friend:GetAbsOrigin(),[1]=Vector(radius,radius,radius)})

		friend:HealEvent(friend:GetMaxHealth(), self, caster)
		friend:AddNewModifier(caster, self, "modifier_chen_god_hand", {Duration = self:GetSpecialValueFor("duration")})

		if caster:HasTalent("special_bonus_unique_chen_god_hand_2") then
			EmitSoundOn("Hero_Omniknight.Purification", friend)
			
			local radius = caster:FindTalentValue("special_bonus_unique_chen_god_hand_2", "radius")

			ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT, friend, {[0]=friend:GetAbsOrigin(),[1]=Vector(radius,radius,radius)})

			local enemies = caster:FindEnemyUnitsInRadius(friend:GetAbsOrigin(), radius, {})
			for _,enemy in pairs(enemies) do
				if not enemy:TriggerSpellAbsorb( self ) then
					local damage = caster:GetIntellect( false)*caster:FindTalentValue("special_bonus_unique_chen_god_hand_2")/100
					self:DealDamage(caster, enemy, damage, {damage_type=DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
				end
			end
		end
	end
end

modifier_chen_god_hand = class({})
function modifier_chen_god_hand:OnCreated()
	self:OnRefresh()
end

function modifier_chen_god_hand:OnRefresh()
	self.cdr = self:GetTalentSpecialValueFor("cdr")
	self.dmg = self:GetTalentSpecialValueFor("dmg")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_chen_god_hand_1")
end

function modifier_chen_god_hand:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE }
end

function modifier_chen_god_hand:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_chen_god_hand:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_chen_god_hand:GetEffectName()
	if self.talent1 then
		return "particles/items_fx/black_king_bar_avatar.vpcf"
	end
end

function modifier_chen_god_hand:GetStatusEffectName()
	if self.talent1 then
		return "particles/status_fx/status_effect_avatar.vpcf"
	end
end

function modifier_chen_god_hand:StatusEffectPriority()
	if self.talent1 then
		return 10
	end
end