zombie_screech = class({})

function zombie_screech:GetIntrinsicModifierName()
	return "modifier_zombie_screech_ai"
end

function zombie_screech:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("duration")
	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_zombie_screech_taunted", {duration = delay})
	end
	EmitSoundOn("Hero_Undying.FleshGolem.Cast", caster)
	local scream = ParticleManager:CreateParticle("particles/heroes/puppeteer/puppeteer_zombie_screech.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(scream)
	self:SetActivated(false)
	self:EndCooldown()
	Timers:CreateTimer(delay, function() 
		self:SetActivated(true)	
		self:UseResources( false, false, true )
	end)
end

LinkLuaModifier( "modifier_zombie_screech_taunted", "summons/zombie_brute/zombie_screech.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_zombie_screech_taunted = class({})

function modifier_zombie_screech_taunted:IsPurgable()
	return false
end
	
function modifier_zombie_screech_taunted:StatusEffectPriority()
	return 5
end

function modifier_zombie_screech_taunted:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_zombie_screech_taunted:GetHeroEffectName()
	return "particles/units/heroes/hero_axe/axe_beserkers_call_hero_effect.vpcf"
end


function modifier_zombie_screech_taunted:GetTauntTarget()
	return self:GetCaster()
end


LinkLuaModifier("modifier_zombie_screech_ai", "summons/zombie_brute/zombie_screech.lua", LUA_MODIFIER_MOTION_NONE)
modifier_zombie_screech_ai = class({})

function modifier_zombie_screech_ai:OnCreated()
	if IsServer() then self:StartIntervalThink(0.2) end
end

function modifier_zombie_screech_ai:OnIntervalThink()
	if not self:GetAbility():IsFullyCastable() then return end
	if self:GetAbility():GetAutoCastState() then -- cast on random ally below health treshhold or spam on whatever ally is being attacked
		local target
		local allies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		for _, ally in pairs(allies) do
			if ally:IsBeingAttacked() and ally ~= self:GetParent() then 
				target = ally
				break
			end
		end
		if not target then return end
		self:GetCaster():Interrupt()
		ExecuteOrderFromTable({
			UnitIndex = self:GetCaster():entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = self:GetAbility():entindex(),
			Queue = true
		})
	end
end


function modifier_zombie_screech_ai:IsHidden()
	return true
end
