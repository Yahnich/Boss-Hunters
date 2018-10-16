ursa_earthshock_bh = class({})
LinkLuaModifier("modifier_ursa_earthshock_bh_slow", "heroes/hero_ursa/ursa_earthshock_bh", LUA_MODIFIER_MOTION_NONE)

function ursa_earthshock_bh:IsStealable()
	return true
end

function ursa_earthshock_bh:IsHiddenWhenStolen()
	return false
end

function ursa_earthshock_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function ursa_earthshock_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("radius")

	EmitSoundOn("Hero_Ursa.Earthshock", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
				--ParticleManager:SetParticleControl(nfx, 1, Vector(900, 450, 225))
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, 225))
				ParticleManager:ReleaseParticleIndex(nfx)

	GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), radius, false)

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_ursa_earthshock_bh_slow", {Duration = self:GetTalentSpecialValueFor("duration")})

		if caster:HasTalent("special_bonus_unique_ursa_earthshock_bh_2") then
			for i=1,3 do
				local ability = caster:FindAbilityByName("ursa_fury_swipes_bh")
				enemy:AddNewModifier(caster, ability, "modifier_ursa_fury_swipes_bh", {duration = ability:GetTalentSpecialValueFor("duration")}):IncrementStackCount()
			end
		end

		self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end

modifier_ursa_earthshock_bh_slow = class({})
function modifier_ursa_earthshock_bh_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_ursa_earthshock_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("slow_ms")
end

function modifier_ursa_earthshock_bh_slow:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end

function modifier_ursa_earthshock_bh_slow:IsDebuff()
	return true
end