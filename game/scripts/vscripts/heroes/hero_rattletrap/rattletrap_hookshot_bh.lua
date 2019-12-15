rattletrap_hookshot_bh = class({})

function rattletrap_hookshot_bh:IsStealable()
    return false
end

function rattletrap_hookshot_bh:IsHiddenWhenStolen()
    return false
end

function rattletrap_hookshot_bh:GetCastAnimation()
    return ACT_DOTA_RATTLETRAP_HOOKSHOT_START
end

function rattletrap_hookshot_bh:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetLevel(1)
        self:SetHidden(false)
        self:SetActivated(true)
    else
        self:SetLevel(0)
        self:SetHidden(true)
        self:SetActivated(false)
    end
end

function rattletrap_hookshot_bh:OnSpellStart()
    local caster = self:GetCaster()
	
	local direction = CalculateDirection( self:GetCursorPosition(), caster )
	
	local speed = self:GetTalentSpecialValueFor("speed")
	local distance = self:GetTrueCastRange() - 32
	local width = self:GetTalentSpecialValueFor("latch_radius")
	local duration = (distance/speed) * 2
	local endPos = caster:GetAbsOrigin() + direction * distance
	
	self.hookFX = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt( self.hookFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl( self.hookFX, 1, endPos )
	ParticleManager:SetParticleControl( self.hookFX, 2, Vector(speed,1,1) )
	ParticleManager:SetParticleControl( self.hookFX, 3, Vector( duration,1,1) )
	EmitSoundOn( "Hero_Rattletrap.Hookshot.Fire", caster )
	
	if caster:GetName() == "npc_dota_hero_rattletrap" and caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON ) then
		caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON ):AddEffects(EF_NODRAW)
	end
	self:FireLinearProjectile("", direction * speed, distance, width, {team = DOTA_UNIT_TARGET_TEAM_BOTH, origin = caster:GetAbsOrigin() + direction * 32}, true, true, width * 2)
end

function rattletrap_hookshot_bh:OnProjectileHit( target, position )
	local caster = self:GetCaster()
	if target and not target:TriggerSpellAbsorb( self ) then
		local distance = CalculateDistance( caster, target )
		local speed = self:GetTalentSpecialValueFor("speed")
		ParticleManager:SetParticleControlEnt( self.hookFX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		target:AddNewModifier( caster, self, "modifier_rattletrap_hookshot_bh_hook", { duration = distance / speed } )
		self:Stun( target, distance / speed )
	else
		ParticleManager:SetParticleControl( self.hookFX, 1, caster:GetAbsOrigin() )
	end
	StopSoundOn( "Hero_Rattletrap.Hookshot.Fire", caster )
	EmitSoundOn( "Hero_Rattletrap.Hookshot.Retract", caster )
	Timers:CreateTimer( self:GetTrueCastRange() / self:GetTalentSpecialValueFor("speed"), function()
		ParticleManager:ClearParticle( self.hookFX )
		StopSoundOn( "Hero_Rattletrap.Hookshot.Retract", caster )
	end)
	return true
end

LinkLuaModifier("modifier_rattletrap_hookshot_bh_hook", "heroes/hero_rattletrap/rattletrap_hookshot_bh", LUA_MODIFIER_MOTION_NONE)
modifier_rattletrap_hookshot_bh_hook = class({})

if IsServer() then
	function modifier_rattletrap_hookshot_bh_hook:OnCreated()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.speed = self:GetTalentSpecialValueFor("speed") * FrameTime()
		self.direction = CalculateDirection( parent, caster )
		self.distance = CalculateDistance( self:GetParent(), caster ) - ( caster:GetHullRadius() + parent:GetHullRadius() + caster:GetCollisionPadding() + parent:GetCollisionPadding() + 64 )
		self.radius = self:GetTalentSpecialValueFor("stun_radius")
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.duration = self:GetTalentSpecialValueFor("duration")
		
		self.enemiesHit = {}
		caster:StartGesture( ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP )
		self:StartMotionController()
	end
	
	function modifier_rattletrap_hookshot_bh_hook:OnDestroy()
		local caster = self:GetCaster()
		ResolveNPCPositions(caster:GetAbsOrigin(), caster:GetHullRadius() + caster:GetCollisionPadding())
		self:StopMotionController()
		caster:RemoveGesture( ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP )
		caster:StartGesture( ACT_DOTA_RATTLETRAP_HOOKSHOT_END )
		
		ParticleManager:ClearParticle( self:GetAbility().hookFX )
		
		EmitSoundOn( "Hero_Rattletrap.Hookshot.Impact", self:GetParent() )
		StopSoundOn( "Hero_Rattletrap.Hookshot.Retract", caster )
		if caster:GetName() == "npc_dota_hero_rattletrap" and caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON ) then
			caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON ):RemoveEffects(EF_NODRAW)
		end
	end
	
	function modifier_rattletrap_hookshot_bh_hook:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
			if not self.enemiesHit[enemy:entindex()] then
				ability:DealDamage( caster, enemy, self.damage )
				ability:Stun( enemy, self.duration )
				self.enemiesHit[enemy:entindex()] = true
				EmitSoundOn( "Hero_Rattletrap.Hookshot.Damage", enemy )
			end
		end
		if caster:IsAlive() and self.distance > 0 then
			local newPos = GetGroundPosition(caster:GetAbsOrigin(), caster) + self.direction * self.speed
			self.distance = self.distance - self.speed
			caster:SetAbsOrigin( newPos )
		else
			self:Destroy()
			return
		end
	end
end

function modifier_rattletrap_hookshot_bh_hook:IsHidden()
	return true
end