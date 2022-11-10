-- MOUSE PLAY SCRIPT

function onCreate()
	-- triggered when the lua file is started
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);
end

function onDestroy()
	-- triggered when the lua file is ended (Song fade out finished)
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', false);
end

local stopAnimTimer = 0;
local targetTime = 0;

function onUpdatePost(elapsed)
	-- end of "update"
	setProperty('boyfriend.stunned', true); --stop boyfriend from hitting notes normally
	mouseX = getMouseX('hud') - 55;
	mouseY = getMouseY('hud') - 50;
	noteCount = getProperty('notes.length');

	for i = 0, noteCount-1 do
		if getPropertyFromGroup('notes', i, 'mustPress') then
			noteX = getPropertyFromGroup('notes', i, 'x');
			noteY = getPropertyFromGroup('notes', i, 'y');

			hitbox = 60;
			isSustainNote = getPropertyFromGroup('notes', i, 'isSustainNote');
			if isSustainNote then
				noteX = noteX - 20;
			else
				noteX = noteX - 5;
				noteY = noteY + 20;
			end

			if math.abs(noteX - mouseX) <= hitbox and math.abs(noteY - mouseY) <= hitbox then
				playSound('scrollMenu', 0.25);
				addScore(350);
				addHits(1);

				noteData = getPropertyFromGroup('notes', i, 'noteData');
				noteType = getPropertyFromGroup('notes', i, 'noteType');
				if noteType == 'Hurt Note' then
					characterPlayAnim('boyfriend', 'hurt', true);
				else
					if noteData == 0 then
						characterPlayAnim('boyfriend', 'singLEFT', true);
					elseif noteData == 1 then
						characterPlayAnim('boyfriend', 'singDOWN', true);
					elseif noteData == 2 then
						characterPlayAnim('boyfriend', 'singUP', true);
					elseif noteData == 3 then
						characterPlayAnim('boyfriend', 'singRIGHT', true);
					end
					stopAnimTimer = 0;
					targetTime = stepCrochet * 0.001 * getProperty('boyfriend.singDuration');
				end

				if noteType == 'Hey!' then
					characterPlayAnim('boyfriend', 'hey', true);
					setProperty('boyfriend.heyTimer', 0.6);
					characterPlayAnim('gf', 'hey', true);
					setProperty('gf.heyTimer', 0.6);
				elseif noteType == 'Hurt Note' then
					if not isSustainNote then
						setProperty('health', getProperty('health') - 0.15);
					else
						setProperty('health', getProperty('health') - 0.03);
					end
				else
					if not isSustainNote then
						setProperty('health', getProperty('health') + 0.023);
					else
						setProperty('health', getProperty('health') + 0.004);
					end
				end
				removeFromGroup('notes', i);
				setProperty('vocals.volume', 1);
				break;
			end
		end
	end

	stopAnimTimer = stopAnimTimer + elapsed;
	if targetTime > 0 and stopAnimTimer > targetTime then
		characterPlayAnim('boyfriend', 'danceLeft');
		characterPlayAnim('boyfriend', 'idle');
		targetTime = 0;
		stopAnimTimer = 0;
	end
end

function onPause()
	-- Called when you press Pause while not on a cutscene/etc
	-- return Function_Stop if you want to stop the player from pausing the game
	return Function_Continue;
end

function onResume()
	-- Called after the game has been resumed from a pause (WARNING: Not necessarily from the pause screen, but most likely is!!!)
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);
end

function onGameOver()
	-- You died! Called every single frame your health is lower (or equal to) zero
	-- return Function_Stop if you want to stop the player from going into the game over screen
	setPropertyFromClass('flixel.FlxG', 'mouse.visible', false);
	return Function_Continue;
end