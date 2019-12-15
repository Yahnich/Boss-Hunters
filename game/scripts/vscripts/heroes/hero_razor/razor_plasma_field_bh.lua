razor_plasma_field_bh = class({})
LinkLuaModifier("modifier_razor_plasma_field_bh", "heroes/hero_razor/razor_plasma_field_bh", LUA_MODIFIER_MOTION_NONE)

function razor_plasma_field_bh:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Ability.PlasmaField", caster)
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	local duration = self:GetTalentSpecialValueFor("radius")/self:GetTalentSpecialValueFor("speed")
	caster:AddNewModifier(caster, self, "modifier_razor_plasma_field_bh", {Duration = duration*2})
end

modifier_razor_plasma_field_bh = class({})
function modifier_razor_plasma_field_bh:OnCreated(table)
	if self:GetCaster():HasTalent("special_bonus_unique_razor_plasma_field_bh_1") then
		self.movespeed = self:GetCaster():FindTalentValue("special_bonus_unique_razor_plasma_field_bh_1")
	end
	if IsServer() then
		local caster = self:GetCaster()
		local currentRadius = 0
		local maxRadius = self:GetTalentSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_plasmafield.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(maxRadius, self:GetTalentSpecialValueFor("speed"), 1))
		local spellBlockEnemies = {}
		Timers:CreateTimer(0,function()
			if currentRadius < maxRadius and not self:IsNull() then
				local enemies = caster:FindEnemyUnitsInRing(caster:GetAbsOrigin(), currentRadius, math.max(0, currentRadius-200), {})
				for _, enemy in pairs(enemies) do
					if not enemy:TriggerSpellAbsorb( self ) then
						if caster:HasTalent("special_bonus_unique_razor_plasma_field_bh_2") then
							enemy:Paralyze( self:GetAbility(), caster, 1)
						end
						self:GetAbility():DealDamage( caster, enemy, self:GetTalentSpecialValueFor("damage_max")*FrameTime(), {}, 0 )
					else
						spellBlockEnemies[enemy] = true
					end
				end
				currentRadius = currentRadius + maxRadius*FrameTime()
				return 0.03
			else
				return nil
			end
		end)

		local duration = maxRadius/self:GetTalentSpecialValueFor("speed")
		Timers:CreateTimer(duration, function()
			ParticleManager:SetParticleControl(nfx, 1, Vector(maxRadius, 1, 1))
			Timers:CreateTimer(0,function()
				if currentRadius > maxRadius*FrameTime() then
					local enemies
					if currentRadius < 200 then
						enemies = caster:FindEnemyUnitsInRing(caster:GetAbsOrigin(), currentRadius, 0, {})
					else
						enemies = caster:FindEnemyUnitsInRing(caster:GetAbsOrigin(), currentRadius, currentRadius-200, {})
					end
					for _,enemy in pairs(enemies) do
						if not spellBlockEnemies[enemy] and not enemy:TriggerSpellAbsorb( self ) then
							self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage_max")*FrameTime(), {}, 0)
						end
					end
					currentRadius = currentRadius - maxRadius*FrameTime()
					return 0.03
				else
					return nil
				end
			end)
		end)
		self:AttachEffect(nfx)
	end 
end

function modifier_razor_plasma_field_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_razor_plasma_field_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
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