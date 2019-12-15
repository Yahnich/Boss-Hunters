boss_arthromos_virulent_swarm = class({})

function boss_arthromos_virulent_swarm:OnAbilityPhaseStart()
	local startPos = self:GetCaster():GetAbsOrigin()
	ParticleManager:FireLinearWarningParticle( startPos, startPos + CalculateDirection( self:GetCursorPosition(), startPos ) * self:GetTrueCastRange(), self:GetSpecialValueFor("width") )
	return true
end

function boss_arthromos_virulent_swarm:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn( "Hero_Venomancer.VenomousGale", caster )
	self:FireLinearProjectile("particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf", self:GetSpecialValueFor("speed") * CalculateDirection( self:GetCursorPosition(), caster ), self:GetTrueCastRange(), self:GetSpecialValueFor("width") )
end

function boss_arthromos_virulent_swarm:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) and not hTarget:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		hTarget:AddNewModifier(caster, self, "modifier_boss_arthromos_virulent_swarm", {duration = self:GetSpecialValueFor("duration") + 0.1})
		EmitSoundOn( "Hero_Venomancer.VenomousGaleImpact", hTarget )
		
		local vDirection = vLocation - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		return false
	end
end

modifier_boss_arthromos_virulent_swarm = class({})
LinkLuaModifier( "modifier_boss_arthromos_virulent_swarm", "bosses/boss_arthromos/boss_arthromos_virulent_swarm", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_arthromos_virulent_swarm:OnCreated()
		self.damage = self:GetSpecialValueFor("damage")
		self.radius = self:GetSpecialValueFor("spread_radius")
		self.duration = self:GetSpecialValueFor("duration")
		self:StartIntervalThink(3)
	end
	
	function modifier_boss_arthromos_virulent_swarm:OnRefresh()
		self.damage = self:GetSpecialValueFor("damage")
		self.radius = self:GetSpecialValueFor("spread_radius")
		self.duration = self:GetSpecialValueFor("duration")
		self:StartIntervalThink(3)
	end
	
	function modifier_boss_arthromos_virulent_swarm:OnIntervalThink()
		if not self:GetAbility() or not self:GetCaster() or self:GetAbility():IsNull() or self:GetCaster():IsNull() then 
			self:Destroy()
			return
		end
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		ability:DealDamage( caster, parent, self.damage )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius) ) do
			if not enemy:HasModifier("modifier_boss_arthromos_virulent_swarm") then
				enemy:AddNewModifier(caster, ability, "modifier_boss_arthromos_virulent_swarm", {duration = self.duration + 0.1})
			end
		end
		local novaCloud = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt(novaCloud, 0, parent, PATTACH_POINT_FOLLOW, "attach_caster", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(novaCloud, 1, Vector(self.radius - 100,1,self.radius - 100) )
		ParticleManager:SetParticleControl(novaCloud, 2, parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(novaCloud)
	end
end

function modifier_boss_arthromos_virulent_swarm:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end