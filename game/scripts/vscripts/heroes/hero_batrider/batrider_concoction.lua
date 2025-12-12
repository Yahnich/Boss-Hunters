batrider_concoction = class({})
LinkLuaModifier("modifier_batrider_concoction", "heroes/hero_batrider/batrider_concoction", LUA_MODIFIER_MOTION_NONE)

function batrider_concoction:IsStealable()
    return false
end

function batrider_concoction:IsHiddenWhenStolen()
    return false
end

function batrider_concoction:GetIntrinsicModifierName()
	return "modifier_batrider_concoction"
end

modifier_batrider_concoction = class({})
function modifier_batrider_concoction:OnCreated(table)
	if IsServer() then
		self.damage = self:GetSpecialValueFor("base_damage") + self:GetSpecialValueFor("damage_per_lvl") * self:GetCaster():GetLevel()

		self:StartIntervalThink(1)
	end
end

function modifier_batrider_concoction:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetSpecialValueFor("base_damage") + self:GetSpecialValueFor("damage_per_lvl") * self:GetCaster():GetLevel()
	end
end

function modifier_batrider_concoction:OnIntervalThink()
	if IsServer() then
		self.damage = self:GetSpecialValueFor("base_damage") + self:GetSpecialValueFor("damage_per_lvl") * self:GetCaster():GetLevel()
	end
end

function modifier_batrider_concoction:DeclareFunctions()
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_batrider_concoction:OnTakeDamage(params)
    if IsServer() then
    	local caster = self:GetCaster()
    	local unit = params.unit
    	local attacker = params.attacker

        if unit ~= attacker and attacker == caster then
        	local ability = self:GetAbility()

        	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf", PATTACH_POINT, caster)
        				ParticleManager:SetParticleControlEnt(nfx, 0, unit, PATTACH_POINT, "attach_hitloc", unit:GetAbsOrigin(), true)
        				ParticleManager:ReleaseParticleIndex(nfx)

        	ability:DealDamage(caster, unit, self.damage, {damage_flags = DOTA_DAMAGE_FLAG_HPLOSS}, OVERHEAD_ALERT_INCOMING_DAMAGE )
        end
    end
end

function modifier_batrider_concoction:IsHidden()
	return true
end
