kunkka_water_spout = class({})

function kunkka_water_spout:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function kunkka_water_spout:OnSpellStart()
    local point = self:GetCursorPosition()
    local caster = self:GetCaster()

    local radius = self:GetSpecialValueFor("radius")
    local extra_torrents = self:GetSpecialValueFor("extra_torrents")
    local extra_torrent_delay = self:GetSpecialValueFor("extra_torrent_delay")
	
    self:CreateTorrent( point, radius )
    if extra_torrents > 0 then
		Timers:CreateTimer(extra_torrent_delay, function()
			local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() )
			local target
			for _, enemy in ipairs( enemies ) do
				if not enemy:HasModifier("modifier_kunkka_water_spout_slow") then
					target = enemy
					break
				end
			end
			extra_torrents = extra_torrents - 1
			if target then
				self:CreateTorrent( target:GetAbsOrigin() + ActualRandomVector(radius), radius )
			else
				self:CreateTorrent( caster:GetAbsOrigin() + ActualRandomVector( self:GetTrueCastRange() ), radius )
			end
			if extra_torrents > 0 then
				return extra_torrent_delay
			end
		end)
    end
end

function kunkka_water_spout:CreateTorrent( position, radius )
    local caster = self:GetCaster()
	EmitSoundOnLocationWithCaster(position, "Ability.pre.Torrent", caster)

    local bubbles = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(bubbles, 0, position)
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	local slow = self:GetSpecialValueFor("slow_duration") + stunDuration

    local bonus_armor_duration = self:GetSpecialValueFor("bonus_armor_duration")
    AddFOWViewer( caster:GetTeamNumber(), position, radius, 3.13, false)
	
	local pull_radius = radius * self:GetSpecialValueFor("pull_radius")
	local delay = self:GetSpecialValueFor("delay")
	
	local spellAbsorbedUnits = {}
	if pull_radius > 0 then
		for _,enemy in ipairs( caster:FindEnemyUnitsInRadius( position, pull_radius ) ) do
			if not enemy:TriggerSpellAbsorb( self ) then
				enemy:ApplyKnockBack( position, 0, delay, -math.min( pull_radius * 0.75, CalculateDistance( enemy, position ) * 0.75 ), 0, caster, self, true)
			else
				spellAbsorbedUnits[enemy] = true
			end
		end
	end

    Timers:CreateTimer( delay, function()
        ParticleManager:ClearParticle(bubbles)
        StopSoundOn("Ability.pre.Torrent", caster)
        EmitSoundOnLocationWithCaster(position, "Ability.Torrent", caster)
        ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_POINT, caster, {[0]=position})
        for _,enemy in ipairs( caster:FindEnemyUnitsInRadius(position, radius) ) do
			if not ( spellAbsorbedUnits[enemy] or enemy:TriggerSpellAbsorb( self ) ) then
				enemy:ApplyKnockBack(enemy:GetAbsOrigin(), stunDuration + 0.1, stunDuration, 0, 350, caster, self, true)
				enemy:AddNewModifier(caster, self, "modifier_kunkka_water_spout_damage", {duration = stunDuration})
				enemy:AddNewModifier(caster, self, "modifier_kunkka_water_spout_slow", {duration = slow})
				self:TriggerSpellEffect( enemy )
			end
        end
		for _, ally in ipairs(caster:FindFriendlyUnitsInRadius( position, radius ) ) do
			self:TriggerSpellEffect( ally )
			if bonus_armor_duration > 0 then
				ally:AddNewModifier(caster, self, "modifier_kunkka_water_spout_admiral", { duration = bonus_armor_duration })
			end
        end
    end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
modifier_kunkka_water_spout_damage = class({})
LinkLuaModifier("modifier_kunkka_water_spout_damage", "heroes/hero_kunkka/kunkka_water_spout", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_water_spout_damage:OnCreated()
	if not IsServer() then return end
    self.tick = self:GetSpecialValueFor("damage_tick_interval")
    self.damage = self:GetSpecialValueFor("damage")
    self:StartIntervalThink( self.tick )
end

function modifier_kunkka_water_spout_damage:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage * self.tick )
end

function modifier_kunkka_water_spout_damage:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_kunkka_water_spout_damage:IsHidden()
    return true
end

-----------------------------------------------------------------------------------------------------------------------------------------
modifier_kunkka_water_spout_slow = class({})
LinkLuaModifier("modifier_kunkka_water_spout_slow", "heroes/hero_kunkka/kunkka_water_spout", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_water_spout_slow:OnCreated()
    self.slow = self:GetSpecialValueFor("movespeed_bonus")
    self.bonus_dmg = self:GetSpecialValueFor("bonus_physical_damage")
end

function modifier_kunkka_water_spout_slow:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_kunkka_water_spout_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end

function modifier_kunkka_water_spout_slow:OnAttackLanded(params)
	if self.bonus_dmg == 0 then return end
    local parent = self:GetParent()
	if parent ~= params.target then return end
    local caster = self:GetCaster()
	if caster ~= params.attacker then return end
	self:GetAbility():DealDamage( caster, parent, self.bonus_dmg, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_DAMAGE )
end

modifier_kunkka_water_spout_admiral = class({})
LinkLuaModifier("modifier_kunkka_water_spout_admiral", "heroes/hero_kunkka/kunkka_water_spout", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_water_spout_admiral:OnCreated()
    self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
    self.mspd_bonus = self:GetSpecialValueFor("movespeed_bonus") * self:GetSpecialValueFor("admiral_mspd_bonus") / 100
end

function modifier_kunkka_water_spout_admiral:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_kunkka_water_spout_admiral:GetModifierMoveSpeedBonus_Percentage()
    return self.mspd_bonus
end

function modifier_kunkka_water_spout_admiral:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end