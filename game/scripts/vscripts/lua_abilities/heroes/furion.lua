furion_sprout_ebf = class({})

if IsServer() then
	function furion_sprout_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		if self:GetCursorTarget() then
			local point = self:GetCursorTarget():GetAbsOrigin()
		end
		local duration = self:GetSpecialValueFor("duration")
		local vision_range = self:GetSpecialValueFor("vision_range")
		local trees = 8
		local radius = 150
		local angle = math.pi/4
		
		-- Creates 8 temporary trees at each 45 degree interval around the clicked point
		for i=1,trees do
			local position = Vector(point.x+radius*math.sin(angle), point.y+radius*math.cos(angle), point.z)
			CreateTempTree(position, duration)
			angle = angle + math.pi/4
		end
		local dummy = CreateUnitByName( "npc_dummy_blank", point, false, nil, nil, self:GetCaster():GetTeamNumber() )
		dummy:AddNewModifier(self:GetCaster(), self, "modifier_furion_sprout_sleep_thinker", {duration = duration})
		-- Gives vision to the caster's team in a radius around the clicked point for the duration
		AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
		local sprout = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_ABSORIGIN, dummy)
			ParticleManager:SetParticleControl( sprout, 0, dummy:GetOrigin() )
		ParticleManager:ReleaseParticleIndex(sprout)
		EmitSoundOn("Hero_Furion.Sprout", dummy)
	end
end

LinkLuaModifier( "modifier_furion_sprout_sleep_thinker", "lua_abilities/heroes/furion.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_furion_sprout_sleep_thinker = class({})

function modifier_furion_sprout_sleep_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "sleep_radius" )
end

function modifier_furion_sprout_sleep_thinker:OnDestroy( kv )
	if IsServer() then
		self:GetParent():RemoveSelf()
	end
end

function modifier_furion_sprout_sleep_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetModifierAura()
	return "modifier_furion_sprout_sleep_aura"
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_furion_sprout_sleep_thinker:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_furion_sprout_sleep_thinker:IsPurgable()
    return false
end

function modifier_furion_sprout_sleep_thinker:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

function modifier_furion_sprout_sleep_thinker:GetEffectName()
	return "particles/furion_sprout_sleep.vpcf"
end

LinkLuaModifier( "modifier_furion_sprout_sleep_aura", "lua_abilities/heroes/furion.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_furion_sprout_sleep_aura = class({})

function modifier_furion_sprout_sleep_aura:OnCreated()
	self.sleepDelay = self:GetAbility():GetSpecialValueFor("sleep_delay")
	self.sleepDuration = self:GetAbility():GetSpecialValueFor("sleep_duration")
	self.chokeDamage = self:GetAbility():GetSpecialValueFor("damage") * self.sleepDelay
	if IsServer() then
		self:StartIntervalThink(self.sleepDelay)
	end
end

function modifier_furion_sprout_sleep_aura:OnRefresh()
	self.sleepDelay = self:GetAbility():GetSpecialValueFor("sleep_delay")
	self.sleepDuration = self:GetAbility():GetSpecialValueFor("sleep_duration")
	self.chokeDamage = self:GetAbility():GetSpecialValueFor("damage") * self.sleepDelay
end

function modifier_furion_sprout_sleep_aura:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.chokeDamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_furion_sprout_sleep", {duration = self.sleepDuration})
end

LinkLuaModifier( "modifier_furion_sprout_sleep", "lua_abilities/heroes/furion.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_furion_sprout_sleep = class({})

function modifier_furion_sprout_sleep:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_furion_sprout_sleep:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() and params.inflictor ~= self:GetAbility() then
			self:Destroy()
		end
	end
end
function modifier_furion_sprout_sleep:GetEffectName()
	return "particles/generic_gameplay/generic_sleep.vpcf"
end

function modifier_furion_sprout_sleep:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_furion_sprout_sleep:CheckState()
    local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end