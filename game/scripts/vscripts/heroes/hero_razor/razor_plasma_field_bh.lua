razor_plasma_field_bh = class({})

function razor_plasma_field_bh:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Ability.PlasmaField", caster)
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	local duration = self:GetSpecialValueFor("radius")/self:GetSpecialValueFor("speed")
	caster:AddNewModifier(caster, self, "modifier_razor_plasma_field_bh", {Duration = duration*2})
end

modifier_razor_plasma_field_attackspeed = class({})
LinkLuaModifier("modifier_razor_plasma_field_attackspeed", "heroes/hero_razor/razor_plasma_field_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_razor_plasma_field_attackspeed:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("attack_speed")
	self.movespeed = self:GetCaster():FindTalentValue("special_bonus_unique_razor_plasma_field_bh_1", "value2")
end

function modifier_razor_plasma_field_attackspeed:OnRefresh()
	self.attackspeed = self:GetSpecialValueFor("attack_speed")
	self.movespeed = self:GetCaster():FindTalentValue("special_bonus_unique_razor_plasma_field_bh_1", "value2")
end

function modifier_razor_plasma_field_attackspeed:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_razor_plasma_field_attackspeed:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_razor_plasma_field_attackspeed:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

modifier_razor_plasma_field_bh = class({})
LinkLuaModifier("modifier_razor_plasma_field_bh", "heroes/hero_razor/razor_plasma_field_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_razor_plasma_field_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local currentRadius = 0
		local maxRadius = self:GetSpecialValueFor("radius")
		local speed = self:GetSpecialValueFor("speed")
		local damage = self:GetSpecialValueFor("damage")
		local talent2 = caster:HasTalent("special_bonus_unique_razor_plasma_field_bh_2")
		
		
		local attackspeed = caster:AddNewModifier(caster, ability, "modifier_razor_plasma_field_attackspeed", {Duration = self:GetSpecialValueFor("duration")})
		local duration_increase = self:GetSpecialValueFor("duration_increase")
		local minion_increase = self:GetSpecialValueFor("duration_minion")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_plasmafield.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(speed, maxRadius, 1))
		local inward = false
		local enemyHit = {}
		Timers:CreateTimer(0,
		function()
			if currentRadius < maxRadius and not self:IsNull() then
				local enemies = caster:FindEnemyUnitsInRing(caster:GetAbsOrigin(), currentRadius+200, currentRadius )
				for _, enemy in pairs(enemies) do
					if not enemyHit[enemy] then
						if not enemy:TriggerSpellAbsorb( self ) then
							ability:DealDamage( caster, enemy, damage )
							if enemy:IsMinion() then
								attackspeed:SetDuration( attackspeed:GetRemainingTime() + minion_increase, true )
							else
								attackspeed:SetDuration( attackspeed:GetRemainingTime() + duration_increase, true )
							end
							if talent2 then
								enemy:Paralyze( ability, caster, attackspeed:GetRemainingTime() )
							end
						end
						enemyHit[enemy] = true
					end
				end
				currentRadius = currentRadius + maxRadius*FrameTime()
				return 0.03
			else
				ParticleManager:SetParticleControl(nfx, 1, Vector(-speed, maxRadius, 1))
			end
		end)
		self:AttachEffect(nfx)
	end 
end

function modifier_razor_plasma_field_bh:IsPurgeException()
	return false
end

function modifier_razor_plasma_field_bh:IsPurgable()
	return false
end

function modifier_razor_plasma_field_bh:IsHidden()
	return true
end

function modifier_razor_plasma_field_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end