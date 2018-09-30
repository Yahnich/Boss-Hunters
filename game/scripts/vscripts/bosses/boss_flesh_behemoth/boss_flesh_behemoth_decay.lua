boss_flesh_behemoth_decay = class({})

function boss_flesh_behemoth_decay:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_flesh_behemoth_decay:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,radius,radius)})
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		if not enemy:TriggerSpellReflect( self ) then
			caster:Lifesteal(self, 100, damage, enemy, damage_type, 2, true)
			enemy:AddNewModifier( caster, self, "modifier_boss_flesh_behemoth_decay_debuff", {duration = duration})
			local hpPct = caster:GetHealth() / caster:GetMaxHealth()
			caster:AddNewModifier( caster, self, "modifier_boss_flesh_behemoth_decay_buff", {duration = duration})
			caster:SetHealth( hpPct * caster:GetMaxHealth() )
		end
	end
end

modifier_boss_flesh_behemoth_decay_debuff = class({})
LinkLuaModifier("modifier_boss_flesh_behemoth_decay_debuff", "bosses/boss_flesh_behemoth/boss_flesh_behemoth_decay", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_flesh_behemoth_decay_debuff:OnCreated()
	self.loss = self:GetSpecialValueFor("str_loss")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_boss_flesh_behemoth_decay_debuff:OnRefresh()
	self.loss = self:GetSpecialValueFor("str_loss")
	if IsServer() then
		self:AddIndependentStack()
	end
end

function modifier_boss_flesh_behemoth_decay_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_boss_flesh_behemoth_decay_debuff:GetModifierBonusStats_Strength()
	return self.loss * self:GetStackCount() * (-1)
end


modifier_boss_flesh_behemoth_decay_buff = class({})
LinkLuaModifier("modifier_boss_flesh_behemoth_decay_buff", "bosses/boss_flesh_behemoth/boss_flesh_behemoth_decay", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_flesh_behemoth_decay_buff:OnCreated()
	self.loss = self:GetSpecialValueFor("str_loss") * 20
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_boss_flesh_behemoth_decay_buff:OnRefresh()
	self.loss = self:GetSpecialValueFor("str_loss") * 20
	if IsServer() then
		self:AddIndependentStack()
	end
end

function modifier_boss_flesh_behemoth_decay_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
end

function modifier_boss_flesh_behemoth_decay_buff:GetModifierExtraHealthBonus()
	return self.loss * self:GetStackCount()
end