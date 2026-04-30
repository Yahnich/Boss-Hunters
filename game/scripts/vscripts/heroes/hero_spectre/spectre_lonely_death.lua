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
	self.solo_damage = self:GetSpecialValueFor("bonus_damage_solo")
	self.radius = self:GetSpecialValueFor("radius")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_spectre_desolate_2")
end

function modifier_spectre_lonely_death:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE}
end

function modifier_spectre_lonely_death:GetModifierProcAttack_BonusDamage_Pure(params)
	if params.attacker == self:GetParent() then
		local damage = self.solo_damage
		local solo = true
		print( self.talent2, params.target:HasModifier("modifier_spectre_spectral_dagger_bh") )
		if not ( self.talent2 and params.target:HasModifier("modifier_spectre_spectral_dagger_bh") ) then
			for _, ally in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius) ) do
				if params.target ~= ally then
					damage = self.damage
					solo = false
					break
				end
			end
		end
		if solo then
			params.target:EmitSound("Hero_Spectre.Desolate")
			local vDir = CalculateDirection( params.target, params.attacker )
			local hitFX = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_desolate.vpcf", PATTACH_ABSORIGIN, params.target)
			ParticleManager:SetParticleControl( hitFX, 0, params.attacker:GetAbsOrigin() + params.attacker:GetForwardVector() * 50 )
			ParticleManager:SetParticleControlForward( hitFX, 0, vDir )
			ParticleManager:ReleaseParticleIndex( hitFX )
		end
		if params.attacker:HasTalent("special_bonus_unique_spectre_desolate_1") then
			params.target:Paralyze(self:GetAbility(), params.attacker, params.attacker:FindTalentValue("special_bonus_unique_spectre_desolate_1"))
		end
		return damage -- self:GetAbility():DealDamage( params.attacker, params.target, damage )
	end
end

function modifier_spectre_lonely_death:IsHidden()
	return true
end