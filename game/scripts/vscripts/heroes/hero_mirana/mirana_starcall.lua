mirana_starcall = class({})
LinkLuaModifier("modifier_mirana_starcall", "heroes/hero_mirana/mirana_starcall", LUA_MODIFIER_MOTION_NONE)

function mirana_starcall:IsStealable()
    return true
end

function mirana_starcall:IsHiddenWhenStolen()
    return false
end

function mirana_starcall:GetIntrinsicModifierName()
    return "modifier_mirana_starcall"
end

function mirana_starcall:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_mirana_starcall_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function mirana_starcall:OnTalentLearned()
	if self:GetCaster():HasTalent("special_bonus_unique_mirana_starcall_1") then
		self:ToggleAutoCast()
	elseif self:GetAutoCastState() then
		self:ToggleAutoCast()
	end
end

function mirana_starcall:OnSpellStart()
    local caster = self:GetCaster()
    local damage = self:GetTalentSpecialValueFor("damage")
    local agi_damage = self:GetTalentSpecialValueFor("agi_damage")/100

    EmitSoundOn("Ability.Starfall", caster)

    damage = damage + caster:GetAgility() * agi_damage
	local radius = self:GetTalentSpecialValueFor("radius")
	self:StarFall( radius, damage, 0 )
	local damage2 = damage * 0.75
	self:StarFall( radius, damage2, self:GetTalentSpecialValueFor("wave_delay") )
	if caster:HasTalent("special_bonus_unique_mirana_starcall_2") then
		local damage3 = damage * caster:FindTalentValue("special_bonus_unique_mirana_starcall_2", "damage")
		self:StarFall( radius, damage3, self:GetSpecialValueFor("wave_delay") )
	end
end

function mirana_starcall:StarFall( radius, damage, delay)
	local caster = self:GetCaster()
	 Timers:CreateTimer(delay or 0, function()
        local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
        for _,enemy in pairs(enemies) do
            ParticleManager:FireParticle("particles/units/heroes/hero_mirana/mirana_loadout.vpcf", PATTACH_POINT_FOLLOW, enemy, {[0]=enemy:GetAbsOrigin()})
            Timers:CreateTimer(0.57, function() --particle delay
                EmitSoundOn("Ability.StarfallImpact", enemy)
                if not enemy:TriggerSpellAbsorb(self) then self:DealDamage(caster, enemy, damage, {}, 0) end
            end)
        end
    end)
end

modifier_mirana_starcall = class({})
function modifier_mirana_starcall:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(0.15)
    end
end

function modifier_mirana_starcall:OnIntervalThink()
    if self:GetParent():HasTalent("special_bonus_unique_mirana_starcall_1") and self:GetParent():IsAlive() and self:GetAbility():GetAutoCastState() then
		local caster = self:GetCaster()
		local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius") )
		if #enemies > 0 then
			self:GetAbility():OnSpellStart()
			self:StartIntervalThink(self:GetParent():FindTalentValue("special_bonus_unique_mirana_starcall_1"))
		else
			self:StartIntervalThink(0.35)
		end
    end
end

function modifier_mirana_starcall:IsHidden()
    return true
end