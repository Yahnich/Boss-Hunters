batrider_flamebreak_bh = class({})
LinkLuaModifier("modifier_batrider_flamebreak_bh_debuff", "heroes/hero_batrider/batrider_flamebreak_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_flamebreak_bh_pit", "heroes/hero_batrider/batrider_flamebreak_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_flamebreak_bh_pit_damage", "heroes/hero_batrider/batrider_flamebreak_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_flamebreak_bh_status_resist", "heroes/hero_batrider/batrider_flamebreak_bh", LUA_MODIFIER_MOTION_NONE)

function batrider_flamebreak_bh:IsStealable()
    return true
end

function batrider_flamebreak_bh:IsHiddenWhenStolen()
    return false
end

function batrider_flamebreak_bh:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function batrider_flamebreak_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	self:TossCocktail(point)
end

function batrider_flamebreak_bh:TossCocktail(vLocation)
	local caster = self:GetCaster()
	local point = vLocation

	local distance = CalculateDistance(point, caster:GetAbsOrigin())
	local speed = 900
	local time = distance / speed

	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_Batrider.Flamebreak", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flamebreak.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, Vector(900, 0, 0))
				ParticleManager:SetParticleControl(nfx, 3, point)
				ParticleManager:SetParticleControl(nfx, 4, point)
				ParticleManager:SetParticleControl(nfx, 5, point)

	Timers:CreateTimer(time, function()
		EmitSoundOnLocationWithCaster(point, "Hero_Batrider.Flamebreak.Impact", caster)

		ParticleManager:ClearParticle(nfx)

		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:ApplyKnockBack(point, 0.25, 0.25, 50, 100, caster, self, true)
				enemy:AddNewModifier(caster, self, "modifier_batrider_flamebreak_bh_debuff", {Duration = duration})

				if caster:HasTalent("special_bonus_unique_batrider_flamebreak_bh_2") then
					enemy:AddNewModifier(caster, self, "modifier_batrider_flamebreak_bh_status_resist", {Duration = duration})
				end
			end
		end

		if caster:HasTalent("special_bonus_unique_batrider_flamebreak_bh_1") then
			CreateModifierThinker(caster, self, "modifier_batrider_flamebreak_bh_pit", {Duration = 3}, point, caster:GetTeam(), false)
		end
	end)
end

modifier_batrider_flamebreak_bh_debuff = class({})
function modifier_batrider_flamebreak_bh_debuff:OnCreated(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage")

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_batrider_flamebreak_bh_debuff:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage")
	end
end

function modifier_batrider_flamebreak_bh_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	ParticleManager:FireParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_debuff.vpcf", PATTACH_POINT, parent, {})

	self:GetAbility():DealDamage(caster, parent, self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)

	self:StartIntervalThink(1)
end

function modifier_batrider_flamebreak_bh_debuff:IsDebuff()
	return true
end

function modifier_batrider_flamebreak_bh_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_batrider_flamebreak_bh_pit = class({})
function modifier_batrider_flamebreak_bh_pit:OnCreated(table)
    if IsServer() then
    	local parent = self:GetParent()
    	local point = parent:GetAbsOrigin()
    	self.radius = self:GetTalentSpecialValueFor("radius")
    	
    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_lsa_fire.vpcf", PATTACH_POINT, parent)
    				ParticleManager:SetParticleControl(nfx, 0, point)
    				ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, 1, 1))

    	self:AttachEffect(nfx)
    end
end

function modifier_batrider_flamebreak_bh_pit:IsAura()
    return true
end

function modifier_batrider_flamebreak_bh_pit:GetAuraDuration()
    return 0.5
end

function modifier_batrider_flamebreak_bh_pit:GetAuraRadius()
    return self.radius
end

function modifier_batrider_flamebreak_bh_pit:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_batrider_flamebreak_bh_pit:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_batrider_flamebreak_bh_pit:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_batrider_flamebreak_bh_pit:GetModifierAura()
    return "modifier_batrider_flamebreak_bh_pit_damage"
end

function modifier_batrider_flamebreak_bh_pit:IsAuraActiveOnDeath()
    return false
end

function modifier_batrider_flamebreak_bh_pit:IsHidden()
    return true
end

modifier_batrider_flamebreak_bh_pit_damage = class({})
function modifier_batrider_flamebreak_bh_pit_damage:OnCreated(table)
	if IsServer() then
    	self.damage = self:GetTalentSpecialValueFor("damage") * 0.5
    	self:StartIntervalThink(0.5)
    end
end

function modifier_batrider_flamebreak_bh_pit_damage:OnIntervalThink()
	ParticleManager:FireParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_debuff.vpcf", PATTACH_POINT, self:GetParent(), {})
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_DAMAGE)
end

function modifier_batrider_flamebreak_bh_pit_damage:IsHidden()
    return true
end

modifier_batrider_flamebreak_bh_status_resist = class({})
function modifier_batrider_flamebreak_bh_status_resist:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function modifier_batrider_flamebreak_bh_status_resist:GetModifierStatusResistanceStacking()
    return -50
end

function modifier_batrider_flamebreak_bh_status_resist:IsHidden()
    return true
end