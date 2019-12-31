boss_leshrac_lightning_storm = class({})

function boss_leshrac_lightning_storm:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("hit_radius") )
	return true
end

function boss_leshrac_lightning_storm:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local damage = self:GetSpecialValueFor("damage")
	local delay = self:GetCastPoint()
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("hit_radius")
	local searchRadius = self:GetSpecialValueFor("search_radius")
	local bounces = self:GetSpecialValueFor("bounces")
	local splits = self:GetSpecialValueFor("splits")
	
	local lightnings = {}
	table.insert( lightnings, position )

	Timers:CreateTimer( function()
		local newLightnings = {}
		local preventDoubles = {}
		for i = #lightnings, 1, -1 do
			local lightningPos = lightnings[i]
			local hitPos = lightningPos
			for id, enemy in ipairs( caster:FindEnemyUnitsInRadius( lightningPos, radius ) ) do
				if not enemy:TriggerSpellAbsorb( self ) then
					hit = true
					damageType = DAMAGE_TYPE_MAGICAL
					if enemy:GetMagicalArmorValue( ) > enemy:GetPhysicalArmorReduction()/100 then
						damageType = DAMAGE_TYPE_PHYSICAL
					end
					self:DealDamage( caster, enemy, damage, {damage_type = damageType} )
					enemy:AddNewModifier( caster, self, "modifier_boss_leshrac_lightning_storm", {duration = duration} )
					hitPos = enemy:GetAbsOrigin()
					for i = 1, splits do
						for _, newTarget in ipairs( caster:FindEnemyUnitsInRadius( lightningPos, searchRadius ) ) do
							if newTarget ~= enemy and not preventDoubles[newTarget] then
								preventDoubles[newTarget] = true
								table.insert( newLightnings, newTarget:GetAbsOrigin() )
								break
							end
						end
					end
				end
				break
			end
			ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, caster, {[0] = hitPos + Vector(0,0,2000),
																																					[1] = hitPos})
			EmitSoundOnLocationWithCaster( hitPos, "Hero_Leshrac.Split_Earth", caster )
		end
		lightnings = newLightnings
		bounces = bounces - 1
		if bounces > 0 then
			for _, lightningPos in ipairs( lightnings ) do
				ParticleManager:FireWarningParticle( lightningPos, radius )
			end
			return delay
		end
	end)
end


modifier_boss_leshrac_lightning_storm = class({})
LinkLuaModifier("modifier_boss_leshrac_lightning_storm", "bosses/boss_leshrac/boss_leshrac_lightning_storm", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_leshrac_lightning_storm:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("slow")
end

function modifier_boss_leshrac_lightning_storm:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("slow")
end

function modifier_boss_leshrac_lightning_storm:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_leshrac_lightning_storm:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_boss_leshrac_lightning_storm:GetEffectName()
	return "particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf"
end
