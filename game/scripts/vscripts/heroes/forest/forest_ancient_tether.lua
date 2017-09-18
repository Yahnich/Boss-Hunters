forest_ancient_tether = class({})

function forest_ancient_tether:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if caster ~= target then
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber())
	else
		return UF_FAIL_CUSTOM
	end
end

function forest_ancient_tether:GetCustomCastErrorTarget(target)
	return "Skill cannot target caster"
end

function forest_ancient_tether:OnSpellStart()
	local caster =  self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Treant.SpellFoley", target)
	
	target:AddNewModifier(caster, self, "modifier_forest_ancient_tether_buff", {duration = self:GetSpecialValueFor("duration")})
end


modifier_forest_ancient_tether_buff = class({})
LinkLuaModifier("modifier_forest_ancient_tether_buff", "heroes/forest/forest_ancient_tether.lua", 0)

function modifier_forest_ancient_tether_buff:OnCreated()
	self.regen = self:GetSpecialValueFor("ally_regen") / 100
	self.eqRate = self:GetSpecialValueFor("equalize_rate")
	
	self.talent = self:GetSpecialValueFor("talent_damage_reduction")
	self.breakrange = self:GetSpecialValueFor("break_buffer")
	
	if IsServer() then 
		self:StartIntervalThink(0.3)
		local linkFX = ParticleManager:CreateParticle("particles/heroes/forest/forest_ancient_tether.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(linkFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(linkFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(linkFX)
	end
end

function modifier_forest_ancient_tether_buff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if not parent:IsAlive() then self:Destroy() end
	if CalculateDistance(parent, caster) > self:GetAbility():GetTrueCastRange() + self.breakrange then self:Destroy() end
	local hpDiff = parent:GetHealthPercent() - caster:GetHealthPercent()
	if hpDiff < 0 then -- caster has more hp
		print("healing parent", hpDiff, self.eqRate)
		local heal = (caster:GetMaxHealth() * math.min( math.abs(hpDiff), self.eqRate ) / 100) * 0.3
		caster:SetHealth( caster:GetHealth() - heal )
		parent:HealEvent(heal, self:GetAbility(), caster)
	elseif hpDiff > 0 then -- parent has more hp
		print("healing caster", hpDiff, self.eqRate)
		local heal = (parent:GetMaxHealth() * math.min( math.abs(hpDiff), self.eqRate ) / 100) * 0.3
		parent:SetHealth( parent:GetHealth() - heal )
		caster:HealEvent(heal, self:GetAbility(), caster)
	end
	parent:HealEvent(caster:GetHealthRegen() * self.regen)
end

function modifier_forest_ancient_tether_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_forest_ancient_tether_buff:GetModifierIncomingDamage_Percentage()
	return self.talent
end