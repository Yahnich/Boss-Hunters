pl_juxtapose = class({})
LinkLuaModifier("modifier_pl_juxtapose", "heroes/hero_phantom_lancer/pl_juxtapose", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_juxtapose_illusion", "heroes/hero_phantom_lancer/pl_juxtapose", LUA_MODIFIER_MOTION_NONE)

function pl_juxtapose:IsStealable()
    return false
end

function pl_juxtapose:IsHiddenWhenStolen()
    return false
end

function pl_juxtapose:GetIntrinsicModifierName()
    return "modifier_pl_juxtapose"
end

function pl_juxtapose:SpawnIllusion(forceIllusion)
    local caster = self:GetCaster()
	local player = caster:GetPlayerID()
	
	local max_illusions =  TernaryOperator( self:GetTalentSpecialValueFor("scepter_illusions"), caster:HasScepter(), self:GetTalentSpecialValueFor("max_illusions") )
	local current_illusions = 0
	
	-- Gets the ability owned by the original caster, so we can keep track of the number of illusions
	local original_hero = PlayerResource:GetSelectedHeroEntity(player) or caster
	local ability_name = self:GetAbilityName()
	local original_ability = original_hero:FindAbilityByName(ability_name)
	
	if original_ability and original_ability.illusions == nil then
		original_ability.illusions = {}
	else
		for i = #original_ability.illusions, 1, -1 do
			if original_ability.illusions[i] and original_ability.illusions[i]:IsNull() or not original_ability.illusions[i]:IsAlive() then
				table.remove( original_ability.illusions, i )
			end
		end
		current_illusions = #original_ability.illusions
	end
	
	-- If there is a proc and there are not too many illusions, creates a new one
	if current_illusions < max_illusions or forceIllusion then
		local origin = caster:GetAbsOrigin() + RandomVector(72)

		local duration = self:GetTalentSpecialValueFor("illusion_duration")
		local outgoingDamage = self:GetTalentSpecialValueFor("illusion_out") - 100
		local incomingDamage = self:GetTalentSpecialValueFor("illusion_in") - 100

		if caster:IsIllusion() then
			duration = self:GetTalentSpecialValueFor("illusion_duration") / 2
		end

        local image = original_hero:ConjureImage( {outgoing_damage = outgoingDamage, incoming_damage = incomingDamage, illusion_modifier = "modifier_phantom_lancer_juxtapose_illusion", position = origin}, duration, original_hero, 1 )
		image[1]:AddNewModifier(original_hero, self, "modifier_pl_juxtapose_illusion", {})
		table.insert( original_ability.illusions, image[1] )
		return image[1]
	end
end

modifier_pl_juxtapose = class({})
function modifier_pl_juxtapose:OnCreated(table)
	if IsServer() then
		self.chance = self:GetTalentSpecialValueFor("chance")
		self.illusion_chance = self:GetTalentSpecialValueFor("illusion_chance")
	end
end

function modifier_pl_juxtapose:DeclareFunctions()
	local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED}
	return funcs
end

function modifier_pl_juxtapose:OnAttackLanded(params)
	if IsServer() then
		local parent = self:GetParent()
		local attacker = params.attacker
		local target = params.target

		if parent == attacker then
			EmitSoundOn("Hero_Meepo.Ransack.Target", target)

			if parent:IsIllusion() then
				if parent:RollPRNG( self.illusion_chance ) then
					self:GetAbility():SpawnIllusion()
				end
			else
				if self:RollPRNG( self.chance ) then
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

function modifier_pl_juxtapose_illusion:GetStatusEffectName()
	return "particles/units/heroes/hero_phantom_lancer/status_effect_phantom_illstrong.vpcf"
end

function modifier_pl_juxtapose_illusion:StatusEffectPriority()
	return 20
end

function modifier_pl_juxtapose_illusion:IsHidden()
	return true
end