pudge_chain_storm = class({})
LinkLuaModifier( "modifier_pudge_chain_storm", "heroes/hero_pudge/pudge_chain_storm.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_pudge_flesh_heap_lua_effect", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)

function pudge_chain_storm:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Pudge.Dismember.Cast.Arcana", caster)
	target:AddNewModifier(caster, self, "modifier_pudge_chain_storm", {Duration = self:GetTalentSpecialValueFor("duration")})
	if self:GetCaster():HasTalent("special_bonus_unique_pudge_chain_storm_1") then
		target:AddNewModifier(caster, self, "modifier_pudge_chain_storm_talent", {Duration = caster:FindTalentValue("special_bonus_unique_pudge_chain_storm_1", "duration")})
	end
end

modifier_pudge_chain_storm = class({})

function modifier_pudge_chain_storm:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/pudge_arcana_dismember_default.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 2, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 3, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 4, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 8, Vector(2,2,2))
		ParticleManager:SetParticleControl(self.nfx, 15, Vector(142, 2, 2))
		self:StartIntervalThink( 0.5 )
	end
end

function modifier_pudge_chain_storm:OnIntervalThink()
	if IsServer() then
		EmitSoundOn("Hero_Pudge.Dismember.Damage.Arcana", self:GetParent())
		EmitSoundOn("Hero_Pudge.Dismember.Gore.Arcana", self:GetParent())
		EmitSoundOn("Hero_Pudge.Dismember.Arcana", self:GetParent())
		local caster = self:GetCaster()
		if caster:HasTalent("special_bonus_unique_pudge_chain_storm_2") then
			local fleshheap = caster:FindAbilityByName("pudge_flesh_heap_lua")
			caster:AddNewModifier(caster, fleshheap, "modifier_pudge_flesh_heap_lua_effect", {Duration = fleshheap:GetTalentSpecialValueFor("duration")}):AddIndependentStack(fleshheap:GetTalentSpecialValueFor("duration"))
		end

		self:GetAbility():DealDamage(caster, self:GetParent(), caster:GetAttackDamage() * self:GetTalentSpecialValueFor("damage") / 100, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
	end
end

function modifier_pudge_chain_storm:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_pudge_chain_storm:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Pudge.Dismember.Damage.Arcana", self:GetParent())
		StopSoundOn("Hero_Pudge.Dismember.Gore.Arcana", self:GetParent())
		StopSoundOn("Hero_Pudge.Dismember.Arcana", self:GetParent())
		ParticleManager:ClearParticle(self.nfx)
	end
end

function modifier_pudge_chain_storm:IsDebuff()
	return true
end

modifier_pudge_chain_storm_talent = class({})
LinkLuaModifier("modifier_pudge_chain_storm_talent", "heroes/hero_pudge/pudge_chain_storm", LUA_MODIFIER_MOTION_NONE)

function modifier_pudge_chain_storm_talent:OnCreated()
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_chain_storm_1")
end

function modifier_pudge_chain_storm_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_pudge_chain_storm_talent:GetModifierMagicalResistanceBonus()
	return self.mr
end