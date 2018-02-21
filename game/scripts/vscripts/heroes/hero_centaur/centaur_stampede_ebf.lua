centaur_stampede_ebf = class({})

function centaur_stampede_ebf:IsStealable()
	return true
end

function centaur_stampede_ebf:IsHiddenWhenStolen()
	return false
end

function centaur_stampede_ebf:PiercesDisableResistance()
    return true
end

function centaur_stampede_ebf:IsStealable()
	return true
end

function centaur_stampede_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), -1)
	
	EmitSoundOn("Hero_Centaur.Stampede.Cast", caster)
	for _, ally in ipairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_centaur_stampede_ebf", {duration = self:GetTalentSpecialValueFor("duration")})
		ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_stampede_cast.vpcf", PATTACH_POINT_FOLLOW, ally)
	end
end

modifier_centaur_stampede_ebf = class({})
LinkLuaModifier("modifier_centaur_stampede_ebf", "heroes/hero_centaur/centaur_stampede_ebf", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_centaur_stampede_ebf:OnCreated()
		self.hitTable = {}
		self.radius = self:GetTalentSpecialValueFor("radius")
		self.damage = self:GetTalentSpecialValueFor("base_damage") + self:GetCaster():GetStrength() * self:GetTalentSpecialValueFor("strength_damage") 
		self.slowDuration = self:GetTalentSpecialValueFor("slow_duration")
		
		local oFX = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_stampede_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddOverHeadEffect(oFX)
		local sFX = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_stampede.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		self:AddEffect(sFX)
		
		EmitSoundOn("Hero_Centaur.Stampede.Movement", self:GetParent())
		
		self:StartIntervalThink(0.1)
	end
	
	function modifier_centaur_stampede_ebf:OnRefresh()
		self.hitTable = {}
		self.radius = self:GetTalentSpecialValueFor("radius")
		self.damage = self:GetTalentSpecialValueFor("base_damage") + self:GetCaster():GetStrength() * self:GetTalentSpecialValueFor("strength_damage") 
		self.slowDuration = self:GetTalentSpecialValueFor("slow_duration")
	end
	
	function modifier_centaur_stampede_ebf:OnIntervalThink()
		local parent = self:GetParent()
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			if not self.hitTable[tostring(enemy:entindex())] then
				self.hitTable[tostring( enemy:entindex() )] = true
				print("damaging")
				self:Trample(enemy)
			end
		end
	end
	
	function modifier_centaur_stampede_ebf:OnDestroy()
		StopSoundOn("Hero_Centaur.Stampede.Movement", self:GetParent())
	end
	
	function modifier_centaur_stampede_ebf:Trample(target)
		local caster = self:GetCaster()
		ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_open_wounds_impact_slash_splatter.vpcf", PATTACH_POINT_FOLLOW, target)
		EmitSoundOn("Hero_Centaur.Stampede.Stun", target)
		self:GetAbility():DealDamage( caster, target, self.damage )
		if caster:HasTalent("special_bonus_unique_centaur_stampede_1") then
			self:GetAbility():Stun( target, self.slowDuration, false )
		end
		target:AddNewModifier( caster, self:GetAbility(), "modifier_centaur_stampede_ebf_slow", {duration = self.slowDuration} )
	end
end

function modifier_centaur_stampede_ebf:GetEffectName()
	return "particles/units/heroes/hero_centaur/centaur_stampede_haste.vpcf"
end

function modifier_centaur_stampede_ebf:CheckState()
	if self:GetCaster():HasScepter() then return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
end

function modifier_centaur_stampede_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_centaur_stampede_ebf:GetModifierIncomingDamage_Percentage()
	if  self:GetCaster():HasScepter() then return self:GetTalentSpecialValueFor("damage_reduction_scepter") end
end

function modifier_centaur_stampede_ebf:GetModifierMoveSpeed_AbsoluteMin()
	return 550
end

modifier_centaur_stampede_ebf_slow = class({})
LinkLuaModifier("modifier_centaur_stampede_ebf_slow", "heroes/hero_centaur/centaur_stampede_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_centaur_stampede_ebf_slow:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("100") * (-1)
end

function modifier_centaur_stampede_ebf_slow:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("100") * (-1)
end

function modifier_centaur_stampede_ebf_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_centaur_stampede_ebf_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_centaur_stampede_ebf_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_monkey_king_spring_slow.vpcf"
end

function modifier_centaur_stampede_ebf_slow:StatusEffectPriority()
	return 3
end