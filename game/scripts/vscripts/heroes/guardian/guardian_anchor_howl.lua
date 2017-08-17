guardian_anchor_howl = class({})

function guardian_anchor_howl:OnSpellStart()
	local caster = self:GetCaster()
	local targets = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("taunt_radius"), {})
	EmitSoundOn("Hero_Axe.Berserkers_Call", caster)
	local anchorFX = ParticleManager:FireParticle("particles/heroes/guardian/guardian_anchor_howl.vpcf", PATTACH_POINT_FOLLOW, caster, nil)
	local tDuration = self:GetSpecialValueFor("taunt_duration")
	for _, target in ipairs(targets) do
		target:AddNewModifier(caster, self, "modifier_guardian_anchor_howl_taunt", {duration = tDuration})
		target:AddNewModifier(caster, self, "modifier_guardian_anchor_howl_break_effect", {duration = tDuration + self:GetSpecialValueFor("break_duration")})
	end
	if #targets > 0 then self:StartDelayedCooldown(tDuration, true) end
	if caster:HasTalent("guardian_anchor_howl_talent_1") then
		caster:AddNewModifier(caster, self, "modifier_guardian_anchor_howl_talent", {duration = caster:FindTalentValue("guardian_anchor_howl_talent_1")})
	end
end

modifier_guardian_anchor_howl_taunt = class({})
LinkLuaModifier("modifier_guardian_anchor_howl_taunt", "heroes/guardian/guardian_anchor_howl.lua", 0)

function modifier_guardian_anchor_howl_taunt:GetTauntTarget()
	return self:GetCaster()
end

function modifier_guardian_anchor_howl_taunt:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_guardian_anchor_howl_taunt:StatusEffectPriority()
	return 10
end


modifier_guardian_anchor_howl_break_effect = class({})
LinkLuaModifier("modifier_guardian_anchor_howl_break_effect", "heroes/guardian/guardian_anchor_howl.lua", 0)

function modifier_guardian_anchor_howl_break_effect:OnCreated()
	self.damage = self:GetAbility():GetTalentSpecialValueFor("break_damage")
	if IsServer() then
		self.anchorFX = ParticleManager:CreateParticle("particles/heroes/guardian/guardian_anchor_howl_link.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.anchorFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.anchorFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(self.anchorFX)
	
		self:StartIntervalThink(0.1) 
	end
end

function modifier_guardian_anchor_howl_break_effect:OnRefresh()
	self:Break()
	self.damage = self:GetAbility():GetTalentSpecialValueFor("break_damage")
end

function modifier_guardian_anchor_howl_break_effect:Break()
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
		ParticleManager:FireParticle("particles/econ/events/ti7/hero_levelup_ti7.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), nil)
	end
end

function modifier_guardian_anchor_howl_break_effect:OnDestroy()
	self:Break()
	if IsServer() then
		ParticleManager:DestroyParticle(self.anchorFX, true)
		ParticleManager:ReleaseParticleIndex(self.anchorFX)
	end
end

function modifier_guardian_anchor_howl_break_effect:DeclareFunctions()
	funcs = { MODIFIER_EVENT_ON_TAKEDAMAGE,
			}
	return funcs
end

function modifier_guardian_anchor_howl_break_effect:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetCaster() then
		self:Destroy()
	end
end


modifier_guardian_anchor_howl_talent = class({})
LinkLuaModifier("modifier_guardian_anchor_howl_talent", "heroes/guardian/guardian_anchor_howl.lua", 0)

function modifier_guardian_anchor_howl_talent:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("talent_bonus_armor")
end

function modifier_guardian_anchor_howl_talent:OnRefresh()
	self.armor = self:GetAbility():GetSpecialValueFor("talent_bonus_armor")
end

function modifier_guardian_anchor_howl_talent:DeclareFunctions()
	funcs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			}
	return funcs
end

function modifier_guardian_anchor_howl_talent:GetModifierPhysicalArmorBonus()
	return self.armor
end