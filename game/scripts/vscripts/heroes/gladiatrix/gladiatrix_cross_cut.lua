gladiatrix_cross_cut = class({})

function gladiatrix_cross_cut:OnSpellStart()
	local caster = self:GetCaster()
	local targetPoint = self:GetCaster():GetAbsOrigin() 
	local radius = self:GetTalentSpecialValueFor("area_of_effect")
	if not caster:HasTalent("gladiatrix_cross_cut_talent_1") then targetPoint = targetPoint + self:GetCaster():GetForwardVector() * radius end
	
	local enemies = caster:FindEnemyUnitsInRadius(targetPoint, radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
	for _, enemy in pairs(enemies) do
		caster:PerformAttack(enemy, true, true, true, false, false, true, true)
		local damage = self:GetTalentSpecialValueFor("damage")
		caster:Lifesteal(self, self:GetTalentSpecialValueFor("lifesteal"), damage, enemy, self:GetAbilityDamageType(), DOTA_LIFESTEAL_SOURCE_ABILITY)
		enemy:AddNewModifier(caster, self, "modifier_gladiatrix_cross_cut_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
		local cut = ParticleManager:CreateParticle("particles/heroes/gladiatrix/gladiatrix_cross_cut.vpcf", PATTACH_POINT_FOLLOW, enemy)
		ParticleManager:ReleaseParticleIndex(cut)
	end
	if #enemies > 0 then
		EmitSoundOn("Hero_LegionCommander.Courage", caster)
	else
		local cut = ParticleManager:CreateParticle("particles/heroes/gladiatrix/gladiatrix_cross_cut.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(cut, 0, targetPoint)
		ParticleManager:ReleaseParticleIndex(cut)
	end
end

LinkLuaModifier("modifier_gladiatrix_cross_cut_debuff", "heroes/gladiatrix/gladiatrix_cross_cut.lua", 0)

modifier_gladiatrix_cross_cut_debuff = class({})

function modifier_gladiatrix_cross_cut_debuff:OnCreated()
	self.reduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction")
end

function modifier_gladiatrix_cross_cut_debuff:OnRefresh()
	self.reduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction")
end

function modifier_gladiatrix_cross_cut_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			}
	return funcs
end

function modifier_gladiatrix_cross_cut_debuff:GetModifierTotalDamageOutgoing_Percentage()
	return self.reduction
end

function modifier_gladiatrix_cross_cut_debuff:GetEffectName()
	return "particles/heroes/gladiatrix/gladiatrix_cross_cut_debuff.vpcf"
end