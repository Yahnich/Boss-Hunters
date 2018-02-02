rattletrap_aegis_deflector = class({})

function rattletrap_aegis_deflector:GetIntrinsicModifierName()
	return "modifier_rattletrap_aegis_deflector_passive"
end

function rattletrap_aegis_deflector:AegisProc(target)
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("buff_duration")
	local damage = self:GetTalentSpecialValueFor("mana_damage")
	local pushDuration = self:GetTalentSpecialValueFor("push_duration")
	local pushDistance = self:GetTalentSpecialValueFor("push_length")
	
	if not bKnockback then pushDistance = 0 end
	
	caster:AddNewModifier(caster, self, "modifier_rattletrap_aegis_deflector_buff", {duration = duration})
	
	target:ApplyKnockBack(caster:GetAbsOrigin(), pushDuration, pushDuration, pushDistance, 0, caster, self)
	self:DealDamage(caster, target, damage)
	
	local zap = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(zap, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(zap, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	
	target:EmitSound("Hero_Rattletrap.Power_Cogs_Impact")
end

modifier_rattletrap_aegis_deflector_passive = class({})
LinkLuaModifier("modifier_rattletrap_aegis_deflector_passive", "heroes/hero_rattletrap/rattletrap_aegis_deflector", LUA_MODIFIER_MOTION_NONE)

function modifier_rattletrap_aegis_deflector_passive:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.chance = self:GetTalentSpecialValueFor("proc_chance")
end

function modifier_rattletrap_aegis_deflector_passive:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.chance = self:GetTalentSpecialValueFor("proc_chance")
end

function modifier_rattletrap_aegis_deflector_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE}
end


function modifier_rattletrap_aegis_deflector_passive:OnTakeDamage( params )
	print(params.unit, self:GetParent(), self.chance)
	if params.unit == self:GetParent() and RollPercentage( self.chance ) then
		self:GetAbility():AegisProc(params.attacker, true)
	end
	if self:GetParent():HasTalent("special_bonus_unique_rattletrap_aegis_deflector_1") and params.attacker == self:GetParent() and RollPercentage( self:GetParent():FindTalentValue("special_bonus_unique_rattletrap_aegis_deflector_1") ) then
		self:GetAbility():AegisProc(params.unit, false)
	end
end

function modifier_rattletrap_aegis_deflector_passive:GetModifierPhysicalArmorBonus( params )
	return self.armor
end

function modifier_rattletrap_aegis_deflector_passive:IsHidden()
	return false
end

modifier_rattletrap_aegis_deflector_buff = class({})
LinkLuaModifier("modifier_rattletrap_aegis_deflector_buff", "heroes/hero_rattletrap/rattletrap_aegis_deflector", LUA_MODIFIER_MOTION_NONE)

function modifier_rattletrap_aegis_deflector_buff:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_buff")
	self.regen = self:GetTalentSpecialValueFor("heal_pct")
end

function modifier_rattletrap_aegis_deflector_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_rattletrap_aegis_deflector_buff:GetModifierPhysicalArmorBonus( params )
	return self.armor
end

function modifier_rattletrap_aegis_deflector_buff:GetModifierHealthRegenPercentage( params )
	return self.regen
end