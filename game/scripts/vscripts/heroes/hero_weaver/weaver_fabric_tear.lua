weaver_fabric_tear = class({})
LinkLuaModifier("modifier_weaver_fabric_tear", "heroes/hero_weaver/weaver_fabric_tear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weaver_fabric_tear_debuff", "heroes/hero_weaver/weaver_fabric_tear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weaver_fabric_tear_bug", "heroes/hero_weaver/weaver_fabric_tear", LUA_MODIFIER_MOTION_NONE)

function weaver_fabric_tear:IsStealable()
    return true
end

function weaver_fabric_tear:IsHiddenWhenStolen()
    return false
end

function weaver_fabric_tear:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_ArcWarden.MagneticField.Cast", caster)
	CreateModifierThinker(caster, self, "modifier_weaver_fabric_tear", {Duration = duration}, point, caster:GetTeam(), false)
end

modifier_weaver_fabric_tear = class({})
function modifier_weaver_fabric_tear:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPoint = parent:GetAbsOrigin()

		EmitSoundOn("Hero_ArcWarden.MagneticField", parent)

		local radius = self:GetTalentSpecialValueFor("radius")
		local vRadius = Vector(radius, radius, radius)
		
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_fabric_tear.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, parentPoint)
					ParticleManager:SetParticleControl(nfx, 1, vRadius)
		self:AttachEffect(nfx)

		if caster:HasTalent("special_bonus_unique_weaver_fabric_tear_1") then
			local enemies = caster:FindEnemyUnitsInRadius(parentPoint, radius)
			for _,enemy in pairs(enemies) do
				FindClearSpaceForUnit(enemy, parentPoint, true)
			end
		end
	end
	self:StartIntervalThink(0.5)
end

function modifier_weaver_fabric_tear:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local point = self:GetParent():GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")

		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			if not enemy:HasModifier("modifier_weaver_fabric_tear_debuff") then
				if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
					enemy:AddNewModifier(caster, self:GetAbility(), "modifier_weaver_fabric_tear_debuff", {Duration = 1.1})
				end
				break
			end
		end
	end
end

modifier_weaver_fabric_tear_bug = class({})
function modifier_weaver_fabric_tear_bug:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_weaver_fabric_tear_bug:OnAttack(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
        	params.target:RemoveModifierByName("modifier_weaver_fabric_tear_debuff")
            self:GetParent():ForceKill(false)
        end
    end
end

function modifier_weaver_fabric_tear_bug:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_weaver_fabric_tear_bug:IsHidden()
	return true
end

modifier_weaver_fabric_tear_debuff = class({})
function modifier_weaver_fabric_tear_debuff:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		
		local callback = (function(image)
			if image ~= nil then
				image:AddNewModifier(caster, ability, "modifier_weaver_fabric_tear_bug", {Duration = 1})
				image:SetForceAttackTarget(parent)
			end
		end)

		local images = caster:ConjureImage( {outgoing_damage = 0, incoming_damage = 0, position = parent:GetAbsOrigin() + RandomVector( 350 ), controllable = false}, 1, caster, 1 )
		images[1]:AddNewModifier(caster, ability, "modifier_weaver_fabric_tear_bug", {Duration = 1})
		images[1]:SetForceAttackTarget(parent)
	end
end

function modifier_weaver_fabric_tear_debuff:IsHidden()
	return true
end