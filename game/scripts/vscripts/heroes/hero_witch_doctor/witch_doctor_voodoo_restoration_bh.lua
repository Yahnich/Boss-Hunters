witch_doctor_voodoo_restoration_ebf = class({})

function witch_doctor_voodoo_restoration_ebf:GetCastRange()
	return self:GetTalentSpecialValueFor("radius")
end

LinkLuaModifier("witch_doctor_voodoo_restoration_ebf_handler", "heroes/hero_witch_doctor/witch_doctor_voodoo_restoration", LUA_MODIFIER_MOTION_NONE)
function witch_doctor_voodoo_restoration_ebf:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration", self:GetCaster())
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Loop", self:GetCaster())
		caster:AddNewModifier(caster, self, "witch_doctor_voodoo_restoration_ebf_handler", {})
		if caster:HasTalent("special_bonus_unique_witch_doctor_voodoo_restoration_2") then
			local radius = self:GetTalentSpecialValueFor("radius")
			for _, unit in ipairs( caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
				unit:Dispel( caster, true )
			end
		end
	else
		EmitSoundOn("Hero_WitchDoctor.Voodoo_Restoration.Off", caster)
		StopSoundEvent("Hero_WitchDoctor.Voodoo_Restoration.Loop", caster)
		caster:RemoveModifierByName("witch_doctor_voodoo_restoration_ebf_handler")
	end
end

witch_doctor_voodoo_restoration_ebf_handler = class({})

function witch_doctor_voodoo_restoration_ebf_handler:OnCreated()
	self.interval = self:GetAbility():GetTalentSpecialValueFor("heal_interval")
	self.manaCost = self:GetAbility():GetTalentSpecialValueFor("mana_per_second") * self.interval
	self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
	
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_witch_doctor_voodoo_restoration_1")
	if self.talent then
		self.talentInterval = self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_voodoo_restoration_1", "interval")
		self.talentDelay = self.talentInterval
		self.talentHeal = self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_voodoo_restoration_1") / 100
	end
	local mainParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(mainParticle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(mainParticle, 1, Vector( self.radius, self.radius, self.radius ) )
			ParticleManager:SetParticleControlEnt(mainParticle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_staff", self:GetParent():GetAbsOrigin(), true)
	self:AddEffect(mainParticle)
	if IsServer() then
		self:StartIntervalThink( self.interval )
	end
end

function witch_doctor_voodoo_restoration_ebf_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if caster:GetMana() >= ability:GetManaCost(-1) then
		caster:SpendMana(self.manaCost, ability)
		if self.talent then
			self.talentDelay = self.talentDelay - self.interval
			if self.talentDelay <= 0 then
				self.talentDelay = self.talentInterval
				for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
					EmitSoundOn("Hero_WitchDoctor.Attack", ally)
					ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack_explosion.vpcf", PATTACH_POINT_FOLLOW, ally)
					ally:HealEvent(ally:GetMaxHealth()*self.talentHeal, ability, caster)
				end
			end
		end
	else
		ability:ToggleAbility()
	end
end

function witch_doctor_voodoo_restoration_ebf_handler:IsAura()
	return true
end

function witch_doctor_voodoo_restoration_ebf_handler:IsAuraActiveOnDeath()
	return false
end

function witch_doctor_voodoo_restoration_ebf_handler:GetAuraRadius()
	return self.radius
end

function witch_doctor_voodoo_restoration_ebf_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function witch_doctor_voodoo_restoration_ebf_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function witch_doctor_voodoo_restoration_ebf_handler:GetModifierAura()
	return "witch_doctor_voodoo_restoration_ebf_heal"
end

function witch_doctor_voodoo_restoration_ebf_handler:GetAuraDuration()
	return 0.5
end

function witch_doctor_voodoo_restoration_ebf_handler:IsHidden()
	return true
end

LinkLuaModifier("witch_doctor_voodoo_restoration_ebf_heal", "heroes/hero_witch_doctor/witch_doctor_voodoo_restoration", LUA_MODIFIER_MOTION_NONE)
witch_doctor_voodoo_restoration_ebf_heal = class({})

function witch_doctor_voodoo_restoration_ebf_heal:OnCreated()
	self.interval = self:GetAbility():GetTalentSpecialValueFor("heal_interval")
	self.heal = (self:GetAbility():GetTalentSpecialValueFor("heal") + self:GetCaster():GetIntellect()*self:GetAbility():GetTalentSpecialValueFor("int_to_heal")/100 ) * self.interval
	if IsServer() then
		self:StartIntervalThink( self.interval )
	end
end

function witch_doctor_voodoo_restoration_ebf_heal:OnRefresh()
	self.interval = self:GetAbility():GetTalentSpecialValueFor("heal_interval")
	self.heal = (self:GetAbility():GetTalentSpecialValueFor("heal") + self:GetCaster():GetIntellect()*self:GetAbility():GetTalentSpecialValueFor("int_to_heal")/100 ) * self.interval
end

function witch_doctor_voodoo_restoration_ebf_heal:OnIntervalThink()
	self:GetParent():HealEvent(self.heal, self:GetAbility(), self:GetCaster())
end

function witch_doctor_voodoo_restoration_ebf_heal:IsBuff()
	return true
end