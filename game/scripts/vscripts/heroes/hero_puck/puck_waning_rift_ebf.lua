puck_waning_rift_ebf = class({})

function puck_waning_rift_ebf:GetCastRange(target, position)
	return self:GetSpecialValueFor("radius")
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
	
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("silence_duration")
	local disarms = self:GetSpecialValueFor("disarms") == 1
	
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local slow_damage = self:GetSpecialValueFor("slow_damage")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_puck/puck_waning_rift.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = vPos + Vector(0,0,64), [1] = Vector(radius, 0, 0)})
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( vPos, radius ) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			self:DealDamage(caster, enemy, damage)
			enemy:Silence(self, caster, duration, true)
			if disarms then
				enemy:Disarm(self, caster, duration, false)
			end
			if slow_duration > 0 then
				enemy:AddNewModifier( caster, self, "modifier_puck_waning_rift_talent", {duration = slow_duration})
			end
		end
	end
end

modifier_puck_waning_rift_talent = class({})
LinkLuaModifier("modifier_puck_waning_rift_talent", "heroes/hero_puck/puck_waning_rift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_waning_rift_talent:OnCreated(kv)
	self.slow = -self:GetSpecialValueFor("slow")
	self.damage_pct = self:GetSpecialValueFor("slow_damage") / 100
	self.damage = self:GetSpecialValueFor("damage")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_puck_waning_rift_talent:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage * self.damage_pct )
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