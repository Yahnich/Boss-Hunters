rattletrap_battery_assault_ebf = class({})

function rattletrap_battery_assault_ebf:IsStealable()
	return true
end

function rattletrap_battery_assault_ebf:IsHiddenWhenStolen()
	return false
end

function rattletrap_battery_assault_ebf:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_rattletrap_battery_assault_ebf", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_rattletrap_battery_assault_ebf = class({})
LinkLuaModifier("modifier_rattletrap_battery_assault_ebf", "heroes/hero_rattletrap/rattletrap_battery_assault_ebf", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_rattletrap_battery_assault_ebf:OnCreated()
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.radius = self:GetTalentSpecialValueFor("radius")
		self:StartIntervalThink( self:GetTalentSpecialValueFor("interval") )
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_rattletrap_battery_assault_ebf:OnRefresh()
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.radius = self:GetTalentSpecialValueFor("radius")
		self:StartIntervalThink( self:GetTalentSpecialValueFor("interval") )
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_rattletrap_battery_assault_ebf:OnIntervalThink()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local enemies = parent:FindEnemyUnitsInRadius(parentPos, self.radius)
		
		ParticleManager:FireParticle( "particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		EmitSoundOn( "Hero_Rattletrap.Battery_Assault_Launch", parent )
		
		for _, enemy in ipairs( enemies ) do
			return self:ShrapnelShot(enemy)
		end
		self:ShrapnelShot( parentPos + RandomVector( self.radius ) )
	end
	
	function modifier_rattletrap_battery_assault_ebf:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
	
	function modifier_rattletrap_battery_assault_ebf:ShrapnelShot( target )
		local parent = self:GetParent()
		local targetPos = target
		if target.GetAbsOrigin then
			targetPos = target:GetAbsOrigin()
			
			if self:GetCaster():HasTalent("special_bonus_unique_rattletrap_battery_assault_1") then
				for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( targetPos, self:GetCaster():FindTalentValue("special_bonus_unique_rattletrap_battery_assault_1") ) ) do
					self:GetAbility():DealDamage(parent, enemy, self.damage)
					self:GetAbility():Stun(enemy, 0.15, false)
				end
			else
				self:GetAbility():DealDamage(parent, target, self.damage)
				self:GetAbility():Stun(target, 0.15, false)
			end
			EmitSoundOn( "Hero_Rattletrap.Battery_Assault_Impact", target )
		else
			if self:GetCaster():HasTalent("special_bonus_unique_rattletrap_battery_assault_1") then
				for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( targetPos, self:GetCaster():FindTalentValue("special_bonus_unique_rattletrap_battery_assault_1") ) ) do
					self:GetAbility():DealDamage(parent, enemy, self.damage)
					self:GetAbility():Stun(enemy, 0.15, false)
				end
			end
		end
		ParticleManager:FireParticle( "particles/units/heroes/hero_rattletrap/rattletrap_battery_shrapnel.vpcf", PATTACH_POINT_FOLLOW, parent, {[1] = targetPos})
	end
end