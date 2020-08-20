boss_genesis_return_to_life = class({})

function boss_genesis_return_to_life:OnAbilityPhaseStart()
	for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
		ParticleManager:FireWarningParticle( hero:GetAbsOrigin(), 150 )
	end
	return true
end

function boss_genesis_return_to_life:OnSpellStart()
	local caster = self:GetCaster()
	local heroes = HeroList:GetActiveHeroes()
	
	local outgoing_damage = self:GetSpecialValueFor("outgoing") - 100
	local incoming_damage = self:GetSpecialValueFor("incoming") - 100
	for _, hero in ipairs( heroes ) do
		if not hero:TriggerSpellAbsorb(self) and hero:IsAlive() and hero:GetHealth() > 0 then
			hero:ConjureImage( {outgoing_damage = outgoing_damage, incoming_damage = incoming_damage, position = caster:GetAbsOrigin(), ability = self}, -1, caster, 1 )
			hero:EmitSound("Hero_Omniknight.Attack.Post")
		end
	end
end