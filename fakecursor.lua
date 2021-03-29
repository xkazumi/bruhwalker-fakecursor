fake_cursor_category = menu:add_category("fake cursor")
fake_cursor_enabled = menu:add_checkbox("enabled", fake_cursor_category, 1)
fake_cursor_speed = menu:add_slider("factor", fake_cursor_category, 5, 30, 20)
spawn_fake_clicks = menu:add_checkbox("spawn fake click", fake_cursor_category, 1)
fake_click_delay = menu:add_slider("fake click delay", fake_cursor_category, 0, 1000, 200)

if file_manager:file_exists("Cursor.png") then
	sprite = renderer:add_sprite("Cursor.png", 28, 40)
	sprite2 = renderer:add_sprite("Attack.png", 26, 44)

	console:log("fake cursor by kazumi successfully loaded!")
end

draw_pos = game.mouse_2d
draw_pos_last = game.mouse_2d
cast_pos = 0
last_cast_time = 0.0

local function is_inregion(m1, m2, x, y)
	x = x - 10
	x2 = x + 20
	
	y = y - 10
	y2 = y + 20

	if m1 > x and m2 > y and m1 < x2 and m2 < y2 then
		return true
	else
		return false
	end
end

local function is_inregion2(m1, m2, x, y)
	x = x - 80
	x2 = x + 160
	
	y = y - 80
	y2 = y + 160

	if m1 > x and m2 > y and m1 < x2 and m2 < y2 then
		return true
	else
		return false
	end
end

moving = false
moving2 = false

local function on_draw()
	if menu:get_value(spawn_fake_clicks) == 1 then
		mode = combo:get_mode()

		if mode == MODE_COMBO or mode == MODE_ORBWALKER or mode == MODE_LANECLEAR or mode == MODE_LASTHIT or mode == MODE_HARASS or mode == MODE_FLEE then
			game:spawn_fake_click(menu:get_value(fake_click_delay))
		end
	end

	if menu:get_value(fake_cursor_enabled) == 1 then
		speed = menu:get_value(fake_cursor_speed)
		draw_attack_icon = false

		under_mouse_object = game.under_mouse_object

		if under_mouse_object.is_enemy then
			draw_attack_icon = true
		end 

		if moving2 then
			if moving then
				tx = cast_pos.x
				ty = cast_pos.y
				sx = draw_pos_x 
				sy = draw_pos_y 
		
				deltaX = tx - sx;
				deltaY = ty - sy;
				angle = math.atan2( deltaY, deltaX )
				
				distance = cast_pos:dist_to(draw_pos_x, draw_pos_y, 0)
				speed_move = distance / speed
		
				draw_pos_x = draw_pos_x + speed_move * math.cos( angle );
				draw_pos_y = draw_pos_y + speed_move * math.sin( angle );
				
				if is_inregion(draw_pos_x, draw_pos_y, tx, ty) then
					moving = false
				end

				if is_inregion2(draw_pos_x, draw_pos_y, tx, ty) then
					draw_attack_icon = true
				end
			elseif moving2 then
				draw_pos = game.mouse_2d
				tx = draw_pos.x
				ty = draw_pos.y
				sx = draw_pos_x 
				sy = draw_pos_y 

				deltaX = tx - sx;
				deltaY = ty - sy;
				angle = math.atan2( deltaY, deltaX )

				distance = draw_pos:dist_to(draw_pos_x, draw_pos_y, 0)
				speed_move = distance / speed
		
				draw_pos_x = draw_pos_x + speed_move * math.cos( angle );
				draw_pos_y = draw_pos_y + speed_move * math.sin( angle );

				if is_inregion(draw_pos_x, draw_pos_y, tx, ty) then
					moving2 = false
				end

				if is_inregion2(draw_pos_x, draw_pos_y, cast_pos.x, cast_pos.y) then
					draw_attack_icon = true
				end
			end

			if draw_attack_icon then
				sprite2:draw(draw_pos_x, draw_pos_y)
			else
				sprite:draw(draw_pos_x, draw_pos_y)
			end
		else
			draw_pos = game.mouse_2d
			
			if draw_attack_icon then
				sprite2:draw(draw_pos.x, draw_pos.y)
			else
				sprite:draw(draw_pos.x, draw_pos.y)
			end
		end
	end
end

local function on_cast_skill(pos)
	cast_pos = vec3.new(pos.x + math.random(-15,20), pos.y + math.random(-15,20), 0)

	if not moving then
		moving = true
		moving2 = true
		draw_pos_last = game.mouse_2d
		draw_pos_x = draw_pos_last.x
		draw_pos_y = draw_pos_last.y
	end
	last_cast_time = game.game_time
end

client:set_event_callback("on_draw_always", on_draw)
client:set_event_callback("on_cast_skill", on_cast_skill)