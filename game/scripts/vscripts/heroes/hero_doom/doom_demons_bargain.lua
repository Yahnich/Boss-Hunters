doom_demons_bargain = class({})

function doom_demons_bargain:IsStealable()
	return true
end

function doom_demons_bargain:IsHiddenWhenStolen()
	return false
end

function doom_demons_bargain:OnAbilityPhaseStart()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	EmitSoundOn("Hero_DoomBringer.DevourCast", self.caster)
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour_beam.vpcf", PATTACH_POINT_FOLLOW, self.target, self.caster)
	return true
end

function doom_demons_bargain:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_DoomBringer.DevourCast", self.caster)
end

function doom_demons_bargain:OnSpellStart()
    local gold = self:GetSpecialValueFor("total_gold")
    local duration = self:GetSpecialValueFor("duration")
	local damage = gold * TernaryOperator( self:GetSpecialValueFor("dmg_mult_minion"), self.target:IsMinion(), self:GetSpecialValueFor("dmg_mult") )
	ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_POINT_FOLLOW, self.target)
	EmitSoundOn("Hero_DoomBringer.Devour", self.target)
	if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end
    self.caster:AddGold(gold)
	
	self.target:AddNewModifier(self.caster, self, "modifier_doom_demons_bargain_devour_target", {duration = duration})
	self.caster:AddNewModifier(self.caster, self, "modifier_doom_demons_bargain_devour", {duration = duration})
	-- if self.caster:HasTalent("special_bonus_unique_doom_demons_bargain_1") then
		-- local reduction = self.caster:FindTalentValue("special_bonus_unique_doom_demons_bargain_1")
		-- for i = 0, self.caster:GetAbilityCount() - 1 do
			-- local ability = self.caster:GetAbilityByIndex( i )
			-- if ability and ability ~= self then
				-- ability:ModifyCooldown(reduction)
			-- end
		-- end
	-- end
	Timers:CreateTimer( function() self:DealDamage( self.caster, self.target, damage ) end )
	if self.caster:HasTalent("special_bonus_unique_doom_demons_bargain_4") then
		self.caster:ModifyThreat( gold * self.caster:FindTalentValue("special_bonus_unique_doom_demons_bargain_4") / 100 )
	end
end

modifier_doom_demons_bargain_devour_target = class({})
LinkLuaModifier("modifier_doom_demons_bargain_devour_target", "heroes/hero_doom/doom_demons_bargain", LUA_MODIFIER_MOTION_NONE	)

function modifier_doom_demons_bargain_devour_target:OnCreated()
	self:GetAbility().demonsBargainLastUnitTargeted = self:GetParent()
end

function modifier_doom_demons_bargain_devour_target:OnDestroy()
	if IsServer() then
		local devour = self:GetCaster():FindModifierByName("modifier_doom_demons_bargain_devour")
		if devour then
			devour:SetStackCount( self:GetSpecialValueFor("hp_regen_mult") )
		end
	end
end

modifier_doom_demons_bargain_devour = class({})
LinkLuaModifier("modifier_doom_demons_bargain_devour", "heroes/hero_doom/doom_demons_bargain", LUA_MODIFIER_MOTION_NONE	)

function modifier_doom_demons_bargain_devour:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:SetStackCount( 1 )
		if self.talent3 then
			local nfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_bringer_demons_bargain_damage.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
			ParticleManager:SetParticleControlEnt(nfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(nfx, 25, Vector(0,255,255))
			self:AddEffect( nfx )
		end
		if self.talent4 then
			self:GetParent():HookInModifier( "GetModifierDamageReflectBonus", self )
			local nfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_bringer_demons_bargain_thorns.vpcf.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
			self:AddEffect( nfx )
		end
		local mainFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_ready.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt(mainFx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_mouth", self:GetCaster():GetAbsOrigin(), true)
		self:AddEffect( mainFx )
	end
end

function modifier_doom_demons_bargain_devour:OnRefresh()
	self.hp_regen = self:GetSpecialValueFor("regen")
	self.hp_regen_mult = self:GetSpecialValueFor("hp_regen_mult")
	self.talent3 = self:GetCaster():HasTalent("special_bonus_unique_doom_demons_bargain_3")
	self.talent3Value = self.hp_regen * self:GetCaster():FindTalentValue("special_bonus_unique_doom_demons_bargain_3")
	self.talent4 = self:GetCaster():HasTalent("special_bonus_unique_doom_demons_bargain_4")
	self.talent4Value = self.hp_regen * self:GetCaster():FindTalentValue("special_bonus_unique_doom_demons_bargain_4", "value2")
	if self.talent4 then
		self:GetParent():HookInModifier( "GetModifierDamageReflectBonus", self )
	end
end

function modifier_doom_demons_bargain_devour:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_doom_demons_bargain_devour:GetModifierConstantHealthRegen()
	return self.hp_regen * self:GetStackCount()
end

function modifier_doom_demons_bargain_devour:GetModifierPreAttack_BonusDamage()
	if self.talent3 then return self.talent3Value * self:GetStackCount() end
end

function modifier_doom_demons_bargain_devour:GetModifierAttackSpeedBonus_Constant()
	if self.talent3 then return self.talent3Value * self:GetStackCount() end
end

function modifier_doom_demons_bargain_devour:GetModifierDamageReflectBonus()
	if self.talent4 then return self.talent4Value * self:GetStackCount() end
end