boss_lifestealer_consume = class({})

function boss_lifestealer_consume:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_lifestealer_consume:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:EmitSound( "Hero_LifeStealer.Assimilate.Target" )
	if target:IsRealHero() then
		if not target:TriggerSpellAbsorb(self) then
			target:SetAttacking( caster )
			target:MoveToTargetToAttack( caster ) 
			target:SetForceAttackTarget( caster )
			target:SetAbsOrigin( caster:GetAbsOrigin() )
			target:AddNewModifier( caster, self, "modifier_boss_lifestealer_consume_swallow", {duration = self:GetSpecialValueFor("hero_duration")})
		end
	else
		local health = target:GetHealth()
		local damage = target:GetAttackDamage()
		caster:SetMaxHealth( caster:GetMaxHealth() + health )
		caster:SetBaseMaxHealth( caster:GetBaseMaxHealth() + health )
		caster:HealEvent( health, self, caster )
		caster:SetAverageBaseDamage( caster:GetAttackDamage() + damage, 25)
		target:AttemptKill(self, caster)
	end
end

modifier_boss_lifestealer_consume_swallow = class({})
LinkLuaModifier( "modifier_boss_lifestealer_consume_swallow", "bosses/boss_lifestealer/boss_lifestealer_consume", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_lifestealer_consume_swallow:OnCreated()
	if IsServer() then
		self.digest = ( self:GetSpecialValueFor("digest_dmg") * 0.5 ) / 100
		self.damage = self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("spit_dmg") / 100
		self:StartIntervalThink(0.5)
		self:GetParent():AddNoDraw()
	end
end

function modifier_boss_lifestealer_consume_swallow:OnIntervalThink()
	local caster = self:GetCaster()
	if not caster:IsAlive() then
		self:Destroy()
		return true
	end
	local parent = self:GetParent()
	local damage = self:GetAbility():DealDamage( caster, parent, parent:GetMaxHealth() * self.digest, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION } )
	caster:HealEvent( damage, self:GetAbility(), caster )
	parent:SetAbsOrigin( caster:GetAbsOrigin() )
end

function modifier_boss_lifestealer_consume_swallow:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		parent:RemoveNoDraw()
		if not caster:IsAlive() then
			local position = parent:GetAbsOrigin()
			FindClearSpaceForUnit( parent, position, true )
			GridNav:DestroyTreesAroundPoint( position, 64, true ) 
		else
			caster:StartGesture( ACT_DOTA_LIFESTEALER_EJECT )
			local position = caster:GetAbsOrigin() + caster:GetForwardVector() * 250
			FindClearSpaceForUnit( parent, position, true )
			GridNav:DestroyTreesAroundPoint( position, 64, true ) 
			caster:EmitSound( "Hero_LifeStealer.Assimilate.Destroy" )
		end
		
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_boss_lifestealer_consume_swallow:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_boss_lifestealer_consume_swallow:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_MUTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,}
end

function modifier_boss_lifestealer_consume_swallow:OnTakeDamage(params)
	if params.unit == self:GetCaster() then
		self.damage = self.damage - params.damage
		if self.damage <= 0 then
			self:Destroy()
		end
	end
end