spectre_lonely_death = class({})

function spectre_lonely_death:GetIntrinsicModifierName()
	return "modifier_spectre_lonely_death"
end

modifier_spectre_lonely_death = class({})
LinkLuaModifier( "modifier_spectre_lonely_death", "heroes/hero_spectre/spectre_lonely_death", LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_lonely_death:OnCreated()
	self:OnRefresh()
end

function modifier_spectre_lonely_death:OnRefresh()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.solo_multiplier = self:GetSpecialValueFor("solo_multiplier")
	self.radius = self:GetSpecialValueFor("radius")
	
	self.shadow_path_solo = self:GetSpecialValueFor("shadow_path_solo") == 1
	self.paralyze_duration = self:GetSpecialValueFor("paralyze_duration")
	
	print( self.solo_multiplier, self.damage )
end

function modifier_spectre_lonely_death:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE}
end

function modifier_spectre_lonely_death:GetModifierProcAttack_BonusDamage_Pure(params)
	if params.attacker == self:GetParent() then
		local damage = self.damage
		local solo = true
		if not ( self.shadow_path_solo and params.attacker:HasModifier("modifier_spectre_dimensional_interjection_shadow_path") ) then
			for _, ally in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius) ) do
				if params.target ~= ally then
					solo = false
					break
				end
			end
		end
		if solo then
			damage = damage * self.solo_multiplier
			params.target:EmitSound("Hero_Spectre.Desolate")
			local vDir = CalculateDirection( params.target, params.attacker )
			local hitFX = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_desolate.vpcf", PATTACH_ABSORIGIN, params.target)
			ParticleManager:SetParticleControl( hitFX, 0, params.attacker:GetAbsOrigin() + params.attacker:GetForwardVector() * 50 )
			ParticleManager:SetParticleControlForward( hitFX, 0, vDir )
			ParticleManager:ReleaseParticleIndex( hitFX )
		end
		if self.paralyze_duration > 0 then
			params.target:Paralyze(self:GetAbility(), params.attacker, self.paralyze_duration)
		end
		return damage
	end
end

function modifier_spectre_lonely_death:IsHidden()
	return true
end