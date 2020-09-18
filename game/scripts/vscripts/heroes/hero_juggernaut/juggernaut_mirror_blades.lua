juggernaut_mirror_blades = class({})

function juggernaut_mirror_blades:OnSpellStart()
	local caster = self:GetCaster()
	caster:Dispel( caster, true )
	caster:AddNewModifier(caster, self, "modifier_juggernaut_mirror_blades", {duration = self:GetTalentSpecialValueFor("duration")})
end

function juggernaut_mirror_blades:ShouldUseResources()
	return true
end

modifier_juggernaut_mirror_blades = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_juggernaut_mirror_blades", "heroes/hero_juggernaut/juggernaut_mirror_blades", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_mirror_blades:OnCreated()
	local caster = self:GetCaster()
	self:OnRefresh()
	if IsServer() then
		self:MirrorBladeDamage(self.radius, self.damage)
		EmitSoundOn("Hero_Juggernaut.BladeFuryStart" , self:GetParent() )
		local spinFX = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControl(spinFX, 5, Vector(self.radius, 1, 1))
		self:AddEffect(spinFX)
	end
end

function modifier_juggernaut_mirror_blades:OnRefresh()
	local caster = self:GetCaster()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.tick = self:GetTalentSpecialValueFor("damage_tick")
	self.bat = self:GetTalentSpecialValueFor("base_attack_time")
	
	self.ms = caster:FindTalentValue("special_bonus_unique_juggernaut_mirror_blades_2")
	self.talent2 = caster:HasTalent("special_bonus_unique_juggernaut_mirror_blades_2")
	self:StartIntervalThink(self.tick)
	if IsServer() then
		self:MirrorBladeDamage(self.radius, self.damage)
		EmitSoundOn("Hero_Juggernaut.BladeFuryStart" , self:GetParent() )
	end
	
	caster:HookInModifier("GetBaseAttackTime_BonusPercentage", self)
end

function modifier_juggernaut_mirror_blades:OnDestroy()
	self:GetParent():HookOutModifier("GetBaseAttackTime_BonusPercentage", self)
	if IsServer() then
		self:GetParent():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		StopSoundOn("Hero_Juggernaut.BladeFuryStart" , self:GetParent() )
		EmitSoundOn("Hero_Juggernaut.BladeFuryStop" , self:GetParent() )
		
		local caster = self:GetCaster()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius * 2 ) ) do
			enemy:SmoothFindClearSpace( enemy:GetAbsOrigin() )
		end
	end
end

function modifier_juggernaut_mirror_blades:OnIntervalThink()
	if IsServer() then
		self:MirrorBladeDamage(self.radius, self.damage)
		if self.talent2 then
			local caster = self:GetCaster()
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius * 2 ) ) do
				if CalculateDistance( enemy, caster ) > 150 then
					enemy:SetAbsOrigin( enemy:GetAbsOrigin() + CalculateDirection( caster, enemy ) * 250 * FrameTime() )
				end
			end
		end
	end
end

function modifier_juggernaut_mirror_blades:MirrorBladeDamage(radius, damage)
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
		self:GetAbility():DealDamage( caster, enemy, self.damage * self.tick )
		enemy:SmoothFindClearSpace( enemy:GetAbsOrigin() )
		ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_tgt.vpcf", PATTACH_POINT_FOLLOW, enemy)
		EmitSoundOn("Hero_Juggernaut.BladeFury.Impact", enemy )
	end
end

function modifier_juggernaut_mirror_blades:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_juggernaut_mirror_blades:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_juggernaut_mirror_blades:GetBaseAttackTime_BonusPercentage()
	return (self.bat - 1) * 100
end

function modifier_juggernaut_mirror_blades:CheckState()
	local state = {	[MODIFIER_STATE_MAGIC_IMMUNE] = true}
	return state
end