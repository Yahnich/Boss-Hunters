pudge_chain_storm = class({})
LinkLuaModifier( "modifier_pudge_chain_storm", "heroes/hero_pudge/pudge_chain_storm.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_pudge_flesh_heap_lua_effect", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)

function pudge_chain_storm:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Pudge.Dismember.Cast.Arcana", caster)
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier(caster, self, "modifier_pudge_chain_storm", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_pudge_chain_storm = class({})

function modifier_pudge_chain_storm:OnCreated(table)
	self:OnRefresh()
	if IsServer() then
		local nfx1 = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/default/pudge_arcana_dismember_ground_default.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		local nfx2 = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/default/pudge_arcana_dismember_bloom_default.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		self:AddEffect( nfx1 )
		self:AddEffect( nfx2 )
		self:StartIntervalThink( 1 )
	end
end

function modifier_pudge_chain_storm:OnRefresh()
	self.mr = self:GetTalentSpecialValueFor("magic_resist")
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.stacks = self:GetTalentSpecialValueFor("heap_stacks")
		self.heap_chance = self:GetTalentSpecialValueFor("heap_chance")
		self.minion_chance = self:GetTalentSpecialValueFor("minion_chance")
		self.max = self:GetTalentSpecialValueFor("max_resist") / self.mr
		self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_pudge_chain_storm_1")
		self.talent1Timer = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_chain_storm_1")
		self.talent1Radius = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_chain_storm_1", "radius")
		self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_pudge_chain_storm_2")
		self.talent2Heal = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_chain_storm_2") / 100
	end
end

function modifier_pudge_chain_storm:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		EmitSoundOn("Hero_Pudge.Dismember.Damage.Arcana", parent)
		EmitSoundOn("Hero_Pudge.Dismember.Gore.Arcana", parent)
		local fleshheap = caster:FindAbilityByName("pudge_flesh_heap_lua")
		local chance = TernaryOperator( self.minion_chance, parent:IsMinion(), self.heap_chance )
		if self:RollPRNG( chance ) and fleshheap then
			fleshheap:AddSkinHeap(self.stacks)
		end
		if self:GetStackCount() < self.max then
			self:IncrementStackCount()
		end
		
		ParticleManager:FireParticle("particles/econ/items/pudge/pudge_arcana/default/pudge_arcana_dismember_soil_a_default.vpcf", PATTACH_WORLDORIGIN, parent, {[0] = parent:GetAbsOrigin() + RandomVector(128),
																																								 [1] = parent:GetAbsOrigin()})
		ParticleManager:FireParticle("particles/econ/items/pudge/pudge_arcana/default/pudge_arcana_dismember_soil_b_default.vpcf", PATTACH_WORLDORIGIN, parent, {[0] = parent:GetAbsOrigin() + RandomVector(128),
																																								 [1] = parent:GetAbsOrigin()})
		
		local damage = self:GetAbility():DealDamage(caster, parent, self.damage)
		if self.talent2 then
			caster:HealEvent( damage * self.talent2Heal, self:GetAbility(), caster )
		end
		if self.talent1 and not self.talent1Triggered then
			if self.talent1Timer <= 0 then
				self.talent1Timer = caster:FindTalentValue("special_bonus_unique_pudge_chain_storm_1")
				for _, target in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 600 or self.talent1Radius ) ) do
					if not target:HasModifier("modifier_pudge_chain_storm") then
						if target:TriggerSpellAbsorb( self ) then return end
						local modifier = target:AddNewModifier(caster, self:GetAbility(), "modifier_pudge_chain_storm", {Duration = self:GetRemainingTime()-0.01})
						modifier:SetDuration(self:GetRemainingTime()-0.01,true)
						self.talent1Triggered = true
						break
					end
				end
			end
			self.talent1Timer = self.talent1Timer - 1
		end
	end
end

function modifier_pudge_chain_storm:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		StopSoundOn("Hero_Pudge.Dismember.Damage.Arcana", parent)
		StopSoundOn("Hero_Pudge.Dismember.Gore.Arcana", parent)
		StopSoundOn("Hero_Pudge.Dismember.Arcana", parent)
		ParticleManager:ClearParticle(self.nfx)
		if self:GetRemainingTime() > 0 then
			for _, target in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self:GetAbility():GetTrueCastRange() ) ) do
				if not target:HasModifier("modifier_pudge_chain_storm") then
					if target:TriggerSpellAbsorb( self ) then return end
					local modifier = target:AddNewModifier(caster, self:GetAbility(), "modifier_pudge_chain_storm", {Duration = self:GetRemainingTime()-0.01})
					modifier:SetDuration(self:GetRemainingTime()-0.01,true)
					break
				end
			end
		end
	end
end

function modifier_pudge_chain_storm:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_pudge_chain_storm:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_pudge_chain_storm:GetModifierMagicalResistanceBonus()
	return self.mr * self:GetStackCount() * (-1)
end

function modifier_pudge_chain_storm:IsDebuff()
	return true
end