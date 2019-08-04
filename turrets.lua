--Controllable Turrets System By Factis699--
--To set up turret do followig steps:
--1. Open map editor
--2. In your map place entty "Env_Item"
--3. In the name write: create_turret
--4. After space write path of unmovement image (will be covered by player)
--5. After space write path of movement image (will cover player and moved with him)
--6. After space write ID of an item that be equipped when player sit in turret
--7. After space write Damage of an turret
--8. After space write Name of an turret (will be showed on kill)
--9. Press okay, save map, Yer Done!
--Example: create_turret gfx/turrets/part1.png gfx/turrets/part2.png 40 50 Gatling

function totable(t,match)
	local cmd = {}
	if not match then match = "[^%s]+" end
	for word in string.gmatch(t, match) do
		table.insert(cmd, word)
	end
	return cmd
end

function array(m, h)
	local f = {}
	for id = 1, m do
		f[id] = h
	end
	return f
end

entered = array(32, 0)
weapons = array(32, {})
weapon_type = array(32, 0)
turrets = {}
next_var = 1

addhook('drop', 'drop_hook')
addhook('startround', 'startround_hook')
addhook('ms100', 'ms100_hook')
addhook('use', 'use_hook')
addhook('hit', 'hit_hook')
addhook('die', 'die_hook')
addhook('leave', 'leave_hook')

for y = 0, map'ysize' do
	for x = 0, map'xsize' do
		if entity(x, y, 'typename') == 'Env_Item' then
			local g = totable(entity(x, y, 'name'))
			if g[1] == 'create_turret' then	
				turrets[next_var] = {}
				turrets[next_var][1] = image(g[2], x * 32 + 16, y * 32 + 16, 0)
				turrets[next_var][2] = image(g[3], x * 32 +16, y * 32 + 16, 3)
				turrets[next_var][3] = tonumber(g[4])  
				turrets[next_var][4] = tonumber(g[5])
				turrets[next_var][5] = x
				turrets[next_var][6] = y
				turrets[next_var][7] = g[6]
				turrets[next_var][8] = g[2]
				turrets[next_var][9] = g[3]
				next_var = next_var + 1
			end
		end
	end
end

function startround_hook()
	for n, w in ipairs(turrets) do
		w[1] = image(w[8], w[5] * 32 + 16, w[6] * 32 + 16, 0)
		w[2] = image(w[9], w[5] * 32 + 16, w[6] * 32 + 16, 3)
	end
	for id = 1, 32 do
		entered[id] = 0
		parse('speedmod '.. id ..' 0')
	end
end

function use_hook(id, event, data, x, y)
	for n, w in ipairs(turrets) do
		if player(id, 'tilex') == w[5] and player(id, 'tiley') == w[6] then
			if entered[id] == 0 then
				for p =	1, 32 do
					if entered[p] == n then
						return
					end
				end
				entered[id] = n
				weapons[id] = playerweapons(id)
				weapon_type[id] = player(id, 'weapontype')
				parse('strip '.. id ..' 0')
				parse('equip '.. id ..' '.. w[3])
				parse('strip '.. id ..' 50')
				parse('setpos '.. id ..' '.. w[5] * 32 + 16 ..' '.. w[6] * 32 + 16)
				parse('speedmod '.. id ..' -100')
				freeimage(turrets[n][2])
				w[2] = image(w[9], 1, 1, 132 + id)
			else
				entered[id] = 0
				parse('strip '.. id ..' 0')
				for nn, ww in ipairs(weapons[id]) do
					parse('equip '.. id ..' '.. ww)
				end
				parse('setweapon '.. id ..' '.. weapon_type[id])
				parse('speedmod '.. id ..' 0')
				freeimage(w[2])
				w[2] = image(w[9], w[5] * 32 + 16, w[6] * 32 + 16, 3)
				imagepos(w[2], w[5] * 32 + 16, w[6] * 32 + 16, player(id, 'rot'))
			end
		end
	end
end

function ms100_hook()
	for id = 1, 32 do
		if entered[id] ~= 0 then
			if player(id, 'x') ~= turrets[entered[id]][5] * 32 + 16 or player(id, 'y') ~= turrets[entered[id]][6] * 32 + 16 then
				parse('setpos '.. id ..' '.. turrets[entered[id]][5] * 32 + 16 ..' '.. turrets[entered[id]][6] * 32 + 16)
			end
		end
	end
end

function hit_hook(id, source, weapon, hpdmg, apdmg)
    if entered[source] ~= 0 then
		if player(id, 'team') == player(source, 'team') then return 1 end
        if player(id, 'health') - turrets[entered[source]][4] <= 0 then
            parse('customkill '.. source ..' '.. turrets[entered[source]][7] ..' '.. id)
        else
            parse('sethealth '.. id ..' '.. player(id, 'health') - turrets[entered[source]][4])
        end
        return 1
    end
end

function die_hook(victim, killer, weapon, x, y)
	if entered[victim] ~= 0 then
		freeimage(turrets[entered[victim]][2])
		turrets[entered[victim]][2] = image(turrets[entered[victim]][9], turrets[entered[victim]][5] * 32 + 16, turrets[entered[victim]][6] * 32 + 16, 3)
		imagepos(turrets[entered[victim]][2], turrets[entered[victim]][5] * 32 + 16, turrets[entered[victim]][6] * 32 + 16, player(victim, 'rot'))
		entered[victim] = 0
		return 1
	end
end

function leave_hook(id)
	if entered[id] ~= 0 then
		freeimage(turrets[entered[id]][2])
		turrets[entered[id]][2] = image(turrets[entered[id]][9], turrets[entered[id]][5] * 32 + 16, turrets[entered[id]][6] * 32 + 16, 3)
		imagepos(turrets[entered[id]][2], turrets[entered[id]][5] * 32 + 16, turrets[entered[id]][6] * 32 + 16, player(id, 'rot'))
		entered[id] = 0
	end
end

function drop_hook(id, iid, type, ain, a, mode, x, y)
	if entered[id] ~= 0 then
		return 1
	end
end