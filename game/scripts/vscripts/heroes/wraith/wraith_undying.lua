wraith_undying = class({})

function wraith_undying:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if caster ~= target then
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, caster:GetTeamNumber())
	else
		return UF_FAIL_CUSTOM
	end
end

function wraith_undying:GetCustomCastErrorTarget(target)
	return "Skill cannot target caster"
end

function wraith_undying:GetIntrinsicModifierName()
	if self:GetLevel() > 0 then
		return "modifier_wraith_undying_handler"
	end
end

function wraith_undying:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_wraith_undying_buff", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_SkeletonKing.Reincarnate", caster)
end

modifier_wraith_undying_handler = class({})
LinkLuaModifier("modifier_wraith_undying_handler", "heroes/wraith/wraith_undying.lua", 0)

if IsServer() then
	function modifier_wraith_undying_handler:OnCreated()
		self:StartIntervalThink(0.1)
	end
	
	function modifier_wraith_undying_handler:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_wraith_undying_buff") and not self:GetAbility():IsCooldownReady() and caster:IsAlive() then
			caster:RemoveModifierByName("modifier_wraith_undying_buff")
		elseif not caster:HasModifier("modifier_wraith_undying_buff") and self:GetAbility():IsCooldownReady() then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_wraith_undying_buff", {})
		end
	end
end

function modifier_wraith_undying_handler:IsHidden()
	return true
end


modifier_wraith_undying_buff = class({})
LinkLuaModifier("modifier_wraith_undying_buff", "heroes/wraith/wraith_undying.lua", 0)

function modifier_wraith_undying_buff:OnCreated()
	self.delay = self:GetSpecialValueFor("delay")
	self.invuln = self:GetSpecialValueFor("talent_duration")
end

function modifier_wraith_undying_buff:OnDestroy()
	if IsServer() and self:GetCaster():HasTalent("wraith_undying_talent_1") then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local duration = self.invuln
		Timers:CreateTimer(0.1, function()
			parent:AddNewModifier(caster, ability, "modifier_invulnerable", {duration = duration})
		end)
	end
end

function modifier_wraith_undying_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_REINCARNATION, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_wraith_undying_buff:ReincarnateTime(params)
	if self:GetParent() == self:GetCaster() then self:GetAbility():UseResources(false, false, true) end
	Timers:CreateTimer(self.delay + FrameTime(), function() 
		if not self:IsNull() then
			self:Destroy() 
		end 
	end)
	return self.delay
end

function modifier_wraith_undying_buff:RemoveOnDeath()
	return false
end

function modifier_wraith_undying_buff:GetEffectName()
	return "particles/heroes/wraith/wraith_undying.vpcf"
end