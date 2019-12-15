ss_static_remnant = class({})
LinkLuaModifier("modifier_ss_static_remnant", "heroes/hero_storm_spirit/ss_static_remnant", LUA_MODIFIER_MOTION_NONE)

function ss_static_remnant:IsStealable()
    return true
end

function ss_static_remnant:IsHiddenWhenStolen()
    return false
end

function ss_static_remnant:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_ss_static_remnant_1") then
    	return DOTA_ABILITY_BEHAVIOR_POINT
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function ss_static_remnant:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("search_radius")
end

function ss_static_remnant:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	if caster:HasTalent("special_bonus_unique_ss_static_remnant_1") then
		point = self:GetCursorPosition()
	end

	self:CreateRemnant(point)
end

function ss_static_remnant:CreateRemnant(vLocation)
	local caster = self:GetCaster()

	EmitSoundOn("Hero_StormSpirit.StaticRemnantPlant", caster)

	local duration = self:GetTalentSpecialValueFor("duration")

	local pos = GetGroundPosition(vLocation or caster:GetAbsOrigin(), caster)

	CreateModifierThinker(caster, self, "modifier_ss_static_remnant", {Duration = duration}, pos, caster:GetTeam(), false)
end

modifier_ss_static_remnant = class({})
function modifier_ss_static_remnant:OnCreated(table)
	if IsServer() then
		self.caster = self:GetCaster()
		self.point = self:GetParent():GetAbsOrigin()

		self.damage = self:GetTalentSpecialValueFor("damage")
		self.damage_radius = self:GetTalentSpecialValueFor("damage_radius")
		self.search_radius = self:GetTalentSpecialValueFor("search_radius")

		--sequence numbers, look them up in the model viewer for dota 2
		--local animationSet1 = math.random(46, 52) 
		local animationSet2 = math.random(37, 52)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf", PATTACH_POINT, self.caster)
					ParticleManager:SetParticleControl(nfx, 0, self.point)
					ParticleManager:SetParticleControlEnt(nfx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.point, true)
					ParticleManager:SetParticleControl(nfx, 2, Vector(animationSet2, 1, 0))
					--ParticleManager:SetParticleControl(nfx, 11, self.point)

		self:AttachEffect(nfx)

		self.current = 0

		local delay = self:GetTalentSpecialValueFor("delay")

		if self.caster:HasTalent("special_bonus_unique_ss_static_remnant_1") then
			delay = 0.5
		end

		self:StartIntervalThink(delay)
	end
end

function modifier_ss_static_remnant:OnIntervalThink()

	if self.caster:HasTalent("special_bonus_unique_ss_static_remnant_2") then
		if self.current >= 1 + 0.1 then
			local allies = self.caster:FindFriendlyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.damage_radius)
			for _,ally in pairs(allies) do
				ally:RestoreMana(self.caster:FindTalentValue("special_bonus_unique_ss_static_remnant_2"))
			end

			self.current = 0
		else
			self.current = self.current + 0.1
		end
	end

	local enemies = self.caster:FindEnemyUnitsInRadius(self.point, self.search_radius)
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_StormSpirit.StaticRemnantExplode", enemy)
		self:Destroy()
		break
	end
	self:StartIntervalThink(0.1)
end

function modifier_ss_static_remnant:OnRemoved()
	if IsServer() then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.damage_radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				self:GetAbility():DealDamage(self:GetCaster(), enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end
	end
end
