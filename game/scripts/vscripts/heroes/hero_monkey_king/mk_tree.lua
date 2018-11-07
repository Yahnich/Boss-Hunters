mk_tree = class({})
LinkLuaModifier("modifier_mk_tree_jump", "heroes/hero_monkey_king/mk_tree", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mk_tree_perch", "heroes/hero_monkey_king/mk_tree", LUA_MODIFIER_MOTION_NONE)

function mk_tree:IsStealable()
	return true
end

function mk_tree:IsHiddenWhenStolen()
	return false
end

function mk_tree:GetCastPoint()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_mk_tree_perch") then
		return 0
	end
	return 0.3
end

function mk_tree:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_MonkeyKing.TreeJump.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_mk_tree_jump", {Duration = 1})
end

modifier_mk_tree_jump = class({})

function modifier_mk_tree_jump:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_jump_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self.speed = self:GetTalentSpecialValueFor("leap_speed") * FrameTime()

		self.distance = CalculateDistance(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
		self.direction = CalculateDirection(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
		self.maxHeight = 192

		self.distanceTraveled = 0

		self:StartMotionController()
	end
end

function modifier_mk_tree_jump:OnRefresh(table)
	if IsServer() then
		self.speed = self:GetTalentSpecialValueFor("leap_speed") * FrameTime()
	end
end

function modifier_mk_tree_jump:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_mk_tree_jump:GetOverrideAnimation()
	return ACT_DOTA_MK_TREE_SOAR
end

function modifier_mk_tree_jump:DoControlledMotion()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()

		if self.distanceTraveled < (self.distance - self.speed) then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			local height = GetGroundHeight(parent:GetAbsOrigin(), parent)
			newPos.z = height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			if not parent:HasModifier("modifier_mk_tree_perch") then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_mk_tree_perch", {})
			end
			
			EmitSoundOn("Hero_MonkeyKing.TreeJump.Tree", parent)
			
			--parent:StartGesture(ACT_DOTA_MK_TREE_END)

			self:StopMotionController()
		end  
	end
end

function modifier_mk_tree_jump:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_FLYING] = true}
end

function modifier_mk_tree_jump:IsHidden()
	return true
end

modifier_mk_tree_perch = class({})

function modifier_mk_tree_perch:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_mk_tree_perch:OnIntervalThink()
	local caster = self:GetParent()
	if not GridNav:IsNearbyTree(caster:GetAbsOrigin(), caster:BoundingRadius2D(), true) then
		self:Destroy()
	end
end

function modifier_mk_tree_perch:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_mk_tree_perch:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_mk_tree_perch:OnOrder(params)
	if IsServer() then
		local unit = params.unit
		local parent = self:GetParent()
		local orderType = params.order_type

		if unit == parent then
			if (orderType == DOTA_UNIT_ORDER_MOVE_TO_TARGET) or (orderType == DOTA_UNIT_ORDER_ATTACK_MOVE) or (orderType == DOTA_UNIT_ORDER_ATTACK_TARGET) then
				
				FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
				self:Destroy()
			end
		end
	end
end

function modifier_mk_tree_perch:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_mk_tree_perch:GetActivityTranslationModifiers()
	return "perch"
end

function modifier_mk_tree_perch:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_FLYING] = true}
end

function modifier_mk_tree_perch:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_DAY_VISION,
			MODIFIER_PROPERTY_BONUS_NIGHT_VISION}
end

function modifier_mk_tree_perch:GetBonusDayVision()
	return 800
end

function modifier_mk_tree_perch:GetBonusNightVision()
	return 800
end