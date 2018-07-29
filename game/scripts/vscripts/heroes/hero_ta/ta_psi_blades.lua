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
	self.endBonusRange = 0
	self.bonus_range = self:GetTalentSpecialValueFor("bonus_range")
	self.bonus_range_pct = self:GetTalentSpecialValueFor("bonus_range_pct")
	self:StartIntervalThink(0.1)
end

function modifier_ta_psi_blades:OnIntervalThink()
	self.endBonusRange = 0
	self.endBonusRange = self:GetCaster():GetAttackRange() * self.bonus_range_pct/100
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
	return self.bonus_range + self.endBonusRange
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
			EmitSoundOn("Hero_TemplarAssassin.PsiBlade", params.target)
			if self:GetAbility().disableLoop then return end
			local bounces = self:GetTalentSpecialValueFor("max_units")
			self.disableLoop = false
			if self:GetCaster():HasTalent("special_bonus_unique_ta_psi_blades_2") then
				params.target:Paralyze(self, self:GetCaster(), 0.5)
			end
			local enemies = params.attacker:FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), params.attacker:GetAttackRange() + self:GetTalentSpecialValueFor("radius"), {})
			for _,enemy in pairs(enemies) do
				if enemy ~= params.target and enemy:IsAlive() then
					local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_psi_blade.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
					ParticleManager:SetParticleControlEnt(FX, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(FX, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					self:GetAbility():FireTrackingProjectile(nil, enemy, 99999, {})
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