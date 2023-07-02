witch_doctor_voodoo_restoration_bh = class({})

function witch_doctor_voodoo_restoration_bh:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_witch_doctor_marasa_mirror") then
		return "custom/witch_doctor_voodoo_restoration_heal"
	else
		return "witch_doctor_voodoo_restoration"
	end
end

function witch_doctor_voodoo_restoration_bh:GetCastRange()
	return self:GetTalentSpecialValueFor("radius")
end

function witch_doctor_voodoo_restoration_bh:GetManaCost(iLvl)
	local manaCost = self.BaseClass.GetManaCost( self, iLvl ) 
	if self:GetCaster():HasTalent("special_bonus_unique_witch_doctor_voodoo_restoration_1") then
		manaCost = manaCost + manaCost * self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_voodoo_restoration_1", "cost")/100
	end
	return manaCost
end

function witch_doctor_voodoo_restoration_bh:OnTalentLearned( talent )
	local caster = self:GetCaster()
	for _, unit in ipairs( caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		unit:RemoveModifierByName("modifier_witch_doctor_voodoo_restoration_bh_curse")
		unit:RemoveModifierByName("modifier_witch_doctor_voodoo_restoration_bh_heal")
	end
	local curseHandler = caster:FindModifierByName("modifier_witch_doctor_voodoo_restoration_curse_bh_handler")
	if curseHandler then
		curseHandler:Destroy()
		caster:AddNewModifier(caster, self, "modifier_witch_doctor_voodoo_restoration_curse_bh_handler", {})
	end
	local healHandler = caster:FindModifierByName("modifier_witch_doctor_voodoo_restoration_bh_handler")
	if healHandler then 
		healHandler:Destroy()
		caster:AddNewModifier(caster, self, "modifier_witch_doctor_voodoo_restoration_bh_handler", {})
	end
end

function witch_doctor_voodoo_restoration_bh:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration", self:GetCaster())
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Loop", self:GetCaster())

		if caster:HasScepter() then
			caster:AddNewModifier(caster, self, "modifier_witch_doctor_voodoo_restoration_bh_handler", {})
			caster:AddNewModifier(caster, self, "modifier_witch_doctor_voodoo_restoration_curse_bh_handler", {})
		elseif caster:HasModifier("modifier_witch_doctor_marasa_mirror") then
			caster:AddNewModifier(caster, self, "modifier_witch_doctor_voodoo_restoration_curse_bh_handler", {})
		else
			caster:AddNewModifier(caster, self, "modifier_witch_doctor_voodoo_restoration_bh_handler", {})
		end
	else
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Off", caster)
		StopSoundEvent("Hero_WitchDoctor.Voodoo_Restoration.Loop", caster)
		caster:RemoveModifierByName("modifier_witch_doctor_voodoo_restoration_bh_handler")
		caster:RemoveModifierByName("modifier_witch_doctor_voodoo_restoration_curse_bh_handler")
	end
end

modifier_witch_doctor_voodoo_restoration_bh_handler = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_witch_doctor_voodoo_restoration_bh_handler", "heroes/hero_witch_doctor/witch_doctor_voodoo_restoration_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_voodoo_restoration_bh_handler:OnCreated()
	self.interval = self:GetAbility():GetTalentSpecialValueFor("tick_interval")
	self.manaCost = self:GetAbility():GetTalentSpecialValueFor("mana_per_second") * self.interval
	self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
	
	if IsServer() then
		local mainParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(mainParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(mainParticle, 1, Vector( self.radius, self.radius, self.radius ) )
			ParticleManager:SetParticleControlEnt(mainParticle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(mainParticle)
		self:StartIntervalThink( self.interval )
	end
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if caster:GetMana() >= self.manaCost then
		caster:SpendMana(self.manaCost, ability)
		self:SetStackCount( #caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) )
	else
		ability:ToggleAbility()
	end
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:IsAura()
	return true
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:IsAuraActiveOnDeath()
	return false
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:GetAuraRadius()
	return self.radius
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:GetModifierAura()
	return "modifier_witch_doctor_voodoo_restoration_bh_heal"
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:GetAuraDuration()
	return 0.5
end

function modifier_witch_doctor_voodoo_restoration_bh_handler:IsHidden()
	return true
end

modifier_witch_doctor_voodoo_restoration_bh_heal = class({})
LinkLuaModifier("modifier_witch_doctor_voodoo_restoration_bh_heal", "heroes/hero_witch_doctor/witch_doctor_voodoo_restoration_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_voodoo_restoration_bh_heal:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink( self.interval )
	end
end

function modifier_witch_doctor_voodoo_restoration_bh_heal:OnRefresh()
	self.interval = self:GetAbility():GetTalentSpecialValueFor("tick_interval")
	self.heal = ( self:GetAbility():GetTalentSpecialValueFor("heal") ) * self.interval
	self.bonusHeal = self.heal * self:GetAbility():GetTalentSpecialValueFor("bonus_damage") / 100
	if IsServer() then
		self.modifier = self:GetCaster():FindModifierByName("modifier_witch_doctor_voodoo_restoration_bh_handler")
		self.lastUnitCount = math.max(self.modifier:GetStackCount(), 1)
	end
end

function modifier_witch_doctor_voodoo_restoration_bh_heal:OnIntervalThink()
	local heal = self.heal + self.bonusHeal / self.lastUnitCount
	if not self.modifier:IsNull() then
		self.lastUnitCount = math.max(self.modifier:GetStackCount(), 1)
	elseif self:GetCaster():FindModifierByName("modifier_witch_doctor_voodoo_restoration_bh_handler") then
		self:Destroy()
	end
	self:GetParent():HealEvent(heal, self:GetAbility(), self:GetCaster())
end

function modifier_witch_doctor_voodoo_restoration_bh_heal:IsBuff()
	return true
end


modifier_witch_doctor_voodoo_restoration_curse_bh_handler = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_witch_doctor_voodoo_restoration_curse_bh_handler", "heroes/hero_witch_doctor/witch_doctor_voodoo_restoration_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:OnCreated()
	self.interval = self:GetAbility():GetTalentSpecialValueFor("tick_interval")
	self.manaCost = self:GetAbility():GetTalentSpecialValueFor("mana_per_second") * self.interval
	self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
	
	if IsServer() then
		local mainParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_curse.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(mainParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(mainParticle, 1, Vector( self.radius, self.radius, self.radius ) )
			ParticleManager:SetParticleControlEnt(mainParticle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(mainParticle)
		self:StartIntervalThink( self.interval )
	end
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not caster:HasModifier("modifier_modifier_witch_doctor_voodoo_restoration_bh_handler") then
		if caster:GetMana() >= self.manaCost then
			caster:SpendMana(self.manaCost, ability)
			self:SetStackCount( #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) )
		else
			ability:ToggleAbility()
		end
	end
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:IsAura()
	return true
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:IsAuraActiveOnDeath()
	return false
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:GetAuraRadius()
	return self.radius
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:GetModifierAura()
	return "modifier_witch_doctor_voodoo_restoration_bh_curse"
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:GetAuraDuration()
	return 0.5
end

function modifier_witch_doctor_voodoo_restoration_curse_bh_handler:IsHidden()
	return true
end

modifier_witch_doctor_voodoo_restoration_bh_curse = class({})
LinkLuaModifier("modifier_witch_doctor_voodoo_restoration_bh_curse", "heroes/hero_witch_doctor/witch_doctor_voodoo_restoration_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_voodoo_restoration_bh_curse:OnCreated()
	self:OnRefresh()
	self.talentBonusDMG = 0
	self.bonusManaCost = 0
	if IsServer() then
		self:StartIntervalThink( self.interval )
	end
end

function modifier_witch_doctor_voodoo_restoration_bh_curse:OnRefresh()
	self.interval = self:GetAbility():GetTalentSpecialValueFor("tick_interval")
	self.damage = ( self:GetAbility():GetTalentSpecialValueFor("damage") ) * self.interval
	self.bonusDamage = self.damage * self:GetAbility():GetTalentSpecialValueFor("bonus_damage") / 100
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_witch_doctor_voodoo_restoration_2")
	self.talentDmg = self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_voodoo_restoration_2")
	self.talentManaCost = self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_voodoo_restoration_2", "cost")
	if IsServer() then
		self.modifier = self:GetCaster():FindModifierByName("modifier_witch_doctor_voodoo_restoration_curse_bh_handler")
		self.lastUnitCount = math.max(self.modifier:GetStackCount(), 1)
	end
end

function modifier_witch_doctor_voodoo_restoration_bh_curse:OnIntervalThink()
	local damage = self.damage + self.bonusDamage / self.lastUnitCount
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	-- if self.talent2 then
		-- self.talentBonusDMG = self.talentBonusDMG + self.talentDmg * self.interval
		-- damage = damage + self.talentBonusDMG
		-- if self.bonusManaCost > 0 then
			-- self.bonusManaCost = 0
			-- caster:SpendMana(self.bonusManaCost, ability)
		-- else
			-- self.bonusManaCost = self.bonusManaCost + self.talentManaCost * self.interval
		-- end
	-- end
	if not self.modifier:IsNull() then
		self.lastUnitCount = math.max(self.modifier:GetStackCount(), 1)
	elseif caster:FindModifierByName("modifier_witch_doctor_voodoo_restoration_curse_bh_handler") then -- if aura has been retoggled; recreate buff
		self:Destroy()
	end
	ability:DealDamage( caster, self:GetParent(), damage, {damage_type = DAMAGE_TYPE_MAGICAL} )
end

function modifier_witch_doctor_voodoo_restoration_bh_curse:IsDebuff()
	return true
end