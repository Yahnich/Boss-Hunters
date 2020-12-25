doom_apocalypse = class({})


function doom_apocalypse:IsStealable()
	return true
end

function doom_apocalypse:IsHiddenWhenStolen()
	return false
end

function doom_apocalypse:OnSpellStart()
	self.doomDamage = self:GetTalentSpecialValueFor( "damage" )
	self.doomDuration = self:GetTalentSpecialValueFor("duration")
	local doomModifier = "modifier_doom_apocalypse"
	local hTarget = self:GetCursorTarget()
	EmitSoundOn( "Hero_DoomBringer.LvlDeath", self:GetCaster())
	-- if self:GetCaster():HasScepter() then
		-- EmitSoundOn( "Hero_Nevermore.Shadowraze", self:GetCaster())
		-- if hTarget == nil or ( hTarget ~= nil and ( not hTarget:TriggerSpellAbsorb( self ) ) ) then
			-- local vTargetPosition = nil
			-- if hTarget ~= nil then 
				-- vTargetPosition = hTarget:GetOrigin()
			-- else
				-- vTargetPosition = self:GetCursorPosition()
			-- end
			-- local direction = CalculateDirection( vTargetPosition, self:GetCaster() )
			-- local location = self:GetCaster():GetAbsOrigin() + direction * 150
			-- local strikes = math.floor(self:GetTrueCastRange() / 150)
			-- for i=1, strikes,1 do
                -- self:ApplyAOE({particles = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",
							   -- location = GetGroundPosition(location, self:GetCaster()),
							   -- radius = 250,
							   -- damage = self.doomDamage,
							   -- damage_type = self:GetAbilityDamageType(), 
							   -- modifier = doomModifier, 
							   -- duration = self.doomDuration,
							   -- magic_immune = true})
                -- location = location + direction * 150
            -- end
		-- end
	if not hTarget:TriggerSpellAbsorb(self) then
		hTarget:AddNewModifier( self:GetCaster(), self, doomModifier, { duration = self.doomDuration } )
	end
end

function doom_apocalypse:GetCastRange( hTarget, vLocation )
	if self:GetCaster():HasScepter() then
		return 1000
	else
		return 550
	end
end

modifier_doom_apocalypse = class({})
LinkLuaModifier( "modifier_doom_apocalypse", "heroes/hero_doom/doom_apocalypse.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_doom_apocalypse_talent", "heroes/hero_doom/doom_apocalypse.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function modifier_doom_apocalypse:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_doom_apocalypse:OnCreated( kv )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	EmitSoundOn( "Hero_DoomBringer.Doom", self:GetParent())
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_doom_apocalypse_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_doom_apocalypse_2")
	self.talent3 = self:GetCaster():HasTalent("special_bonus_unique_doom_apocalypse_3")
	self.ogDuration = self:GetDuration()
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor( "damage" )
		self:OnIntervalThink()
		self:StartIntervalThink( 1 )
	end
end

function modifier_doom_apocalypse:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		StopSoundOn("Hero_DoomBringer.Doom", parent)
		if self.talent1 then
			parent:AddNewModifier( caster, ability, "modifier_doom_apocalypse_talent", {} )
		end
		if self.talent2 and self:GetRemainingTime() > 0 then
			for _, unit in ipairs( caster:FindAllUnitsInRadius( parent:GetAbsOrigin(), -1, {order = FIND_CLOSEST} ) ) do
				if not unit:IsSameTeam( caster ) or self.talent3 then
					unit:AddNewModifier( caster, ability, "modifier_doom_apocalypse", {duration = self:GetRemainingTime(), ignoreStatusAmp = true} )
					return
				end
			end
		end
	end
end

function modifier_doom_apocalypse:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	if caster:IsSameTeam( target ) then
		target:HealEvent( self.damage, ability, caster )
	else
		ability:DealDamage( caster, target, self.damage )
	end
	if self.talent2 and target:IsMinion() then
		self:SetDuration( self.ogDuration, true )
	end
	if not target:IsAlive() then
		StopSoundOn("Hero_DoomBringer.Doom", target)
	end
end

function modifier_doom_apocalypse:CheckState()
	if self:GetCaster():IsSameTeam( self:GetParent() ) then
		return {
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_UNSLOWABLE] = true,
		}
	else
		return {
		[MODIFIER_STATE_SILENCED] = true,
	}
	end
end

function modifier_doom_apocalypse:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING }
end

function modifier_doom_apocalypse:GetDisableHealing()
	if not self:GetCaster():IsSameTeam( self:GetParent() ) then
		return 1
	end
end


function modifier_doom_apocalypse:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end

function modifier_doom_apocalypse:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_doom_apocalypse:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf" 	   
end

--------------------------------------------------------------------------------
function modifier_doom_apocalypse:RemoveOnDeath()
	return true
end

function modifier_doom_apocalypse:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

modifier_doom_apocalypse_talent = class(modifier_doom_apocalypse)
LinkLuaModifier( "modifier_doom_apocalypse_talent", "heroes/hero_doom/doom_apocalypse.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_doom_apocalypse_talent:OnRefresh( kv )
	if IsServer() then
		self.damage = self.damage + self:GetAbility():GetTalentSpecialValueFor( "damage" )
		self:OnIntervalThink()
	end
end

function modifier_doom_apocalypse_talent:OnDestroy()
	StopSoundOn("Hero_DoomBringer.Doom", self:GetParent())
end

function modifier_doom_apocalypse_talent:CheckState()
	local state = {}

	return state
end

function modifier_doom_apocalypse_talent:DeclareFunctions()
	return {}
end