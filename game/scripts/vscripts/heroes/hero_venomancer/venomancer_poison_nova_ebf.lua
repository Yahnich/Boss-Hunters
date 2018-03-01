venomancer_poison_nova_ebf = class({})

function venomancer_poison_nova_ebf:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_venomancer_poison_nova_2") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function venomancer_poison_nova_ebf:CastFilterResultTarget(target)
	if target == self:GetCaster() or target:GetUnitName() == "npc_dota_venomancer_plague_ward_1" then
		return UF_SUCCESS
	else
		return UF_FAIL_CUSTOM
	end
end

function venomancer_poison_nova_ebf:GetCustomCastErrorTarget(target)
	return "Target must be Venomancer or a ward"
end

function venomancer_poison_nova_ebf:OnOwnerDied()
	if self:GetCaster():HasTalent("special_bonus_unique_venomancer_poison_nova_1") then self:OnSpellStart() end
end

function venomancer_poison_nova_ebf:OnAbilityPhaseStart()
	self.warmUp = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	return true
end

function venomancer_poison_nova_ebf:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle(self.warmUp)
end

function venomancer_poison_nova_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local origin = self:GetCursorTarget() or self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("start_radius")
	local maxRadius = self:GetTalentSpecialValueFor("radius")
	local radiusGrowth = self:GetTalentSpecialValueFor("speed") * 0.1
	local duration = self:GetTalentSpecialValueFor("duration")
	if caster:HasScepter() then duration = self:GetTalentSpecialValueFor("duration_scepter") end
	local enemies = FindUnitsInRadius(caster:GetTeam(), origin:GetAbsOrigin(), nil, maxRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_venomancer_poison_nova_cancer", {duration = duration})
		EmitSoundOn( "Hero_Venomancer.PoisonNovaImpact", self:GetCaster() )
	end
	EmitSoundOn( "Hero_Venomancer.PoisonNova", self:GetCaster() )
	
	ParticleManager:ClearParticle(self.warmUp)
	
	local novaCloud = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, origin )
		ParticleManager:SetParticleControlEnt(novaCloud, 0, origin, PATTACH_POINT_FOLLOW, "attach_origin", origin:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(novaCloud, 1, Vector(maxRadius,1,maxRadius) )
		ParticleManager:SetParticleControl(novaCloud, 2, origin:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(novaCloud)
end

LinkLuaModifier( "modifier_venomancer_poison_nova_cancer","heroes/hero_venomancer/venomancer_poison_nova_ebf", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_poison_nova_cancer = class({})

function modifier_venomancer_poison_nova_cancer:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	if self:GetCaster():HasScepter() then self.damage = self:GetAbility():GetSpecialValueFor("damage_scepter") end
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_venomancer_poison_nova_cancer:OnIntervalThink()
	if IsServer() then
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	end
end

function modifier_venomancer_poison_nova_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf"
end

function modifier_venomancer_poison_nova_cancer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end