elite_sweeping = class({})

function elite_sweeping:GetIntrinsicModifierName()
	return "modifier_elite_sweeping"
end

modifier_elite_sweeping = class(relicBaseClass)
LinkLuaModifier("modifier_elite_sweeping", "elites/elite_sweeping", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_sweeping:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.dmg_pct = self:GetSpecialValueFor("damage_pct")
end

function modifier_elite_sweeping:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_elite_sweeping:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self.radius = self:GetSpecialValueFor("radius")
		self.dmg_pct = self:GetSpecialValueFor("damage_pct") / 100
		local ability = self:GetAbility()
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius ) ) do
			if enemy ~= params.target then
				ability:DealDamage(params.attacker, enemy, params.damage * self.dmg_pct, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
			end
		end
	end
end