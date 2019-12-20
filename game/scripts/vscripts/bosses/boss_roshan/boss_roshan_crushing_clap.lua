boss_roshan_crushing_clap = class({})

function boss_roshan_crushing_clap:OnAbilityPhaseStart()
	local startPos = self:GetCaster():GetAbsOrigin()
	EmitSoundOn( "Roshan.Grunt", self:GetCaster() )
	ParticleManager:FireWarningParticle( startPos, self:GetTrueCastRange() )
	return true
end

function boss_roshan_crushing_clap:OnSpellStart()
	local caster = self:GetCaster()
	
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetTrueCastRange() 
	local startPos = caster:GetAbsOrigin()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( startPos, radius ) ) do
		if not enemy:TriggerSpellAbsorb( self ) then	
			self:DealDamage( caster, enemy, damage )
			enemy:AddNewModifier( caster, self, "modifier_boss_roshan_crushing_clap", {duration = duration})
		end
	end
	EmitSoundOn( "Roshan.Slam", caster )
	ParticleManager:FireParticle( "particles/neutral_fx/roshan_slam.vpcf", PATTACH_ABSORIGIN, caster, {[0] = startPos, [1] = Vector(radius,radius,radius)})
end

modifier_boss_roshan_crushing_clap = class({})
LinkLuaModifier( "modifier_boss_roshan_crushing_clap", "bosses/boss_roshan/boss_roshan_crushing_clap", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_roshan_crushing_clap:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_reduction")
	self.mr = self:GetSpecialValueFor("mr_reduction")
end

function modifier_boss_roshan_crushing_clap:OnRefresh()
	self:OnCreated()
end

function modifier_boss_roshan_crushing_clap:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_boss_roshan_crushing_clap:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_boss_roshan_crushing_clap:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_boss_roshan_crushing_clap:GetEffectName()
	return "particles/units/heroes/hero_monkey_king/monkey_king_jump_armor_debuff.vpcf"
end