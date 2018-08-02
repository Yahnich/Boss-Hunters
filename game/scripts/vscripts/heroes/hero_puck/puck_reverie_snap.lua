puck_reverie_snap = class({})

function puck_reverie_snap:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local target = caster:GetAbsOrigin()
	local illusoryOrb = caster:FindAbilityByName( "puck_illusory_orb_ebf" )
	if illusoryOrb then
		illusoryOrb.orbProjectiles = illusoryOrb.orbProjectiles or {}
		local orb = nil
		local distance = CalculateDistance(position, caster)
		for projID, _ in pairs( illusoryOrb.orbProjectiles ) do
			if orb ~= projID and CalculateDistance(position, ProjectileManager:GetLinearProjectileLocation(projID)) < distance then
				orb = projID
				distance = CalculateDistance(position, ProjectileManager:GetLinearProjectileLocation(projID))
			end
		end
		if orb then
			target = ProjectileManager:GetLinearProjectileLocation(orb)
		end
	end
	if caster:HasTalent("special_bonus_unique_puck_reverie_snap_2") then
		caster:AddNewModifier(caster, self, "modifier_puck_reverie_snap_talent", {duration = self:GetTalentSpecialValueFor("coil_duration") + self:GetTalentSpecialValueFor("suck_duration")})
	end
	self:ReverieSnap(target)
end

function puck_reverie_snap:OnProjectileHit(target, position)
	if target then
		self:GetCaster():PerformGenericAttack(target, true)
	end
end

function puck_reverie_snap:ReverieSnap(position)
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("suck_radius")
	local suckDur = self:GetTalentSpecialValueFor("suck_duration")

	local vPos = GetGroundPosition(position, caster)
	EmitSoundOnLocationWithCaster(vPos, "Hero_Dark_Seer.Vacuum", caster)
	ParticleManager:FireParticle("particles/reverie_snap_pull.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = vPos, [1] = Vector(radius,0,0)})
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( vPos, radius ) ) do
		enemy:ApplyKnockBack(vPos, suckDur, suckDur, -(CalculateDistance(enemy, caster) - 150), 0, caster, self)
		enemy:AddNewModifier(caster, self, "modifier_puck_reverie_snap_pull", {duration = suckDur})
	end
	
	if caster:HasScepter() then
		local illusoryOrb = caster:FindAbilityByName( "puck_illusory_orb_ebf" )
		if illusoryOrb then
			local orbs = self:GetTalentSpecialValueFor("scepter_orbs")
			local speed = illusoryOrb:GetTalentSpecialValueFor("orb_speed")
			local direction =  caster:GetForwardVector()
			local angle = 360 / orbs
			for i = 1, orbs do
				illusoryOrb:CreateOrb(speed * direction, position)
				direction = RotateVector2D( direction, ToRadians(angle) )
			end
		end
	end
	
	Timers:CreateTimer(suckDur, function()
		EmitSoundOnLocationWithCaster(vPos, "Hero_Puck.Dream_Coil", caster)
		CreateModifierThinker(caster, self, "modifier_puck_reverie_snap_coil", {duration = self:GetTalentSpecialValueFor("coil_duration")}, vPos, caster:GetTeam(), false)
	end)
end

modifier_puck_reverie_snap_pull = class({})
LinkLuaModifier("modifier_puck_reverie_snap_pull", "heroes/hero_puck/puck_reverie_snap", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_reverie_snap_pull:GetEffectName()
	return "particles/reverie_snap_pull_rope.vpcf"
end

function modifier_puck_reverie_snap_pull:IsHidden()
	return true
end

modifier_puck_reverie_snap_tether = class({})
LinkLuaModifier("modifier_puck_reverie_snap_tether", "heroes/hero_puck/puck_reverie_snap", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_reverie_snap_tether:OnCreated(kv)
	if IsServer() then
		local caster = EntIndexToHScript(tonumber(kv.entindex))
		local parent = self:GetParent()
		
		local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(FX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(FX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AddEffect(FX)
	end
end

modifier_puck_reverie_snap_coil = class({})
LinkLuaModifier("modifier_puck_reverie_snap_coil", "heroes/hero_puck/puck_reverie_snap", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_puck_reverie_snap_coil:OnCreated()
		self.radius = self:GetTalentSpecialValueFor("coil_break_radius")
		self.damage = self:GetTalentSpecialValueFor("coil_break_damage")
		self.duration = self:GetTalentSpecialValueFor("coil_stun_duration")
		self.radiusDecrease = self.radius / self:GetRemainingTime() * 0.1
		self.initRadius = self:GetTalentSpecialValueFor("coil_radius")
		
		local initDamage = self:GetTalentSpecialValueFor("coil_init_damage_tooltip")
		local initStun =  self:GetTalentSpecialValueFor("stun_duration")
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		
		if caster:HasTalent("special_bonus_unique_puck_reverie_snap_1") then
			self.attackRate = caster:FindTalentValue("special_bonus_unique_puck_reverie_snap_1")
			self.attackThink = 0
		end
		
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.initRadius) ) do
			ability:Stun(enemy, initStun)
			ability:DealDamage(caster, enemy, initDamage)
			enemy:AddNewModifier(caster, ability, "modifier_puck_reverie_snap_tether", {duration = self:GetTalentSpecialValueFor("coil_duration"), entindex = parent:entindex()})
		end
		self:StartIntervalThink(0.1)
	end
	
	function modifier_puck_reverie_snap_coil:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		self.radius = self.radius - self.radiusDecrease
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), -1) ) do
			if enemy:HasModifier("modifier_puck_reverie_snap_tether") and CalculateDistance(enemy, parent) > self.radius then
				EmitSoundOn("Hero_Puck.Dream_Coil_Snap", enemy)
				enemy:RemoveModifierByName("modifier_puck_reverie_snap_tether")
				ability:Stun(enemy, self.duration)
				ability:DealDamage(caster, enemy, self.damage)
			end
		end
		if self.attackRate then
			self.attackThink = self.attackThink + 0.1
			if self.attackThink >= self.attackRate then
				self.attackThink = 0
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.initRadius) ) do
					ability:FireTrackingProjectile("particles/units/heroes/hero_puck/puck_base_attack.vpcf", enemy, caster:GetProjectileSpeed(), {source = parent, origin = parent:GetAbsOrigin()})
				end
			end
		end
	end
end

modifier_puck_reverie_snap_talent = class({})
LinkLuaModifier("modifier_puck_reverie_snap_talent", "heroes/hero_puck/puck_reverie_snap", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_reverie_snap_talent:CheckState()
	return {[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_OUT_OF_GAME] = true}
end

function modifier_puck_reverie_snap_talent:GetStatusEffectName()
	return "particles/status_fx/status_effect_phase_shift.vpcf"
end

function modifier_puck_reverie_snap_talent:StatusEffectPriority()
	return 5
end

function modifier_puck_reverie_snap_talent:GetEffectName()
	return "particles/units/heroes/hero_puck/puck_phase_shift.vpcf"
end