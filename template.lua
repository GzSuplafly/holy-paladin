local addonName, _A = ...
--local mediaPath, _A = ...
--local _G = _A._G
--local U = _A.Cache.Utils


local GUI = {
}





local exeOnLoad = function()


    _A.Interface:ShowToggle("cooldowns", false)
    _A.Interface:ShowToggle("interrupts", false)
    _A.Interface:ShowToggle("aoe", false)

	_A.Interface:AddToggle({	
		key = 'autoDisease',
		name = 'AUTO DISPEL DISEASE/TOXIN IN PARTY',
		text = 'dispel specific diseases/toxins in dragonflight dungeons',
		icon ='Interface\\Icons\\Spell_holy_renew.png'
	})



end

local exeOnUnload = function()


end


local inCombat = function()
    local player = Object("player")
    if not player then return end
    local target = Object("target")
	local lowest = Object("lowest")
    --if not lowest then return end

	
	-- pause CR if CC locked
	if player:State("stun || fear || sleep || disorient || incapacitate") then
		return 
	end

	-- pause
    if player:keybind("lalt") then
		return
    end
	
	-- cancel protection
	if IsMounted() then
		return
	end

    -- divine steed
    if player:CanCast("Divine Steed")
	and not player:buff("Divine Steed") then
		if player:keybind("lshift")
		and not player:Lastcast("Divine Steed") then
			--return
			player:Cast("Divine Steed")
		end
    end
	

	
	-- Lay on Hands
    if player:CanCast("Lay on Hands")
    and player:health() < 20
	and not player:debuff("Forbearance") then
        return player:Cast("Lay on Hands")
    end
	
	-- Lay on Hands on lowest
    if player:CanCast("Lay on Hands")
	and lowest
	and lowest:health() < 40
	and lowest:distance() < 35
	and lowest:los()
	and player:health() > 70
	and not lowest:debuff("Forbearance") then
        return lowest:Cast("Lay on Hands")
    end
	


	-- dungeon dispel start
	if IsInGroup() and IsInInstance() then
	
		if player:toggle('autoDisease')
		and player:CanCast("Cleanse Toxins")
		and player:mana() > 11 then

			
			
			--player	
			if player:debuffCountAny("Creeping Mold") > 2  -- disease / nature dot stacks
			then
				return player:Cast("Cleanse Toxins")
			end


			--lowest
			if lowest
			and lowest:los()
			and IsSpellInRange("Flash of Light", lowest.key) == 1
			then

				if lowest:debuffCountAny("Decaying Spores") > 2  -- disease / plague dmg (underrot)
				then
					return lowest:Cast("Cleanse Toxins")
				end
			end
			
		end
		
	end
	-- dungeon dispel end







	-- interrupt
	if target
	and player:CanCast("Rebuke")
	and target:enemy()
	and IsSpellInRange("Rebuke", target) == 1
	and target:combat()
	and target:alive()
	and target:infront()
	and target:interruptAt(40) then
		return target:Cast("Rebuke")
	end


    -- dps on target
    if target
    and target:enemy()
	and target:alive()
	and target:infront()
	then

		-- triggers autoattack if not active
		if IsSpellInRange("Rebuke", target) == 1
		-- rebuke for rangecheck is an precise alternative for meleerange (5y)
		and not player:AutoAttack() then
			_A.AttackTarget()
		end

		-- Shield of Righteous divine buff
		if player:CanCast("Shield of the Righteous")
		and IsSpellInRange("Rebuke", target) == 1
		and player:buff("Divine Purpose") then
			return target:Cast("Shield of the Righteous")
		end

		-- Judgement
		if player:CanCast("Judgment") -- US client Judgment / UK client Judgement
		-- Judgement rangecheck doesnt work on firestorm that why we just use another
		-- spell with similar range that work like avengers shield
		and IsSpellInRange("Avenger's Shield", target) == 1
		then
			return target:Cast("Judgment")
		end

		-- Hammer of Righteous single
		if player:CanCast("Hammer of the Righteous")
		and IsSpellInRange("Rebuke", target) == 1
		then
			return target:Cast("Hammer of the Righteous")
		end


    end



end



local outCombat = function()
    local player = Object("player")
    if not player then return end
    local target = Object("target")
	local lowest = Object("lowest")
    --if not lowest then return end



	-- self dispel decay ore / herb
	if not IsInInstance() then
		if player:CanCast("Cleanse Toxins")
		and player:debuff(391404) -- coated in decay (disease)
		then
			return player:Cast("Cleanse Toxins")
		end
	end

	-- pause keybind
    if player:keybind("lalt") then
		return
    end

	-- bag / mount pause
	if IsMounted()
	or IsBagOpen(0) -- backpack default
	or IsBagOpen(-1) -- bank default
	then
		--print("default bag is up?", IsBagOpen(0))
		return
	end
	
	if _A.ArkInventory then
		if _A.ArkInventory.Frame_Main_Get( _A.ArkInventory.Const.Location.Bag ):IsVisible( ) -- mainframe ark inventory
		then
		--print("arkinv is up")
			return
		end
	end
	
	if _A.Bagnon then
		if _A.Bagnon.Frames:IsShown('inventory') -- mainframe bagnon
		then
		--print("bagnon is up")
			return
		end
	end
	


    -- divine steed
    if player:CanCast("Divine Steed")
	and not player:buff("Divine Steed") then
		if player:keybind("lshift")
		and not player:Lastcast("Divine Steed") then
			--return
			player:Cast("Divine Steed")
		end
    end


	
	-- flash of light heal outcombat
	if player:CanCast("Flash of Light")
	and player:mana() > 11
	and not player:moving() then
		if player:health() < 80 then
			return player:Cast("Flash of Light")
		end
		
		if lowest
		and lowest:health() < 80
		and lowest:distance() < 35
		and lowest:los() then
			return lowest:Cast("Flash of Light")
		end
	end



	

end


_A.CR:Add(66, {
	name = "Prot | Pala Template by ZoDDeL",
	ic = inCombat,
	ooc = outCombat,
	use_lua_engine = true,
	gui = GUI,
	wow_ver = "10.1.7",
	apep_ver = "1.1",
	--pooling = true,
	load = exeOnLoad,
	unload = exeOnUnload
})
