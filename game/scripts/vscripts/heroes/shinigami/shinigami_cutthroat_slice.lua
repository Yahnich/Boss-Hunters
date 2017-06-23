shinigami_cutthroat_slice = class({})

function shinigami_cutthroat_slice:GetCastRange(entity, position)
	return self:GetCaster():GetAttackRange() + 50
end

function shinigami_cutthroat_slice:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local attack = ParticleManager:CreateParticle("particles/heroes/shinigami/shinigami_cutthroat_slice.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(attack, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(attack)
	
	local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(blood, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(blood)
	
	local backstabMultiplier = 1
	if caster:IsAtAngleWithEntity(target, 90) then
		backstabMultiplier = self:GetSpecialValueFor("backstab_multiplier") / 100
	end
	
	EmitSoundOn("Hero_LifeStealer.OpenWounds", target)
	
	ApplyDamage({victim = target, attacker = caster, damage = self:GetSpecialValueFor("base_damage") * backstabMultiplier, damage_type = self:GetAbilityDamageType(), ability = self})
	for i = 1, math.floor(self:GetSpecialValueFor("deep_wound_stacks") * backstabMultiplier + 0.5) do
		caster:PerformAbilityAttack(target)
	end
	target:AddNewModifier(caster, self, "modifier_shinigami_cutthroat_slice_debuff", {duration = self:GetSpecialValueFor("silence_duration") * backstabMultiplier})
end


modifier_shinigami_cutthroat_slice_debuff = class({})
LinkLuaModifier("modifier_shinigami_cutthroat_slice_debuff", "heroes/shinigami/shinigami_cutthroat_slice.lua", 0)
if IsServer() then
	function modifier_shinigami_cutthroat_slice_debuff:OnCreated()
		self:GetAbility():SetActivated(false)
		self:GetAbility():EndCooldown()
		self:GetAbility():StartCooldown(self:GetRemainingTime())
		local silence = ParticleManager:CreateParticle("particles/generic_gameplay/generic_silence.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(silence,false, false, 0, false, true)
		ParticleManager:ReleaseParticleIndex(silence)
		if self:GetCaster():HasTalent("shinigami_cutthroat_slice_talent_1") then
			local disarm = ParticleManager:CreateParticle("particles/generic_gameplay/generic_disarm.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
			self:AddParticle(disarm,false, false, 0, false, true)
			ParticleManager:ReleaseParticleIndex(disarm)
		end


		local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(blood)
	end
	
	function modifier_shinigami_cutthroat_slice_debuff:OnRefresh()
		self:GetAbility():SetActivated(false)
		self:GetAbility():EndCooldown()
		self:GetAbility():StartCooldown(self:GetRemainingTime())
		local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(blood)
	end

	function modifier_shinigami_cutthroat_slice_debuff:OnDestroy()
		self:GetAbility():EndCooldown()
		self:GetAbility():UseResources(false, false, true)
		self:GetAbility():SetActivated(true)
	end
end


function modifier_shinigami_cutthroat_slice_debuff:CheckState()
	local state = { [MODIFIER_STATE_SILENCED] = true}
	if self:GetCaster():HasTalent("shinigami_cutthroat_slice_talent_1") then
		state = {[MODIFIER_STATE_SILENCED] = true,
				 [MODIFIER_STATE_PASSIVES_DISABLED] = true,
				 [MODIFIER_STATE_DISARMED] = true}
	end
	return state
end