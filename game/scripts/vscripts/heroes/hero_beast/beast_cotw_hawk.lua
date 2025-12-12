beast_cotw_hawk = class({})

function beast_cotw_hawk:IsStealable()
	return true
end

function beast_cotw_hawk:IsHiddenWhenStolen()
	return false
end

function beast_cotw_hawk:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_cotw_hawk_spirit", {})
	caster:RemoveModifierByName("modifier_cotw_boar_spirit")
end

modifier_cotw_hawk_spirit = class({})
LinkLuaModifier( "modifier_cotw_hawk_spirit", "heroes/hero_beast/beast_cotw_hawk.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_cotw_hawk_spirit:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		EmitSoundOn("Hero_Beastmaster.Call.hawk", caster)
		if ability.currentSpirit and not ability.currentSpirit:IsNull() then
			ability.currentSpirit:ForceKill(false)
			UTIL_Remove( ability.currentSpirit )
			ability.currentSpirit = nil
		end
		ability.currentSpirit = caster:CreateSummon( "npc_dota_beastmaster_hawk_1", caster:GetAbsOrigin() )

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_call_bird.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, ability.currentSpirit:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nfx)

		ability.currentSpirit:AddNewModifier(caster, ability, "modifier_cotw_hawk_spirit_hawk", {})
		
		local hp = ability:GetSpecialValueFor("hawk_health")
		local ms = ability:GetSpecialValueFor("hawk_ms")
		local vision = ability:GetSpecialValueFor("hawk_vision")
		
		ability.currentSpirit:SetCoreHealth( hp )
		ability.currentSpirit:SetBaseMoveSpeed( ms )
		ability.currentSpirit:SetDayTimeVisionRange( vision )
		ability.currentSpirit:SetNightTimeVisionRange( vision )
		
		ability.currentSpirit:SetPhysicalArmorBaseValue( 1.5 + ability:GetLevel() * 0.5 )
		ability.currentSpirit:SetBaseMagicalResistanceValue( 15 )
		ability.currentSpirit:SetBaseHealthRegen( hp / 100 )
		
		if caster:HasTalent("special_bonus_unique_beast_cotw_hawk_1") then
			ability.currentSpirit:SetRangedProjectileName( "particles/base_attacks/generic_projectile.vpcf" )
			ability.currentSpirit:SetAverageBaseDamage( caster:GetAttackDamage() * caster:FindTalentValue("special_bonus_unique_beast_cotw_hawk_1", "dmg") / 100, 15)
			ability.currentSpirit:SetBaseAttackTime( caster:FindTalentValue("special_bonus_unique_beast_cotw_hawk_1", "bat") )
		else
			ability.currentSpirit:SetAttackCapability( DOTA_UNIT_CAP_NO_ATTACK )
		end
		
		self:StartIntervalThink( 1 )
		self:SetDuration( -1, true)
		
		self.respawnTime = ability:GetSpecialValueFor("respawn_time")
	end
end

function modifier_cotw_hawk_spirit:OnRefresh(table)
	self:OnCreated()
end

function modifier_cotw_hawk_spirit:OnIntervalThink()
	local ability = self:GetAbility()
	if not ability.currentSpirit then
		self:OnCreated()
	end
	if ability.currentSpirit and ( ability.currentSpirit:IsNull() or not ability.currentSpirit:IsAlive() ) then
		ability.currentSpirit = nil
	end
	if not ability.currentSpirit then
		self:StartIntervalThink( self.respawnTime )
		self:SetDuration( self.respawnTime + 0.1, true)
	end
end

function modifier_cotw_hawk_spirit:OnRemoved()
	if IsServer() then
		local ability = self:GetAbility()
		StopSoundOn("Hero_Beastmaster.Call.hawk", self:GetCaster())
		if ability.currentSpirit and not ability.currentSpirit:IsNull() then
			ability.currentSpirit:ForceKill(false)
			UTIL_Remove( ability.currentSpirit )
			ability.currentSpirit = nil
		end
	end
end

function modifier_cotw_hawk_spirit:IsDebuff()
	return false
end


modifier_cotw_hawk_spirit_hawk = class({})
LinkLuaModifier( "modifier_cotw_hawk_spirit_hawk", "heroes/hero_beast/beast_cotw_hawk.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_cotw_hawk_spirit_hawk:OnCreated()
	self.delay = self:GetSpecialValueFor("invis_delay")
	if IsServer() then
		self.last_location = self:GetParent():GetAbsOrigin()
		self.timer = 0
		self:StartIntervalThink(0.25)
	end
end

function modifier_cotw_hawk_spirit_hawk:OnRefresh()
	self:OnCreated()
end

function modifier_cotw_hawk_spirit_hawk:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_invisible") then
		if CalculateDistance( self.last_location, self:GetParent():GetAbsOrigin() ) >= 10 or self:GetParent():GetAttackTarget() then
			self:GetParent():RemoveModifierByName("modifier_invisible")
			self.timer = 0
		end
	else
		if CalculateDistance( self.last_location, self:GetParent():GetAbsOrigin() ) >= 10 or self:GetParent():GetAttackTarget() then
			self.timer = 0
		elseif self.timer >= self.delay then
			self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_invisible", {} )
		else
			self.timer = self.timer + 0.25
		end
	end
	self.last_location = self:GetParent():GetAbsOrigin()
end

function modifier_cotw_hawk_spirit_hawk:IsHidden()
	return true
end