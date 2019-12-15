chen_holy_persuasion_bh = class({})
function chen_holy_persuasion_bh:IsStealable()
	return false
end

function chen_holy_persuasion_bh:IsHiddenWhenStolen()
	return false
end

function chen_holy_persuasion_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Chen.HolyPersuasionCast", caster)
	
	
	if caster:IsSameTeam( target ) then
		target:AddNewModifier( caster, self, "modifier_chen_holy_persuasion_bh_tp", { duration = self:GetTalentSpecialValueFor("teleport_delay") } )
		if caster:HasTalent("special_bonus_unique_chen_holy_persuasion_2") then
			target:AddNewModifier( caster, self, "modifier_chen_holy_persuasion_bh_tp", { duration = caster:FindTalentValue("special_bonus_unique_chen_holy_persuasion_2") } )
		end
	elseif not target:TriggerSpellAbsorb( self ) then
		local duration = self:GetTalentSpecialValueFor("duration")
		if target:IsMinion() then
			duration = -1
			self.minionList = self.minionList or {}
			for i = #self.minionList, 1, -1 do
				if not self.minionList[i] or self.minionList[i]:IsNull() then
					table.remove( self.minionList, 1 )
				end
			end
			if #self.minionList >= self:GetTalentSpecialValueFor("minion_limit") then
				self.minionList[1]:ForceKill( false )
				table.remove( self.minionList, 1 )
			end
			table.insert( self.minionList, target )
		else
			if not target:IsBoss() and caster:HasTalent("special_bonus_unique_chen_holy_persuasion_1") then
				duration = duration * caster:FindTalentValue("special_bonus_unique_chen_holy_persuasion_1")
			end
		end
		target:AddNewModifier( caster, self, "modifier_chen_holy_persuasion_bh", { duration = duration } )
		ParticleManager:FireParticle( "particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_POINT_FOLLOW, target, {[0] = target:GetAbsOrigin(), [1] = target:GetAbsOrigin(),[2] = Vector(duration,0,0)} )
	end
end

modifier_chen_holy_persuasion_bh_tp = class({})
LinkLuaModifier( "modifier_chen_holy_persuasion_bh_tp", "heroes/hero_chen/chen_holy_persuasion_bh.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_chen_holy_persuasion_bh_tp:OnCreated()
	if IsServer() then
		EmitSoundOn( "Hero_Chen.TeleportLoop", self:GetParent() )
	end
end

function modifier_chen_holy_persuasion_bh_tp:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Chen.TeleportLoop", self:GetParent() )
		ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_teleport_flash.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		EmitSoundOn( "Hero_Chen.TeleportOut", self:GetParent() )
		FindClearSpaceForUnit( self:GetParent(), self:GetCaster():GetAbsOrigin() + RandomVector( 64 ), true )
		EmitSoundOn( "Hero_Chen.TeleportIn", self:GetParent() )
	end
end

function modifier_chen_holy_persuasion_bh_tp:GetEffectName()
	return "particles/units/heroes/hero_chen/chen_teleport.vpcf"
end

modifier_chen_holy_persuasion_bh = class({})
LinkLuaModifier( "modifier_chen_holy_persuasion_bh", "heroes/hero_chen/chen_holy_persuasion_bh.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_chen_holy_persuasion_bh:OnCreated()
	if self:GetParent():IsMinion() or self:GetParent():IsRealHero() and self:GetCaster():HasTalent("special_bonus_unique_chen_holy_persuasion_2") then	
		self.hp = self:GetTalentSpecialValueFor("bonus_health")
		if IsServer() then
			local currHPPCT = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()
			Timers:CreateTimer(function() self:GetParent():SetHealth( currHPPCT * self:GetParent():GetMaxHealth() ) end )
		end
	end
	if IsServer() then
		self.originalTeam = self:GetParent():GetTeam()
		if not self:GetParent():IsSameTeam( self:GetCaster() ) then
			self:GetParent():SetTeam( self:GetCaster():GetTeam() )
		end
	end
end

function modifier_chen_holy_persuasion_bh:OnDestroy()
	if self:GetParent():IsMinion() or self:GetParent():IsRealHero() and self:GetCaster():HasTalent("special_bonus_unique_chen_holy_persuasion_2") then	
		self.hp = self:GetTalentSpecialValueFor("bonus_health")
	end
	if IsServer() then
		if self.originalTeam ~= self:GetCaster():GetTeam() then
			self:GetParent():SetTeam( self.originalTeam )
		end
	end
end

function modifier_chen_holy_persuasion_bh:CheckState()
	if not self:GetParent():IsMinion() then
		return {[MODIFIER_STATE_SPECIALLY_DENIABLE] = true}
	end
end

function modifier_chen_holy_persuasion_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_chen_holy_persuasion_bh:GetModifierExtraHealthBonus()
	return self.hp
end