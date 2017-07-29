ifrit_fire_surge = class({})

--------------------------------------------------------------------------------
function ifrit_fire_surge:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return "custom/ifrit_fire_surge_kindled"
	else
		return "custom/ifrit_fire_surge"
	end
end

function ifrit_fire_surge:OnSpellStart()
	local caster = self:GetCaster()

	self.speed = self:GetTalentSpecialValueFor( "speed" )
	self.width_initial = self:GetTalentSpecialValueFor( "width_initial" )
	self.width_end = self:GetTalentSpecialValueFor( "width_end" )
	self.distance = self:GetTalentSpecialValueFor( "distance" )
	
	self:GetCaster().selfImmolationDamageBonus = self:GetCaster().selfImmolationDamageBonus or 0
	self.maxDamage = self:GetTalentSpecialValueFor( "max_damage" ) + self:GetCaster().selfImmolationDamageBonus
	self.minDamage = self:GetTalentSpecialValueFor( "min_damage" ) + self:GetCaster().selfImmolationDamageBonus / 2
	
	self.projectileTable = {}

	EmitSoundOn( "Hero_Lina.DragonSlave.Cast", caster )

	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetOrigin()
	else
		vPos = self:GetCursorPosition()
	end

	local vDirection = vPos - caster:GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	self.speed = self.speed * ( self.distance / ( self.distance - self.width_initial ) )
	self.damage_falloff = (self.maxDamage - self.minDamage) * (self.distance / self.speed) * FrameTime()
	self:CreateFireSurge(vDirection)
	if caster:HasModifier("modifier_ifrit_kindled_soul_active") then
		for i = 1, self:GetTalentSpecialValueFor( "kindled_total_surges" ) do
			self:UseResources(true, false, false)
			local newDir = RotateVector2D(vDirection, 0.261799 * math.ceil(i/2) * (-1)^i)
			self:CreateFireSurge(newDir)
		end
	end
	EmitSoundOn( "Hero_Lina.DragonSlave", caster )
end

function ifrit_fire_surge:CreateFireSurge(vDirection)
	local info = {
		EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.width_initial,
		fEndRadius = self.width_end,
		vVelocity = vDirection * self.speed,
		fDistance = self.distance,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}
	ProjectileManager:CreateLinearProjectile( info )
end
--------------------------------------------------------------------------------

function ifrit_fire_surge:OnProjectileHitHandle( hTarget, vLocation, projectileID )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		self.projectileTable[projectileID] = self.projectileTable[projectileID] or self.maxDamage
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.projectileTable[projectileID],
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_ifrit_fire_surge_fire_debuff", { duration = self:GetTalentSpecialValueFor("dot_duration"), damage = self.projectileTable[projectileID] * self:GetTalentSpecialValueFor("dot_dmg_pct") / 100} )
		local vDirection = vLocation - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
	self.projectileTable[projectileID] = nil -- clear memory space
	return false
end

function ifrit_fire_surge:OnProjectileThinkHandle( projectileID )
	if not self:GetCaster():HasTalent("ifrit_fire_surge_talent_1") then
		self.projectileTable[projectileID] = self.projectileTable[projectileID] or self.maxDamage
		if self.projectileTable[projectileID] > self.minDamage then
			self.projectileTable[projectileID] = (self.projectileTable[projectileID] or self.maxDamage) - self.damage_falloff
		elseif self.projectileTable[projectileID] < self.minDamage then
			self.projectileTable[projectileID] = self.minDamage
		end
	end
	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_ifrit_fire_surge_fire_debuff", "heroes/ifrit/ifrit_fire_surge.lua", LUA_MODIFIER_MOTION_NONE )
modifier_ifrit_fire_surge_fire_debuff = class({})

function modifier_ifrit_fire_surge_fire_debuff:OnCreated(kv)
	self.damage_over_time = tonumber(kv.damage)
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = (self.damage_over_time or 0) * 2 end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function modifier_ifrit_fire_surge_fire_debuff:OnRefresh(kv)
	self.damage_over_time = tonumber(kv.damage)
	if self:GetCaster():HasScepter() then self.damage_over_time = (self.damage_over_time or 0) * 2 end
end

function modifier_ifrit_fire_surge_fire_debuff:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_ifrit_fire_surge_fire_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_fire_surge_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_ifrit_fire_surge_fire_debuff:IsFireDebuff()
	return true
end