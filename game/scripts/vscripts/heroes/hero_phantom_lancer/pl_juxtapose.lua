pl_juxtapose = class({})
LinkLuaModifier("modifier_pl_juxtapose", "heroes/hero_phantom_lancer/pl_juxtapose", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_juxtapose_illusion", "heroes/hero_phantom_lancer/pl_juxtapose", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_juxtapose_illusion_count", "heroes/hero_phantom_lancer/pl_juxtapose", LUA_MODIFIER_MOTION_NONE)

function pl_juxtapose:IsStealable()
    return false
end

function pl_juxtapose:IsHiddenWhenStolen()
    return false
end

function pl_juxtapose:GetIntrinsicModifierName()
    return "modifier_pl_juxtapose"
end

function pl_juxtapose:SpawnIllusion()
    local caster = self:GetCaster()
	local player = caster:GetPlayerID()
	
	local proc_chance = 0
	local max_illusions =  self:GetTalentSpecialValueFor("max_illusions")
	local current_illusions = 0
	
	-- Gets the ability owned by the original caster, so we can keep track of the number of illusions
	local original_hero = PlayerResource:GetSelectedHeroEntity(player)
	local ability_name = self:GetAbilityName()
	local original_ability = original_hero:FindAbilityByName(ability_name)
	
	if original_ability.illusions == nil then
		original_ability.illusions = 0
	else
		current_illusions = original_ability.illusions
	end
	
	-- If there is a proc and there are not too many illusions, creates a new one
	if current_illusions < max_illusions then
	
		original_ability.illusions = original_ability.illusions + 1

		local origin = caster:GetAbsOrigin() + RandomVector(72)

		local duration = self:GetTalentSpecialValueFor("illusion_duration")
		local outgoingDamage = self:GetTalentSpecialValueFor("illusion_out")
		local incomingDamage = self:GetTalentSpecialValueFor("illusion_in")

		if caster:IsIllusion() then
			duration = self:GetTalentSpecialValueFor("illusion_duration") / 2
		end

		local callback = (function(image)
            if image ~= nil then
            	-- This modifier is applied to every illusion to check if they die or expire
				image:AddNewModifier(caster, self, "modifier_pl_juxtapose_illusion_count", {})
				self:GiveFxModifier(image)
            end
        end)

        local image = original_hero:ConjureImage( origin, duration, outgoingDamage, incomingDamage, "", self, true, original_hero, callback )
 
	end
end

function pl_juxtapose:GiveFxModifier(hTarget)
	local caster = self:GetCaster()
    hTarget:AddNewModifier(caster, self, "modifier_pl_juxtapose_illusion", {})
end

modifier_pl_juxtapose = class({})
function modifier_pl_juxtapose:OnCreated(table)
	if IsServer() then
		self.chance = self:GetTalentSpecialValueFor("chance")
		self.illusion_chance = self:GetTalentSpecialValueFor("illusion_chance")
	end
end

function modifier_pl_juxtapose:DeclareFunctions()
	local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED,
					MODIFIER_EVENT_ON_ABILITY_EXECUTED}
	return funcs
end

function modifier_pl_juxtapose:OnAbilityExecuted(params)
	if IsServer() then
		local caster = self:GetCaster()
		local unit = params.unit

		if unit == caster and caster:HasTalent("special_bonus_unique_pl_juxtapose_1") then
			if RollPercentage(caster:FindTalentValue("special_bonus_unique_pl_juxtapose_1")) then
				self:GetAbility():SpawnIllusion()
			end
		end

	end
end

function modifier_pl_juxtapose:OnAttackLanded(params)
	if IsServer() then
		local parent = self:GetParent()
		local attacker = params.attacker
		local target = params.target

		if parent == attacker then
			EmitSoundOn("Hero_Meepo.Ransack.Target", target)

			if parent:IsIllusion() then
				if RollPercentage( self.illusion_chance ) then
					self:GetAbility():SpawnIllusion()
				end
			else
				if RollPercentage( self.chance ) then
					self:GetAbility():SpawnIllusion()
				end
			end
		end
	end
end

function modifier_pl_juxtapose:IsPurgable()
	return false
end

function modifier_pl_juxtapose:IsHidden()
	return true
end

modifier_pl_juxtapose_illusion = class({})

function modifier_pl_juxtapose_illusion:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_illusion.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 5, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)
	end
end

function modifier_pl_juxtapose_illusion:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_illusion.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)
	end
end

function modifier_pl_juxtapose_illusion:CheckState()
	local state = {}
	if self:GetCaster():HasTalent("special_bonus_unique_pl_juxtapose_2") then
		state = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	end
    return state
end

function modifier_pl_juxtapose_illusion:GetStatusEffectName()
	return "particles/units/heroes/hero_phantom_lancer/status_effect_phantom_illstrong.vpcf"
end

function modifier_pl_juxtapose_illusion:StatusEffectPriority()
	return 20
end

function modifier_pl_juxtapose_illusion:IsHidden()
	return true
end

modifier_pl_juxtapose_illusion_count = class({})
function modifier_pl_juxtapose_illusion_count:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local player = caster:GetPlayerID()

		local original_hero = PlayerResource:GetSelectedHeroEntity(player)
		local ability_name = ability:GetAbilityName()
		local original_ability = original_hero:FindAbilityByName(ability_name)
		
		original_ability.illusions = original_ability.illusions - 1
	end
end

function modifier_pl_juxtapose_illusion_count:IsHidden()
	return true
end