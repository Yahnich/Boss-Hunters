puck_waning_rift_ebf = class({})

function puck_waning_rift_ebf:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function puck_waning_rift_ebf:OnSpellStart()
	local caster = self:GetCaster()
	
	local illusoryOrb = caster:FindAbilityByName( "puck_illusory_orb_ebf" )
	illusoryOrb.orbProjectiles = illusoryOrb.orbProjectiles or {}
	
	self:WaningRift()
	for projID, _ in pairs( illusoryOrb.orbProjectiles ) do
		self:WaningRift(ProjectileManager:GetLinearProjectileLocation(projID))
	end
	EmitSoundOn("Hero_Puck.Waning_Rift", caster)
end

function puck_waning_rift_ebf:WaningRift(position)
	local caster = self:GetCaster()
	local vPos = position or caster:GetAbsOrigin()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("silence_duration")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_puck/puck_waning_rift.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = vPos + Vector(0,0,64), [1] = Vector(radius, 0, 0)})
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( vPos, radius ) ) do
		self:DealDamage(caster, enemy, damage)
		enemy:Silence(self, caster, duration, true)
		if caster:HasTalent("special_bonus_unique_puck_waning_rift_1") then
			enemy:Disarm(self, caster, duration, false)
		end
		if caster:HasTalent("special_bonus_unique_puck_waning_rift_2") then
			enemy:AddNewModifier( caster, self, "modifier_puck_waning_rift_talent", {duration = caster:FindTalentValue("special_bonus_unique_puck_waning_rift_2", "duration")})
		end
	end
end

modifier_puck_waning_rift_talent = class({})
LinkLuaModifier("modifier_puck_waning_rift_talent", "heroes/hero_puck/puck_waning_rift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_waning_rift_talent:OnCreated(kv)
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_puck_waning_rift_2", "slow")
	self.damage = self:GetTalentSpecialValueFor("damage") * self:GetCaster():FindTalentValue("special_bonus_unique_puck_waning_rift_2") / 100
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_puck_waning_rift_talent:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_puck_waning_rift_talent:GetEffectName()
	return "particles/heroes/hero_puck/puck_waning_rift_debuff_slow.vpcf"
end

function modifier_puck_waning_rift_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_puck_waning_rift_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end