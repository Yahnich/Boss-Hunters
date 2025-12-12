zeus_nimbus_storm = class({})
LinkLuaModifier("modifier_zeus_nimbus_storm", "heroes/hero_zeus/zeus_nimbus_storm", LUA_MODIFIER_MOTION_NONE)

function zeus_nimbus_storm:IsStealable()
    return true
end

function zeus_nimbus_storm:IsHiddenWhenStolen()
    return false
end

function zeus_nimbus_storm:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Zuus.Cloud.Cast", caster)
	local cloud = caster:CreateSummon("npc_dota_zeus_cloud", point, self:GetSpecialValueFor("duration"))
	cloud:AddNewModifier(caster, self, "modifier_zeus_nimbus_storm", {})
end

modifier_zeus_nimbus_storm = class({})
function modifier_zeus_nimbus_storm:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local cloud = self:GetParent()
		local radius = self:GetSpecialValueFor("radius")
		
		self.damage = self:GetCaster():FindAbilityByName("zeus_thunder_bolt"):GetSpecialValueFor("damage")
		self.radius = radius
		self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_zeus_nimbus_storm_2")
		
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, cloud:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
		ParticleManager:SetParticleControlEnt(nfx, 2, cloud, PATTACH_POINT_FOLLOW, "attach_hitloc", cloud:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nfx, 5, cloud:GetAbsOrigin())
		self:AttachEffect(nfx)

		self:StartIntervalThink(self:GetSpecialValueFor("bolt_interval"))
		self:OnIntervalThink()
	end
end

function modifier_zeus_nimbus_storm:OnIntervalThink()
	local caster = self:GetCaster()
	local cloud = self:GetParent()

	local enemies = caster:FindEnemyUnitsInRadius(cloud:GetAbsOrigin(), self.radius)
	EmitSoundOn("Hero_Zuus.LightningBolt.Cloud", cloud)
	for _,enemy in pairs(enemies) do
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud_strike.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, cloud, PATTACH_POINT, "attach_hitloc", cloud:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 6, Vector(math.random(1,5),math.random(1,5),math.random(1,5)))
					ParticleManager:ReleaseParticleIndex(nfx)

		if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
			self:GetAbility():DealDamage(caster, enemy, self.damage, {}, 0)
		end
		break
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


function modifier_zeus_nimbus_storm:IsAura()
	return self.talent2
end

function modifier_zeus_nimbus_storm:GetModifierAura()
	return "modifier_zeus_nimbus_storm_talent"
end

function modifier_zeus_nimbus_storm:GetAuraRadius()
	return self.radius
end

function modifier_zeus_nimbus_storm:GetAuraDuration()
	return 0.5
end

function modifier_zeus_nimbus_storm:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_zeus_nimbus_storm:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_zeus_nimbus_storm:IsHidden()
	return true
end

modifier_zeus_nimbus_storm_talent = class({})
LinkLuaModifier("modifier_zeus_nimbus_storm_talent", "heroes/hero_zeus/zeus_nimbus_storm", LUA_MODIFIER_MOTION_NONE)

function modifier_zeus_nimbus_storm_talent:OnCreated()
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_zeus_nimbus_storm_2")
	self.red = self:GetCaster():FindTalentValue("special_bonus_unique_zeus_nimbus_storm_2", "value2")
end

function modifier_zeus_nimbus_storm_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_zeus_nimbus_storm_talent:GetModifierTotalDamageOutgoing_Percentage()
	return self.amp
end

function modifier_zeus_nimbus_storm_talent:GetModifierIncomingDamage_Percentage()
	return self.red
end