antimage_void_of_hatred = class ({})

function antimage_void_of_hatred:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function antimage_void_of_hatred:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Antimage.ManaVoidCast")
	return true
end

function antimage_void_of_hatred:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_Antimage.ManaVoidCast")
end

function antimage_void_of_hatred:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function antimage_void_of_hatred:GetIntrinsicModifierName()
	return "modifier_antimage_void_of_hatred_handler"
end

function antimage_void_of_hatred:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(self) then return end
	local baseDmg = self:GetTalentSpecialValueFor("base_damage")
	local stackDmg = self:GetTalentSpecialValueFor("stack_damage")
	local stunDur = self:GetTalentSpecialValueFor("ministun")
	local radius = self:GetTalentSpecialValueFor("radius")
	
	local handler = caster:FindModifierByNameAndCaster("modifier_antimage_void_of_hatred_handler", caster)
	local damage = handler:GetStackCount()
	handler:SetStackCount( 0 )
	
	self:Stun( target, stunDur )
	
	ParticleManager:FireParticle("particles/antimage_ragevoid.vpcf", PATTACH_POINT_FOLLOW, target, {[1] = Vector(radius,1,1)})
	target:EmitSound("Hero_Antimage.ManaVoid")
	
	local talent = caster:HasTalent("special_bonus_unique_antimage_void_of_hatred_2")
	local silenceDur = caster:FindTalentValue("special_bonus_unique_antimage_void_of_hatred_2")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage( caster, enemy, damage )
			if talent then
				enemy:Silence( self, caster, silenceDur )
			end
		end
	end
end

modifier_antimage_void_of_hatred_handler = class({})
LinkLuaModifier( "modifier_antimage_void_of_hatred_handler", "heroes/hero_antimage/antimage_void_of_hatred", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_void_of_hatred_handler:OnCreated()
	self:OnRefresh()
end

function modifier_antimage_void_of_hatred_handler:OnRefresh()
	self.max = self:GetTalentSpecialValueFor("damage_cap")
	self.perc = self:GetTalentSpecialValueFor("damage_storage") / 100
end

function modifier_antimage_void_of_hatred_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_antimage_void_of_hatred_handler:OnTakeDamage( params )
	local caster = self:GetCaster()
	if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL 
	and not HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE ) 
	and ( params.unit == caster or params.attacker == caster )
	and params.inflictor ~= self:GetAbility()
	and self:GetStackCount() < self.max then
		self:SetStackCount( math.min( self.max, self:GetStackCount() + params.damage * self.perc ) )
	end
end

function modifier_antimage_void_of_hatred_handler:IsHidden()
	return false
end