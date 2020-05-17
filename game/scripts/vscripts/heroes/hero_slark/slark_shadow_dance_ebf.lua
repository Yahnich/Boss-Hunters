slark_shadow_dance_ebf = class({})

function slark_shadow_dance_ebf:GetIntrinsicModifierName()
	return "modifier_slark_shadow_dance_handler"
end

function slark_shadow_dance_ebf:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("search_radius")
end

function slark_shadow_dance_ebf:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_slark_shadow_dance_activated", {duration = self:GetTalentSpecialValueFor("duration")})
	EmitSoundOn("Hero_Slark.ShadowDance", caster)
end

modifier_slark_shadow_dance_handler = class({})
LinkLuaModifier("modifier_slark_shadow_dance_handler", "heroes/hero_slark/slark_shadow_dance_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_shadow_dance_handler:OnCreated()
	self.regen = self:GetTalentSpecialValueFor("bonus_regen_pct")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.radius = self:GetTalentSpecialValueFor("search_radius")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_slark_shadow_dance_handler:OnRefresh()
	self.regen = self:GetTalentSpecialValueFor("bonus_regen_pct")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.radius = self:GetTalentSpecialValueFor("search_radius")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end


function modifier_slark_shadow_dance_handler:OnIntervalThink()
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius) ) do
		self:SetStackCount(1)
		return
	end
	self:SetStackCount(0)
end

function modifier_slark_shadow_dance_handler:IsHidden()
	return self:GetStackCount() ~= 0
end

function modifier_slark_shadow_dance_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_slark_shadow_dance_handler:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_slark_shadow_dance_2") and not HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS ) then
		self:SetStackCount(1)
		self:StartIntervalThink( self:GetParent():FindTalentValue("special_bonus_unique_slark_shadow_dance_2", "duration") )
	end
end

function modifier_slark_shadow_dance_handler:GetModifierHealthRegenPercentage()
	if not self:IsHidden() or self:GetParent():HasModifier("modifier_slark_shadow_dance_effect") then return self.regen end
end

function modifier_slark_shadow_dance_handler:GetModifierMoveSpeedBonus_Percentage()
	if not self:IsHidden() or self:GetParent():HasModifier("modifier_slark_shadow_dance_effect") then return self.ms end
end

modifier_slark_shadow_dance_activated = class({})
LinkLuaModifier("modifier_slark_shadow_dance_activated", "heroes/hero_slark/slark_shadow_dance_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_shadow_dance_activated:IsHidden()
	return false
end

function modifier_slark_shadow_dance_activated:IsAura()
	return true
end

function modifier_slark_shadow_dance_activated:GetModifierAura()
	return "modifier_slark_shadow_dance_effect"
end

function modifier_slark_shadow_dance_activated:GetAuraRadius()
	return self:GetParent():FindTalentValue("special_bonus_unique_slark_shadow_dance_1")
end

function modifier_slark_shadow_dance_activated:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_slark_shadow_dance_activated:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

modifier_slark_shadow_dance_effect = class({})
LinkLuaModifier("modifier_slark_shadow_dance_effect", "heroes/hero_slark/slark_shadow_dance_ebf", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function modifier_slark_shadow_dance_effect:OnCreated()
		local parent = self:GetParent()
		local sFX = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(sFX, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(sFX, 3, parent, PATTACH_POINT_FOLLOW, "attach_eyeR", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(sFX, 4, parent, PATTACH_POINT_FOLLOW, "attach_eyeL", parent:GetAbsOrigin(), true)
		self:AddEffect(sFX)
	end
end

function modifier_slark_shadow_dance_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function modifier_slark_shadow_dance_effect:StatusEffectPriority()
	return 50
end

function modifier_slark_shadow_dance_effect:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			}
end