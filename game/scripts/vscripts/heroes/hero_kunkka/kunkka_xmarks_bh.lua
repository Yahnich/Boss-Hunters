kunkka_xmarks_bh = class({})

function kunkka_xmarks_bh:IsStealable()
    return false
end

function kunkka_xmarks_bh:IsHiddenWhenStolen()
    return false
end

function kunkka_xmarks_bh:GetManaCost( iLvl )
	if self:GetCaster():HasModifier("modifier_kunkka_xmarks_bh_client") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function kunkka_xmarks_bh:GetBehavior()
	if self:GetCaster():HasModifier("modifier_kunkka_xmarks_bh_client") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
end

function kunkka_xmarks_bh:CastFilterResultTarget( target )
	local caster = self:GetCaster()
	if target ~= caster then
		return UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber() )
	else
		return UF_SUCCESS
	end
end


function kunkka_xmarks_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	
	if caster:HasModifier("modifier_kunkka_xmarks_bh_client") then
		self:SetCooldown()
		if not self.currentTargetModifier:IsNull() then
			self.currentTargetModifier:Destroy()
			self.currentTargetModifier = nil
		end
	else
		local duration = self:GetSpecialValueFor("duration")
		
		EmitSoundOn("Ability.XMarksTheSpot.Target", target)
		if target ~= caster then
			if target:TriggerSpellAbsorb( self ) then return end
		else
			duration = self:GetSpecialValueFor("self_duration")
		end
		self.currentTargetModifier = target:AddNewModifier(caster, self, "modifier_kunkka_xmarks_bh", {Duration = duration})
		caster:AddNewModifier(caster, self, "modifier_kunkka_xmarks_bh_client", {})
		self:EndCooldown()
	end
end

modifier_kunkka_xmarks_bh = class({})
LinkLuaModifier("modifier_kunkka_xmarks_bh", "heroes/hero_kunkka/kunkka_xmarks_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_xmarks_bh:OnCreated(table)
    if IsServer() then
        EmitSoundOn("Ability.XMark.Target_Movement", self:GetParent())
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_x_spot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
                    ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        self:AttachEffect(nfx)
        self.startPos = self:GetParent():GetAbsOrigin()
    end
end

function modifier_kunkka_xmarks_bh:OnRemoved()
    if IsServer() then
        StopSoundOn("Ability.XMark.Target_Movement", self:GetParent())
        EmitSoundOn("Ability.XMarksTheSpot.Return", self:GetParent())
        if self:GetParent() ~= self:GetCaster() then
			self:GetParent():Daze(self:GetAbility(), self:GetCaster(), self:GetSpecialValueFor("daze_duration"))
		end
        FindClearSpaceForUnit(self:GetParent(), self.startPos, true)
		self:GetCaster():RemoveModifierByName("modifier_kunkka_xmarks_bh_client")
    end
end


modifier_kunkka_xmarks_bh_client = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_kunkka_xmarks_bh_client", "heroes/hero_kunkka/kunkka_xmarks_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_xmarks_bh_client:IsHidden()
	return true
end