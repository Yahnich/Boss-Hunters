boss3b_acid_spit = class({})

function boss3b_acid_spit:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCursorPosition() , self:GetSpecialValueFor("radius") )
	self.fireFX = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray_cast.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.fireFX, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.fireFX, 1, self:GetCursorPosition() )
	ParticleManager:SetParticleControl(self.fireFX, 15, Vector(28, 120, 28) )
	ParticleManager:SetParticleControl(self.fireFX, 16, Vector(1, 0, 0) )
	return true
end

function boss3b_acid_spit:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle(self.fireFX, false)
	ParticleManager:ReleaseParticleIndex(self.fireFX)
end

function boss3b_acid_spit:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local ability = self
	
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("dot")
	local duration = self:GetSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Alchemist.AcidSpray", caster)
	
	local acidFX = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(acidFX, 0, position)
	ParticleManager:SetParticleControl(acidFX, 1, Vector(radius, 1, 1) )
	ParticleManager:SetParticleControl(acidFX, 15, Vector(0, 200, 0) )
	ParticleManager:SetParticleControl(acidFX, 16, Vector(radius, 0, 0) )
	
	Timers:CreateTimer(function()
		if not caster or caster:IsNull() or not ability or ability:IsNull() then
			ParticleManager:ClearParticle(acidFX)
		end
		local enemies = caster:FindEnemyUnitsInRadius(position, radius)
		for _, enemy in ipairs(enemies) do
			ability:DealDamage(caster, enemy, damage)
			enemy:AddNewModifier(caster, ability, "modifier_boss3b_acid_spit", {duration = 1.5})
			EmitSoundOn("Hero_Alchemist.AcidSpray.Damage", enemy)
		end
		if duration > 0 then
			duration = duration - 1
			return 1
		else
			ParticleManager:DestroyParticle(acidFX, false)
			ParticleManager:ReleaseParticleIndex(acidFX)
		end
	end)
end

modifier_boss3b_acid_spit = class({})
LinkLuaModifier("modifier_boss3b_acid_spit", "bosses/boss3b/boss3b_acid_spit.lua", 0)

function modifier_boss3b_acid_spit:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_reduction")
end


function modifier_boss3b_acid_spit:OnRefresh()
	self.armor = self:GetSpecialValueFor("armor_reduction")
end

function modifier_boss3b_acid_spit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss3b_acid_spit:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_boss3b_acid_spit:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
end