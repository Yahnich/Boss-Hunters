puppeteer_mass_of_flesh = class({})

function puppeteer_mass_of_flesh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local direction = CalculateDirection(caster, position)
	local tangentDir = Vector(direction.y, -direction.x)
	
	local length = self:GetSpecialValueFor("length")
	local segments = math.ceil(length / 80) -- (rough hull radius)
	
	local collectionDummy = caster:CreateSummon("npc_dota_puppeteer_mass_of_flesh", position)
	collectionDummy:AddNewModifier(caster, self, "modifier_wall_of_flesh_handler", {duration = self:GetSpecialValueFor("duration")})
	collectionDummy.wallTable = {}
	
	local talentAngle = 0
	if caster:HasTalent("puppeteer_mass_of_flesh_talent_1") then
		length = length * 0.75
		segments = (length*math.pi / 80)
	end
	
	for i = 1, segments do
		if caster:HasTalent("puppeteer_mass_of_flesh_talent_1") then
			local placePos = Vector(position.x+length*math.sin(talentAngle), position.y+length*math.cos(talentAngle), 0)
			self:CreateWallSegment(placePos, collectionDummy)
			talentAngle = talentAngle + 2*math.pi/segments
		else
			local placePos = position + tangentDir * 80 * (i / 2) *(-1)^i
			self:CreateWallSegment(placePos, collectionDummy)
		end
	end
end

function puppeteer_mass_of_flesh:CreateWallSegment(pos, collectionDummy)
	local caster = self:GetCaster()
	local wall = CreateUnitByName("npc_dota_puppeteer_mass_of_flesh", pos, false, nil, nil, caster:GetTeam())
	local wallType = RandomInt(1,3)
	wall:AddNewModifier(caster, self, "modifier_wall_of_flesh_segment_handler", {})
	wall:SetModel("models/props_debris/riveredge_rocks_small00"..wallType.."_snow.vmdl")
	EmitSoundOn("Hero_Shredder.Attack.Post", wall)
	EmitSoundOn("Hero_Pudge.Dismember", wall)
	EmitSoundOnLocationWithCaster(pos, "Hero_Shredder.Attack.Post", caster)
	EmitSoundOnLocationWithCaster(pos, "Hero_Pudge.Dismember", caster)
	if wallType == 1 then
		local currScale = 5 * FrameTime()
		Timers:CreateTimer(FrameTime(), function() 
			if currScale < 1.5 then
				wall:SetModelScale(currScale + 5 * FrameTime())
				currScale = currScale + 5 * FrameTime()
				return FrameTime()
			end
		end)
	elseif wallType == 2 then
		local currScale = 5 * FrameTime()
		Timers:CreateTimer(FrameTime(), function() 
			if currScale < 2.1 then
				wall:SetModelScale(currScale + 5 * FrameTime())
				currScale = currScale + 5 * FrameTime()
				return FrameTime()
			end
		end)
	elseif wallType == 3 then
		local currScale = 5 * FrameTime()
		Timers:CreateTimer(FrameTime(), function() 
			if currScale < 2.8 then
				wall:SetModelScale(currScale + 5 * FrameTime())
				currScale = currScale + 5 * FrameTime()
				return FrameTime()
			end
		end)
	end
	wall:SetRenderColor( 150, 80, 80 )
	table.insert(collectionDummy.wallTable, wall)
end

LinkLuaModifier("modifier_wall_of_flesh_handler", "heroes/puppeteer/puppeteer_mass_of_flesh.lua", LUA_MODIFIER_MOTION_NONE)
modifier_wall_of_flesh_handler = class({})

if IsServer() then
	function modifier_wall_of_flesh_handler:OnRemoved()
		for _, wallSegment in ipairs(self:GetParent().wallTable) do
			local scale = wallSegment:GetModelScale()
			Timers:CreateTimer(FrameTime(), function() 
				if scale > 0.3 then
					wallSegment:SetModelScale(scale - 5 * FrameTime())
					scale = scale - 5 * FrameTime()
					return FrameTime()
				else
					wallSegment:RemoveSelf()
				end
			end)
		end
	end
end

function modifier_wall_of_flesh_handler:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end


LinkLuaModifier("modifier_wall_of_flesh_segment_handler", "heroes/puppeteer/puppeteer_mass_of_flesh.lua", LUA_MODIFIER_MOTION_NONE)
modifier_wall_of_flesh_segment_handler = class({})
if IsServer() then
	function modifier_wall_of_flesh_segment_handler:OnCreated( kv )
		self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
		self.damage = self:GetAbility():GetSpecialValueFor("aura_damage")

		local stun_radius = self:GetAbility():GetSpecialValueFor("stun_radius")
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		local damage_on_hit = self:GetAbility():GetSpecialValueFor("damage_on_hit")
		
		local rot = ParticleManager:CreateParticle("particles/heroes/puppeteer/puppeteer_wall_of_flesh_plague.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(rot, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(rot, 1, Vector( self.aura_radius + 128, 1, 1 ) )
		self:AddParticle(rot, false, false, 0, false, false)
		
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
									  self:GetParent():GetAbsOrigin(),
									  nil,
									  stun_radius,
									  DOTA_UNIT_TARGET_TEAM_ENEMY,
									  DOTA_UNIT_TARGET_ALL,
									  DOTA_UNIT_TARGET_FLAG_NONE,
									  FIND_ANY_ORDER,
									  false)
		for _, enemy in ipairs(enemies) do
			if not enemy.hitByWallOfFlesh then
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned_generic", {duration = stun_duration})
				ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = damage_on_hit, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
				enemy.hitByWallOfFlesh = true
			end
		end
		for _, enemy in ipairs(enemies) do
			FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), true)
			enemy.hitByWallOfFlesh = nil
		end
	end
end

function modifier_wall_of_flesh_segment_handler:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_wall_of_flesh_segment_handler:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_wall_of_flesh_segment_handler:GetModifierAura()
	return "modifier_wall_of_flesh_segment_aura"
end

--------------------------------------------------------------------------------

function modifier_wall_of_flesh_segment_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_wall_of_flesh_segment_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_wall_of_flesh_segment_handler:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_wall_of_flesh_segment_handler:IsPurgable()
    return false
end


function modifier_wall_of_flesh_segment_handler:CheckState()
    local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

LinkLuaModifier( "modifier_wall_of_flesh_segment_aura", "heroes/puppeteer/puppeteer_mass_of_flesh.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_wall_of_flesh_segment_aura = class({})

if IsServer() then
	function modifier_wall_of_flesh_segment_aura:OnCreated()
		self:StartIntervalThink(1)
	end
	
	function modifier_wall_of_flesh_segment_aura:OnIntervalThink()
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("aura_damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
	end
end