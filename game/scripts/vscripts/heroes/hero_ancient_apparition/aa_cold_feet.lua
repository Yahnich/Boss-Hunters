aa_cold_feet = class({})
LinkLuaModifier("modifier_aa_cold_feet", "heroes/hero_ancient_apparition/aa_cold_feet", LUA_MODIFIER_MOTION_NONE)

function aa_cold_feet:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Ancient_Apparition.ColdFeetCast", caster)
	
	target:AddNewModifier(caster, self, "modifier_aa_cold_feet", {Duration = self:GetSpecialValueFor("duration")})

	if caster:HasTalent("special_bonus_unique_aa_cold_feet_1") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_aa_cold_feet_1"))
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:AddNewModifier(caster, self, "modifier_aa_cold_feet", {Duration = self:GetSpecialValueFor("duration")})
			end
		end
	end
end


modifier_aa_cold_feet = class({})
function modifier_aa_cold_feet:OnCreated(table)
	if IsServer() then self:StartIntervalThink(FrameTime())	end
end

function modifier_aa_cold_feet:OnRefresh(table)
	if IsServer() then self:StartIntervalThink(FrameTime())	end
end

function modifier_aa_cold_feet:OnIntervalThink()
	EmitSoundOn("Hero_Ancient_Apparition.ColdFeetTick", self:GetParent())
	local damage = self:GetSpecialValueFor("damage")
	if self:GetCaster():HasTalent("special_bonus_unique_aa_cold_feet_2") and ( self:GetParent():IsChilled() or self:GetParent():IsFrozenGeneric() ) then
		damage = damage * self:GetCaster():FindTalentValue("special_bonus_unique_aa_cold_feet_2")
	end
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage)
	self:StartIntervalThink(1)
end

function modifier_aa_cold_feet:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_Ancient_Apparition.ColdFeetFreeze", self:GetParent())
		self:GetParent():Freeze(self:GetAbility(), self:GetCaster(), self:GetSpecialValueFor("stun_duration"))
	end
end

function modifier_aa_cold_feet:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet.vpcf"
end

function modifier_aa_cold_feet:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end