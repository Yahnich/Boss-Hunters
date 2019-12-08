rattletrap_aegis_deflector = class({})

function rattletrap_aegis_deflector:GetIntrinsicModifierName()
	return "modifier_rattletrap_aegis_deflector_passive"
end

function rattletrap_aegis_deflector:AegisProc(target, bKnockback)
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("buff_duration")
	local damage = self:GetTalentSpecialValueFor("mana_damage")
	local pushDuration = self:GetTalentSpecialValueFor("push_duration")
	local pushDistance = self:GetTalentSpecialValueFor("push_length")
	
	if not bKnockback then pushDistance = 0 end
	
	caster:AddNewModifier(caster, self, "modifier_rattletrap_aegis_deflector_buff", {duration = duration})
	
	target:ApplyKnockBack(caster:GetAbsOrigin(), pushDuration, pushDuration, pushDistance, 0, caster, self)
	local damage = self:DealDamage(caster, target, damage)
	caster:RestoreMana( damage * self:GetTalentSpecialValueFor("mana_restore") )
	local zap = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(zap, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(zap, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	
	target:EmitSound("Hero_Rattletrap.Power_Cogs_Impact")
	
	-- if caster:HasScepter() then
		-- local nade = caster:FindAbilityByName("rattletrap_rocket_flare_ebf")
		-- if nade then
			-- nade:FireFlashbang( target:GetAbsOrigin() )
		-- end
	-- end
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
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED }
end


function modifier_rattletrap_aegis_deflector_passive:OnAttackLanded( params )
	if params.attacker and params.target == self:GetParent() and params.attacker ~= params.target and self:RollPRNG( self.chance ) then
		self:GetAbility():AegisProc(params.attacker, true)
	end
	if not params.inflictor and self:GetParent():HasTalent("special_bonus_unique_rattletrap_aegis_deflector_1") and params.attacker == self:GetParent() and self:RollPRNG( self:GetParent():FindTalentValue("special_bonus_unique_rattletrap_aegis_deflector_1") ) then
		self:GetAbility():AegisProc(params.target, false)
	end
end

function modifier_rattletrap_aegis_deflector_passive:GetModifierPhysicalArmorBonus( params )
	return self.armor
end

function modifier_rattletrap_aegis_deflector_passive:IsHidden()
	return true
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