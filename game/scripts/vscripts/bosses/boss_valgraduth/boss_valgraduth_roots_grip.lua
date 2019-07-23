boss_valgraduth_roots_grip = class({})

function boss_valgraduth_roots_grip:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	caster:EmitSound("Hero_Treant.Overgrowth.Cast")
	
	local duration = self:GetSpecialValueFor("root_duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
		enemy:AddNewModifier(caster, self, "modifier_boss_valgraduth_roots_grip_root", {duration = duration})
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_treant/treant_overgrowth_trails.vpcf", PATTACH_POINT_FOLLOW, caster, enemy)
		enemy:EmitSound("Hero_Treant.Overgrowth.Target")
	end
end

modifier_boss_valgraduth_roots_grip_root = class({})
LinkLuaModifier("modifier_boss_valgraduth_roots_grip_root", "bosses/boss_valgraduth/boss_valgraduth_roots_grip", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_valgraduth_roots_grip_root:OnCreated()
		self.damage = self:GetSpecialValueFor("root_damage")
		self.pull = self:GetSpecialValueFor("root_pull") * FrameTime()
		self.damageTick = 1
		self:StartIntervalThink(0)
	end
	
	function modifier_boss_valgraduth_roots_grip_root:OnRefresh()
		self:OnCreated()
	end
	
	function modifier_boss_valgraduth_roots_grip_root:OnIntervalThink()
		self.damageTick = self.damageTick - FrameTime()
		if CalculateDistance( self:GetCaster(), self:GetParent() ) >= 250 + self:GetParent():GetHullRadius() + self:GetCaster():GetHullRadius() + self:GetParent():GetCollisionPadding() + self:GetCaster():GetCollisionPadding() then
			self:GetParent():SetAbsOrigin( self:GetParent():GetAbsOrigin() + CalculateDirection( self:GetCaster(), self:GetParent() ) * self.pull )
		else
			self:Destroy()
		end
		if self.damageTick <= 0 then
			self:GetAbility():DealDamage( self:GetCaster(), self:GetCaster(), self.damage )
			self.damageTick = 1
		end
	end
	
	function modifier_boss_valgraduth_roots_grip_root:OnDestroy()
		ResolveNPCPositions( self:GetParent():GetAbsOrigin(), 128 )
	end
end

function modifier_boss_valgraduth_roots_grip_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_boss_valgraduth_roots_grip_root:GetEffectName()
	return "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf"
end