zeus_static_field = class({})

function zeus_static_field:GetIntrinsicModifierName()
    return "modifier_zeus_static_field"
end

function zeus_static_field:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Zuus.Cloud.Cast", caster)
	local cloud = caster:CreateSummon("npc_dota_zeus_cloud", point, self:GetSpecialValueFor("duration"))
	cloud:AddNewModifier(caster, self, "modifier_zeus_nimbus_storm", {})
end

function zeus_static_field:ApplyStaticShock(target)
	if not target:IsAlive() then return end
	-- Attaches the particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle,0,target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)
	-- Plays the sound on the target
	EmitSoundOn("Hero_Zuus.StaticField", target)
	-- local stacks = target:AddNewModifier(self:GetCaster(), self, "modifier_zeus_static_field_static_charge", {duration = self.stack_duration}):GetStackCount()
	local damage = 0
	if target:IsMinion() then
		damage = math.ceil( target:GetMaxHealth() * self.miniondamage )
	else
		damage = math.ceil( target:GetHealth() * self.hpdamage )
	end
	-- Deals the damage based on the target's current health
	self:DealDamage(self:GetCaster(), target, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS})
end

modifier_zeus_static_field = class({})
LinkLuaModifier( "modifier_zeus_static_field", "heroes/hero_zeus/zeus_static_field.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_zeus_static_field:IsPassive()
	return true
end
function modifier_zeus_static_field:IsHidden()
	return true
end

function modifier_zeus_static_field:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

if IsServer() then
	function modifier_zeus_static_field:OnCreated()
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self:GetAbility().hpdamage = self:GetAbility():GetSpecialValueFor("damage_health_pct") / 100
		self:GetAbility().miniondamage = self:GetAbility():GetSpecialValueFor("minion_damage_pct") / 100
	end

	function modifier_zeus_static_field:OnTakeDamage(params)
		if params.attacker ~= self:GetParent() then return end
		if params.inflictor and params.attacker:HasAbility( params.inflictor:GetName() ) then -- check if caster has ability
			local ability = self:GetAbility()
			ability:ApplyStaticShock( params.unit )
		end
	end
end

modifier_zeus_nimbus_storm = class({})
LinkLuaModifier("modifier_zeus_nimbus_storm", "heroes/hero_zeus/zeus_static_field", LUA_MODIFIER_MOTION_NONE)
function modifier_zeus_nimbus_storm:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local cloud = self:GetParent()
		local radius = self:GetSpecialValueFor("radius")
		
		cloud.radius = radius
		
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, cloud:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
		ParticleManager:SetParticleControlEnt(nfx, 2, cloud, PATTACH_POINT_FOLLOW, "attach_hitloc", cloud:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nfx, 5, cloud:GetAbsOrigin())
		self:AttachEffect(nfx)
		
		caster._NimbusClouds = caster._NimbusClouds or {}
		table.insert( caster._NimbusClouds, cloud )
	end
end

function modifier_zeus_nimbus_storm:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local cloud = self:GetParent()
		table.removeval( caster._NimbusClouds, cloud )
	end
end

function modifier_zeus_nimbus_storm:CheckState()
	local state = { [MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,}
	return state
end

function modifier_zeus_nimbus_storm:IsHidden()
	return true
end