ta_psi_blades = class({})
LinkLuaModifier( "modifier_ta_psi_blades", "heroes/hero_ta/ta_psi_blades.lua", LUA_MODIFIER_MOTION_NONE )

function ta_psi_blades:GetIntrinsicModifierName()
	return "modifier_ta_psi_blades"
end

function ta_psi_blades:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil then
		self.disableLoop = true
		self:GetCaster():PerformAttack(hTarget, true, true, true, true, false, false, true)
		--self:DealDamage(self:GetCaster(), hTarget, self:GetCaster():GetAttackDamage(), {}, 0)

		if self:GetCaster():HasTalent("special_bonus_unique_ta_psi_blades_2") then
			hTarget:Paralyze(self, self:GetCaster())
		end
	end
end

modifier_ta_psi_blades = ({})
function modifier_ta_psi_blades:OnCreated(table)
	self.bonusRange = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_ta_psi_blades:OnIntervalThink()
	self.bonusRange = self:GetTalentSpecialValueFor("bonus_range") + self:GetCaster():GetAttackRange() * self:GetTalentSpecialValueFor("bonus_range_pct")/100
end

function modifier_ta_psi_blades:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
    return funcs
end

function modifier_ta_psi_blades:GetModifierAttackRangeBonus()
	return self.bonusRange
end

function modifier_ta_psi_blades:OnAttackStart(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility().disableLoop = false
		end
	end
end

function modifier_ta_psi_blades:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.target:IsAlive() then
			if self:GetAbility().disableLoop then return end
			local bounces = self:GetTalentSpecialValueFor("max_units")
			self.disableLoop = false
			local enemies = params.attacker:FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), params.attacker:GetAttackRange() + self:GetTalentSpecialValueFor("radius"), {})
			for _,enemy in pairs(enemies) do
				if enemy ~= params.target and enemy:IsAlive() then
					ParticleManager:FireRopeParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_psi_blade.vpcf", PATTACH_POINT_FOLLOW, params.target, enemy, {})
					self:GetAbility():FireTrackingProjectile("", enemy, 99999, {})
					bounces = bounces - 1
					if bounces < 1 then break end
				end
			end
		end
	end
end

function modifier_ta_psi_blades:IsHidden()
	return true
end