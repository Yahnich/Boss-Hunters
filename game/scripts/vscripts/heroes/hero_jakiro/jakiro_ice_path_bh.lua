jakiro_ice_path_bh = class({})
LinkLuaModifier("modifier_jakiro_ice_path_bh", "heroes/hero_jakiro/jakiro_ice_path_bh", LUA_MODIFIER_MOTION_NONE)

function jakiro_ice_path_bh:IsStealable()
	return true
end

function jakiro_ice_path_bh:IsHiddenWhenStolen()
	return false
end

function jakiro_ice_path_bh:OnSpellStart()
	local caster = self:GetCaster()

	local point = self:GetCursorPosition()

	if self:GetCursorTarget() then
		point = self:GetCursorTarget():GetAbsOrigin()
	end

	local direction = CalculateDirection(point, caster:GetAbsOrigin())

	EmitSoundOn("Hero_Jakiro.IcePath.Cast", caster)

	CreateModifierThinker(caster, self, "modifier_jakiro_ice_path_bh", {Duration = self:GetTalentSpecialValueFor("duration") + self:GetTalentSpecialValueFor("delay")}, caster:GetAbsOrigin() + direction * 12, caster:GetTeam(), false)
end


modifier_jakiro_ice_path_bh = class({})
function modifier_jakiro_ice_path_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local length = self:GetTalentSpecialValueFor("length")
		local width = self:GetTalentSpecialValueFor("width")
		local delay = self:GetTalentSpecialValueFor("delay")
		local duration = self:GetTalentSpecialValueFor("duration")

		local point = ability:GetCursorPosition()

		if ability:GetCursorTarget() then
			point = ability:GetCursorTarget():GetAbsOrigin()
		end

		local direction = CalculateDirection(point, caster:GetAbsOrigin())
		self.start_pos = caster:GetAbsOrigin() + direction * 100
		self.end_pos = caster:GetAbsOrigin() + direction * length

		local pfx_ice_path_blob = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf", PATTACH_POINT, caster )
								  ParticleManager:SetParticleControl( pfx_ice_path_blob, 0, self.start_pos )
								  ParticleManager:SetParticleControl( pfx_ice_path_blob, 1, self.end_pos )
								  ParticleManager:SetParticleControl( pfx_ice_path_blob, 2, Vector(duration, 0, 0) ) --Shorter duration as it needs to melt
		self:AttachEffect(pfx_ice_path_blob)

		local pfx_icicles = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf", PATTACH_POINT, caster )
							ParticleManager:SetParticleControl( pfx_icicles, 0, self.start_pos )
							ParticleManager:SetParticleControl( pfx_icicles, 1, self.end_pos )
							ParticleManager:SetParticleControl( pfx_icicles, 2, Vector( duration, 0, 0 ) )
							ParticleManager:SetParticleControl( pfx_icicles, 9, self.start_pos )
		self:AttachEffect(pfx_icicles)

		---- Ice path vision nodes ----
		local viewpoint_distance = width/2
		local viewpoint_amount = CalculateDistance(self.start_pos, self.end_pos)/viewpoint_distance
		local viewpoint_view = width + 5 -- extra so we can see the units the Ice Path stuns on entry
		viewpoint_amount = math.floor(viewpoint_amount)
		local direction_vector = CalculateDirection(self.end_pos, self.start_pos)
		------------------------------

		self.hitUnits = {}

		Timers:CreateTimer(delay, function()
			-- Create flying vision nodes
			--[[local current_point = self.start_pos
			for i=1,viewpoint_amount do
				AddFOWViewer(caster:GetTeamNumber(), current_point, viewpoint_view, duration, false)
				current_point = current_point + direction_vector * viewpoint_distance
			end]]
			-- Apply effect immediately after delay
			--self:OnIntervalThink()
			-- Run applying effects on interval
			EmitSoundOnLocationWithCaster(self.end_pos, "Hero_Jakiro.IcePath", caster)
			self:OnIntervalThink()
			self:StartIntervalThink( 0.5 )
		end)
	end
end

function modifier_jakiro_ice_path_bh:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Jakiro.IcePath", self:GetCaster())
	end
end

function modifier_jakiro_ice_path_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local width = self:GetTalentSpecialValueFor("width")
	local enemies = caster:FindEnemyUnitsInLine(self.start_pos, self.end_pos, width, {})
	for _,enemy in pairs(enemies) do
		if not self.hitUnits[enemy] then
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				enemy:Freeze(self:GetAbility(), caster, self:GetRemainingTime())
				local damage = self:GetTalentSpecialValueFor("damage")
				self:GetAbility():DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
			self.hitUnits[enemy] = true
		end
		
	end
end