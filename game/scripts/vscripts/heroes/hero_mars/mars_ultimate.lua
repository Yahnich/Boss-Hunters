mars_ultimate = class({})

LinkLuaModifier("modifier_mars_ultimate", "heroes/hero_mars/mars_ultimate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mars_ultimate_caster", "heroes/hero_mars/mars_ultimate.lua", LUA_MODIFIER_MOTION_NONE)

function mars_ultimate:IsStealable()
	return true
end

function mars_ultimate:IsHiddenWhenStolen()
	return false
end

function mars_ultimate:GetAOERadius()	
	return self:GetSpecialValueFor("radius")		
end

function mars_ultimate:OnSpellStart()			
	-- Ability properties
	local target_point = self:GetCursorPosition()
	local caster = self:GetCaster()		

	local delay = self:GetSpecialValueFor("delay")
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOnLocationWithCaster(target_point, "Hero_Mars.ArenaOfBlood.Start", caster)

	local nfx = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", PATTACH_POINT, self:GetCaster())
				ParticleManager:SetParticleControl(nfx, 0, target_point)
				ParticleManager:SetParticleControl(nfx, 3, Vector(1, 1, 1))
				ParticleManager:ReleaseParticleIndex(nfx)

	-- Wait for formation to finish setting up
	Timers:CreateTimer(delay, function()
		-- Apply thinker modifier on target location
		EmitSoundOnLocationWithCaster(target_point, "Hero_Mars.ArenaOfBlood", caster)
		CreateModifierThinker(caster, self, "modifier_mars_ultimate", {duration = duration}, target_point, caster:GetTeamNumber(), true)
	end)
end

---------------------------------------------------
--				Arena modifier
---------------------------------------------------
modifier_mars_ultimate = class({})

function modifier_mars_ultimate:IsHidden() return true end

function modifier_mars_ultimate:OnCreated(keys)
	if IsServer() then
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.column_absorb = self:GetAbility():GetSpecialValueFor("column_absorb")/100
		self.column_absorb_max = self:GetAbility():GetSpecialValueFor("column_absorb_max")
		self.damage = self:GetAbility():GetSpecialValueFor("column_absorb_max")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_pillar.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		self:AttachEffect(nfx)

		self.PSO = SpawnEntityFromTableSynchronous('point_simple_obstruction', {origin = GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetCaster())}) 

		self:StartIntervalThink(0.1)
	end
end

function modifier_mars_ultimate:OnRemoved()
	if IsServer() then
		UTIL_Remove(self.PSO)
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Mars.ArenaOfBlood.End", self:GetCaster())
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Mars.ArenaOfBlood.Crumble", self:GetCaster())
	end
end

function modifier_mars_ultimate:OnIntervalThink()
	if self.column_absorb_max < 1 then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_shockwave.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(1, 1, 1))
					ParticleManager:ReleaseParticleIndex(nfx)

		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
		for _,enemy in pairs(enemies) do
			self:GetAbility():DealDamage(self:GetCaster(), enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end

		self.column_absorb_max = self:GetAbility():GetSpecialValueFor("column_absorb_max")
	end
end

function modifier_mars_ultimate:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_mars_ultimate:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = params.unit
		local damage = params.damage

		if caster ~= unit and unit:GetTeam() ~= caster:GetTeam() then
			if CalculateDistance(unit, caster) <= self.radius then
				self.column_absorb_max = self.column_absorb_max - damage * self.column_absorb
				print("Absorb: " .. self.column_absorb_max)
			end
		end
	end
end

function modifier_mars_ultimate:IsAura()
    return true
end

function modifier_mars_ultimate:GetAuraDuration()
    return 0.5
end

function modifier_mars_ultimate:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_mars_ultimate:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_mars_ultimate:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mars_ultimate:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_mars_ultimate:GetAuraEntityReject(hEntity)
    if hEntity ~= self:GetCaster() and not self:GetCaster():HasTalent("special_bonus_unique_mars_ultimate_2") then
    	return false
    end
end

function modifier_mars_ultimate:GetModifierAura()
    return "modifier_mars_ultimate_caster"
end

function modifier_mars_ultimate:IsAuraActiveOnDeath()
    return false
end

--Caster buff
modifier_mars_ultimate_caster = class({})

function modifier_mars_ultimate_caster:IsDebuff() return false end

function modifier_mars_ultimate_caster:OnCreated(table)
	if IsServer() then
		self.heal = self:GetSpecialValueFor("heal")
		self.heal_boss = self:GetSpecialValueFor("heal_boss")/100 * self:GetCaster():GetMaxHealth()
		self.radius = self:GetSpecialValueFor("radius")
	end
end

function modifier_mars_ultimate_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function modifier_mars_ultimate_caster:GetActivityTranslationModifiers()
	return "arena_of_blood"
end

function modifier_mars_ultimate_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function modifier_mars_ultimate_caster:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = params.unit

		if caster ~= unit and unit:GetTeam() ~= caster:GetTeam() then
			if CalculateDistance(unit, caster) <= self.radius then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_fg_heal.vpcf", PATTACH_POINT, caster)
							ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
							ParticleManager:ReleaseParticleIndex(nfx)

				if unit:IsBoss() then
					caster:HealEvent(self.heal_boss, self:GetAbility(), caster, false)
					print("Heal: " .. self.heal_boss)
				else
					caster:HealEvent(self.heal, self:GetAbility(), caster, false)
					print("Heal: " .. self.heal)
				end
			end
		end
	end
end