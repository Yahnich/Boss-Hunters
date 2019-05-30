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

function modifier_spectre_desolate_bh:OnRefresh()
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
		local solo = true
		for _, ally in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius) ) do
			if params.target ~= ally then
				damage = self.damage
				solo = false
				break
			end
		end
		if solo then
			params.target:EmitSound("Hero_Spectre.Desolate")
			local vDir = CalculateDirection( params.attacker, params.target )
			local hitFX = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_desolate.vpcf", PATTACH_ABSORIGIN, params.attacker)
			ParticleManager:SetParticleControl( hitFX, 0, params.target:GetAbsOrigin() )
			ParticleManager:SetParticleControlForward( hitFX, 0, vDir )
			ParticleManager:ReleaseParticleIndex( hitFX )
			if params.attacker:HasTalent("special_bonus_unique_spectre_desolate_2") then
				local cdr = params.attacker:FindTalentValue("special_bonus_unique_spectre_desolate_2") * params.attacker:GetCooldownReduction()
				for i = 0, 23 do
					local ability = params.attacker:GetAbilityByIndex( i )
					if ability and not ability:IsCooldownReady() then
						local cdRemaining = ability:GetCooldownTimeRemaining()
						ability:EndCooldown()
						ability:StartCooldown( cdRemaining + cdr )
					end
				end
			end
		end
		if params.attacker:HasTalent("special_bonus_unique_spectre_desolate_1") then
			params.target:Paralyze(self:GetAbility(), params.attacker, params.attacker:FindTalentValue("special_bonus_unique_spectre_desolate_1"))
		end
		
		print( damage, solo, self:GetAbility():DealDamage( params.attacker, params.target, damage ) )
	end
end

function modifier_spectre_desolate_bh:IsHidden()
	return true
end