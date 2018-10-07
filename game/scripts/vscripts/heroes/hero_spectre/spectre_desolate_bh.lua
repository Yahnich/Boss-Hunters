spectre_desolate_bh = class({})

function spectre_desolate_bh:GetIntrinsicModifierName()
	return "modifier_spectre_desolate_bh"
end

modifier_spectre_desolate_bh = class({})
LinkLuaModifier( "modifier_spectre_desolate_bh", "heroes/hero_spectre/spectre_desolate_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_desolate_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.solo_damage = self:GetTalentSpecialValueFor("bonus_damage_solo")
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_spectre_desolate_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_spectre_desolate_bh:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		local damage = self.solo_damage
		for _, ally in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius) ) do
			if params.target ~= ally then
				damage = self.damage
				params.target:EmitSound("Hero_Spectre.Desolate")
				break
			end
		end
		self:GetAbility():DealDamage( params.attacker, params.target, damage )
		local vDir = params.attacker:GetForwardVector() * (-1)
		local hitFX = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_desolate.vpcf", PATTACH_ABSORIGIN, params.attacker)
		ParticleManager:SetParticleControl( hitFX, 0, params.target:GetAbsOrigin() )
		ParticleManager:SetParticleControlForward( hitFX, 0, vDir )
		ParticleManager:ReleaseParticleIndex( hitFX )
	end
end