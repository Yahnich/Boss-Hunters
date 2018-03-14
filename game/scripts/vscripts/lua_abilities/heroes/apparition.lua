LinkLuaModifier("modifier_charges", "lua_abilities/heroes/modifiers/modifier_charges", LUA_MODIFIER_MOTION_NONE)
function ApplyEntropy(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if not target:HasModifier("modifier_entropy_damage_reduction") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_entropy_damage_reduction", {duration = 4})
	else
		target:SetModifierStackCount("modifier_entropy_damage_reduction", caster, target:GetModifierStackCount("modifier_entropy_damage_reduction", caster) + 1)
	end
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetTalentSpecialValueFor("damage"), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function EntropyTalent(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_charges") and caster:HasTalent("special_bonus_unique_ancient_apparition_1") then
		caster:AddNewModifier(caster, ability, "modifier_charges",
        {
            max_count = caster:FindTalentValue("special_bonus_unique_ancient_apparition_1"),
            start_count = caster:FindTalentValue("special_bonus_unique_ancient_apparition_1"),
            replenish_time = ability:GetCooldown(-1)
        })
	end
end


ancient_apparition_ice_blast_ebf = class({})

function ancient_apparition_ice_blast_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local vDir = CalculateDirection(targetPos, caster)
	local vDistance = CalculateDistance(targetPos, caster)
	local speed = self:GetTalentSpecialValueFor("speed")
	local initWidth = self:GetTalentSpecialValueFor("radius_min")
	local endWidth = math.min( initWidth + (vDistance / speed) * self:GetTalentSpecialValueFor("radius_grow"), self:GetTalentSpecialValueFor("radius_max" ) )
	extraData = {}
	extraData["endWidth"] = endWidth
	
	EmitSoundOn("Hero_Ancient_Apparition.IceBlastRelease.Cast", caster)
	
	self:FireLinearProjectile("particles/frostivus_gameplay/holdout_ancient_apparition_ice_blast_final.vpcf", vDir * speed, vDistance, initWidth, {width_end = endWidth, extraData = extraData})
end

function ancient_apparition_ice_blast_ebf:OnProjectileHit_ExtraData(target, position, extraData)
	local caster = self:GetCaster()
	local duration = TernaryOperator(self:GetTalentSpecialValueFor("frostbite_duration_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("frostbite_duration"))
	if target then
		target:AddNewModifier(caster, self, "modifier_ancient_apparition_ice_blast_ebf", {duration = duration})
	else
		EmitSoundOnLocationWithCaster(position, "Hero_Ancient_Apparition.IceBlast.Target", self:GetCaster())
		local targets = caster:FindEnemyUnitsInRadius(position, tonumber(extraData["endWidth"]))
		for _, target in ipairs(targets) do
			target:AddNewModifier(caster, self, "modifier_ancient_apparition_ice_blast_ebf", {duration = duration})
			self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"))
		end
	end
end

modifier_ancient_apparition_ice_blast_ebf = class({})
LinkLuaModifier("modifier_ancient_apparition_ice_blast_ebf", "lua_abilities/heroes/apparition", LUA_MODIFIER_MOTION_NONE)

function modifier_ancient_apparition_ice_blast_ebf:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("dot_damage")
	self.shatter = self:GetTalentSpecialValueFor("kill_pct")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_ancient_apparition_ice_blast_ebf:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("dot_damage")
	self.shatter = self:GetTalentSpecialValueFor("kill_pct")
end

function modifier_ancient_apparition_ice_blast_ebf:OnIntervalThink()
	EmitSoundOn("Hero_Ancient_Apparition.IceBlastRelease.Tick", self:GetParent())
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_ancient_apparition_ice_blast_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_ancient_apparition_ice_blast_ebf:GetDisableHealing()
	return 1
end

function modifier_ancient_apparition_ice_blast_ebf:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.unit:GetHealthPercent() <= self.shatter and params.inflictor ~= self:GetAbility() then
		self:GetParent():AttemptKill( self:GetAbility(), params.attacker )
	end
end

function modifier_ancient_apparition_ice_blast_ebf:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_ancient_apparition_ice_blast_ebf:GetStatusEffectName()
	return "particles/status_fx/status_effect_iceblast.vpcf"
end

function modifier_ancient_apparition_ice_blast_ebf:StatusEffectPriority()
	return 10
end