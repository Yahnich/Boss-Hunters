zeus_nimbus_storm = class({})
LinkLuaModifier("modifier_zeus_nimbus_storm", "heroes/hero_zeus/zeus_nimbus_storm", LUA_MODIFIER_MOTION_NONE)

function zeus_nimbus_storm:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Zuus.Cloud.Cast", caster)
	local cloud = caster:CreateSummon("npc_dota_zeus_cloud", point, self:GetTalentSpecialValueFor("duration"))
	cloud:AddNewModifier(caster, self, "modifier_zeus_nimbus_storm", {})
end

modifier_zeus_nimbus_storm = class({})
function modifier_zeus_nimbus_storm:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local cloud = self:GetParent()
		local radius = self:GetTalentSpecialValueFor("radius")
		
		self.damage = self:GetCaster():FindAbilityByName("zeus_thunder_bolt"):GetTalentSpecialValueFor("damage")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, cloud:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
		ParticleManager:SetParticleControlEnt(nfx, 2, cloud, PATTACH_POINT_FOLLOW, "attach_hitloc", cloud:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nfx, 5, cloud:GetAbsOrigin())
		self:AttachEffect(nfx)

		self:StartIntervalThink(self:GetTalentSpecialValueFor("bolt_interval"))
	end
end

function modifier_zeus_nimbus_storm:OnIntervalThink()
	local caster = self:GetCaster()
	local cloud = self:GetParent()

	local enemies = caster:FindEnemyUnitsInRadius(cloud:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_Zuus.LightningBolt.Cloud", enemy)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud_strike.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, cloud, PATTACH_POINT, "attach_hitloc", cloud:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 6, Vector(math.random(1,5),math.random(1,5),math.random(1,5)))
					ParticleManager:ReleaseParticleIndex(nfx)

		self:GetAbility():DealDamage(caster, enemy, self.damage, {}, 0)
		if caster:HasTalent("special_bonus_unique_zeus_nimbus_storm_2") then
			local static = caster:FindAbilityByName("zeus_static_field")
			if static then static:ApplyStaticShock(enemy) end
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

function modifier_zeus_nimbus_storm:IsHidden()
	return true
end