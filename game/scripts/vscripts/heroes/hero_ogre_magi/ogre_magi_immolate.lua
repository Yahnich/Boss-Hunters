ogre_magi_immolate = class({})
LinkLuaModifier( "modifier_ogre_magi_immolate", "heroes/hero_ogre_magi/ogre_magi_immolate.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ogre_magi_immolate_buff", "heroes/hero_ogre_magi/ogre_magi_immolate.lua",LUA_MODIFIER_MOTION_NONE )

function ogre_magi_immolate:IsStealable()
	return true
end

function ogre_magi_immolate:IsHiddenWhenStolen()
	return false
end

function ogre_magi_immolate:GetIntrinsicModifierName()
	return "modifier_ogre_magi_immolate"
end

function ogre_magi_immolate:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack3", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
				
	return true
end

function ogre_magi_immolate:OnSpellStart()
	EmitSoundOn("Hero_OgreMagi.Fireblast.Cast", self:GetCaster())
	self:Immolate()
end

function ogre_magi_immolate:Immolate()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)
	EmitSoundOn("Hero_OgreMagi.Bloodlust.Target", target)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)
	target:AddNewModifier(caster, self, "modifier_ogre_magi_immolate_buff", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_ogre_magi_immolate = class({})

function modifier_ogre_magi_immolate:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_ogre_magi_immolate:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if ability:GetAutoCastState() and caster:IsAlive() and ability:IsCooldownReady() and ability:IsOwnersManaEnough() and not caster:HasActiveAbility() then
		local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetAbility():GetCastRange(caster:GetAbsOrigin(), caster), {order = FIND_CLOSEST})
		for _,friend in pairs(friends) do
			if not friend:HasModifier("modifier_ogre_magi_immolate_buff") then
				caster:SetCursorCastTarget(friend)
				caster:CastAbilityOnTarget(friend, ability, caster:GetPlayerOwnerID() )
			end
		end
	elseif not ability:IsOwnersManaEnough() and ability:GetAutoCastState() then
		ability:ToggleAutoCast()
	end
end

function modifier_ogre_magi_immolate:IsHidden() return true end

modifier_ogre_magi_immolate_buff = class({})
function modifier_ogre_magi_immolate_buff:OnCreated(kv)
	if self:GetCaster():HasTalent("special_bonus_unique_ogre_magi_immolate_2") then
		self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_ogre_magi_immolate_2")
	end
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_immolation.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 1, Vector(100, 100, 100))
		self:AttachEffect(nfx)
		self:StartIntervalThink(0.25)
	end
end

function modifier_ogre_magi_immolate_buff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage")*0.25, {}, 0)
	end
end

function modifier_ogre_magi_immolate_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
	return funcs
end

function modifier_ogre_magi_immolate_buff:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_ogre_magi_immolate_buff:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_fire_immolation_child.vpcf"
end

function modifier_ogre_magi_immolate_buff:IsDebuff()
	return false
end