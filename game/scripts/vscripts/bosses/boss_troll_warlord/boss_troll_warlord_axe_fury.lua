boss_troll_warlord_axe_fury = boss_troll_warlord_axe_fury or class({})
LinkLuaModifier( "modifier_boss_troll_warlord_axe_fury", "bosses/boss_troll_warlord/boss_troll_warlord_axe_fury.lua", LUA_MODIFIER_MOTION_NONE )

function boss_troll_warlord_axe_fury:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local start = caster:GetAbsOrigin()
	local distance = self:GetTalentSpecialValueFor("range")
	local direction = caster:GetForwardVector()

	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())
	ParticleManager:FireLinearWarningParticle(start, start + direction * distance, self:GetTalentSpecialValueFor("width"))
	return true
end

function boss_troll_warlord_axe_fury:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_boss_troll_warlord_axe_fury", {Duration = self:GetTalentSpecialValueFor("duration")})
end

function boss_troll_warlord_axe_fury:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_TrollWarlord.WhirlingAxes.Target", hTarget)
		self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
		return true
	end
end

modifier_boss_troll_warlord_axe_fury = class({})
function modifier_boss_troll_warlord_axe_fury:OnCreated(table)
	if IsServer() then
		self:GetCaster():FindAbilityByName("boss_troll_warlord_savage_leap"):SetActivated(false)
		self:StartIntervalThink(0.2)
	end
end

function modifier_boss_troll_warlord_axe_fury:OnRemoved(table)
	if IsServer() then
		self:GetCaster():FindAbilityByName("boss_troll_warlord_savage_leap"):SetActivated(true)
	end
end

function modifier_boss_troll_warlord_axe_fury:OnIntervalThink()
	local caster = self:GetCaster()
	local fDir = caster:GetForwardVector()
	local rndAng = math.rad(RandomInt(-self:GetTalentSpecialValueFor("spread_rad")/2, self:GetTalentSpecialValueFor("spread_rad")/2))
	local dirX = fDir.x * math.cos(rndAng) - fDir.y * math.sin(rndAng); 
	local dirY = fDir.x * math.sin(rndAng) + fDir.y * math.cos(rndAng);
	local direction = Vector( dirX, dirY, 0 )
	caster:StartGestureWithPlaybackRate(ACT_DOTA_WHIRLING_AXES_RANGED, 1)
	EmitSoundOn( "Hero_TrollWarlord.WhirlingAxes.Ranged", caster)

	self:GetAbility():FireLinearProjectile("particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf", direction*1500, self:GetTalentSpecialValueFor("range"), self:GetTalentSpecialValueFor("width"), {}, true, true, 100)
	self:StartIntervalThink(self:GetTalentSpecialValueFor("firerate"))
end

function modifier_boss_troll_warlord_axe_fury:IsHidden()
	return false
end

function modifier_boss_troll_warlord_axe_fury:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true}
	return state
end

function modifier_boss_troll_warlord_axe_fury:DeclareFunctions()
	return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function modifier_boss_troll_warlord_axe_fury:GetModifierTurnRate_Percentage()
	return -95
end