justicar_penitence = class({})

function justicar_penitence:OnSpellStart()
	local caster = self:GetCaster()
	
	local hpToDamage = self:GetTalentSpecialValueFor("hp_to_damage") / 100
	local hpToBarrier = self:GetTalentSpecialValueFor("hp_to_barrier") / 100
	
	local hpDamage = (self:GetTalentSpecialValueFor("hp_damage") / 100) * caster:GetHealth()
	local damage = hpDamage * hpToDamage + self:GetTalentSpecialValueFor("base_damage") 
	
	local penitenceFX = ParticleManager:CreateParticle("particles/heroes/justicar/justicar_penitence.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(penitenceFX)
	
	caster:SetHealth( math.max(1, caster:GetHealth() - hpDamage) )
	
	local targetUnits = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetTalentSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, target in ipairs(targetUnits) do
		if not target:IsSameTeam(caster) then
			self:DealDamage(caster, target, damage + caster:GetInnerSun())
			caster:ResetInnerSun()
		elseif caster ~= target or caster:HasTalent("justicar_penitence_talent_1") then
			target:AddBarrier(hpDamage * hpToBarrier, caster, self, nil)
		end
	end
	EmitSoundOn("Hero_Chen.PenitenceImpact", caster)
	EmitSoundOn("Hero_Chen.PenitenceCast", caster)
	caster:AddNewModifier(caster, self, "modifier_justice_penitence_buff", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_justice_penitence_buff = class({})
LinkLuaModifier("modifier_justice_penitence_buff", "heroes/justicar/justicar_penitence.lua", 0)

function modifier_justice_penitence_buff:OnCreated()
	self.armor = self:GetAbility():GetTalentSpecialValueFor("bonus_armor")
	self.damage = self:GetAbility():GetTalentSpecialValueFor("bonus_damage")
end

function modifier_justice_penitence_buff:OnRefresh()
	self.armor = self:GetAbility():GetTalentSpecialValueFor("bonus_armor")
	self.damage = self:GetAbility():GetTalentSpecialValueFor("bonus_damage")
end

function modifier_justice_penitence_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function modifier_justice_penitence_buff:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_justice_penitence_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end