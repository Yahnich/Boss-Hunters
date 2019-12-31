boss_leshrac_punishment = class({})

function boss_leshrac_punishment:GetIntrinsicModifierName()
	return "modifier_boss_leshrac_punishment"
end

modifier_boss_leshrac_punishment = class({})
LinkLuaModifier( "modifier_boss_leshrac_punishment", "bosses/boss_leshrac/boss_leshrac_punishment", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_leshrac_punishment:OnCreated()
		self.interval = self:GetSpecialValueFor("interval")
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetSpecialValueFor("damage")
		
		self:StartIntervalThink( self.interval )
	end
	
	function modifier_boss_leshrac_punishment:OnRefresh()
		self:OnCreated()
	end
	
	function modifier_boss_leshrac_punishment:OnIntervalThink()
		if not self:GetCaster():IsAlive() then return end
		local enemy = self:GetCaster():FindRandomEnemyInRadius( self:GetCaster():GetAbsOrigin(), self.radius )
		if enemy then
			ParticleManager:FireParticle( "particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_POINT_FOLLOW, enemy, {[1] = "attach_hitloc"} )
			EmitSoundOn( "Hero_Leshrac.Diabolic_Edict", enemy )
			damageType = DAMAGE_TYPE_MAGICAL
			if enemy:GetMagicalArmorValue( ) > enemy:GetPhysicalArmorReduction()/100 then
				damageType = DAMAGE_TYPE_PHYSICAL
			end
			self:GetAbility():DealDamage( self:GetCaster(), enemy, self.damage, {damage_type = damageType} )
		end
	end
end