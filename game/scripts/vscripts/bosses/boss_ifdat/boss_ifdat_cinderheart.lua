boss_ifdat_cinderheart = class({})

function boss_ifdat_cinderheart:OnSpellStart()
	local caster = self:GetCaster()
	
	local heal = self:GetSpecialValueFor("heal_per_stack") / 100
	local stacks = 0
	for _, modifier in ipairs( self:GetCaster().touchOfFireTable ) do
		parent = modifier:GetParent()
		ParticleManager:FireRopeParticle( "particles/units/bosses/boss_ifdat/boss_ifdat_cinderheart.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), parent )
		parent:EmitSound( "Hero_Lina.ProjectileImpact" )
		stacks = stacks + modifier:GetStackCount()
		modifier:Destroy()
	end
	caster:HealEvent( caster:GetMaxHealth() * heal * stacks, self, caster )
end


function boss_ifdat_cinderheart:GetCurrentPotentialHeal()
	local stacks = 0
	self:GetCaster().touchOfFireTable = self:GetCaster().touchOfFireTable or {}
	for _, modifier in ipairs( self:GetCaster().touchOfFireTable ) do
		stacks = stacks + modifier:GetStackCount()
	end
	return self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("heal_per_stack") / 100 * stacks
end