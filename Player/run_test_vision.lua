local cwd = os.getenv('PWD') 
require('init')
require('Config')
require('unix')
require('getch')
require('shm')
require('vector')
require('mcm')
require('vcm')
require('wcm')
require('Speak')
require('Body')
require('Motion')
require('gcm')
require ('UltraSound')
require("World")

--require('Broadcast')
require('log_sensor_positions')

UltraSound.entry()

wcm.set_process_broadcast(1) --enable broadcasting


gcm.say_id()

smindex = 0;

Motion.entry();
darwin = false;
webots = false;

-- Enable OP specific 
if(Config.platform.name == 'OP') then
  darwin = true;
end

--enable new nao specific
--TODO: auto-detect using hostname
newnao = true;

getch.enableblock(1);
unix.usleep(1E6*1.0);
Body.set_body_hardness(0);

--This is robot specific 
webots = false;
init = false;
calibrating = false;
ready = false;
if( webots or darwin) then
  ready = true;
end

--State variables
initToggle = true;
targetvel=vector.zeros(3);
headangle=vector.new({0,0*math.pi/180});
headsm_running=0;
bodysm_running=0;

local count = 0;
local ncount = 100;
local imagecount = 0;
local t0 = unix.time();
local tUpdate = t0;

-- Broadcast the images at a lower rate than other data
local broadcast_enable=0;
local imageCount=0;

-- set game state to ready to stop init particle filter during debugging
gcm.set_game_state(1);
--gcm.set_game_penalty(0);


-- main loop
count = 0;
lcount = 0;
tUpdate = unix.time();
Config.fsm.playMode=1; --Always demo mode
fsm.enable_walkkick = 0;
fsm.enable_sidekick = 0;
broadcast_enable=0;
button_pressed = {0,0};

function process_keyinput()
  --Robot specific head pitch bias
  headPitchBiasComp = mcm.get_walk_headPitchBiasComp();
  headPitchBias = mcm.get_headPitchBias()

  --Toggle body SM when button is pressed and then released
  if (Body.get_change_state() == 1) then
    button_pressed[1]=1;
  else
    if button_pressed[1]==1 then
      if bodysm_running==0 then 
        Motion.event("standup");
        Body.set_head_hardness(0.5);
        vcm.set_camera_learned_new_lut(1)
        headsm_running=1;
        bodysm_running=1;
        BodyFSM.sm:set_state('bodySearch');   
        HeadFSM.sm:set_state('headScan');
        walk.start();
      else
        headsm_running=0;
        Body.set_head_hardness(0);
        Body.set_head_command({0,0});

        if walk.active then walk.stop();end
        bodysm_running=0;
        Motion.event("sit");
      end
    end
    button_pressed[1]=0;
  end

  if (Body.get_change_role() == 1) then
    button_pressed[2]=1;
  else
    if button_pressed[2]==1 then
      --[[
      if broadcast_enable == 0 then 
        broadcast_enable = 2;
        Speak.talk('enable broadcasting');
      else
        broadcast_enable = 0
        Speak.talk('disable broadcasting');
      end
      --]]
    end
    button_pressed[2]=0;
  end


  local str=getch.get();
  if #str>0 then

    local byte=string.byte(str,1);
    -- Walk velocity setting
    if byte==string.byte("i") then	targetvel[1]=targetvel[1]+0.02;
    elseif byte==string.byte("j") then	targetvel[3]=targetvel[3]+0.1;
    elseif byte==string.byte("k") then	targetvel[1],targetvel[2],targetvel[3]=0,0,0;
    elseif byte==string.byte("l") then	targetvel[3]=targetvel[3]-0.1;
    elseif byte==string.byte(",") then	targetvel[1]=targetvel[1]-0.02;
    elseif byte==string.byte("h") then	targetvel[2]=targetvel[2]+0.02;
    elseif byte==string.byte(";") then	targetvel[2]=targetvel[2]-0.02;


    -- Move the head around
    elseif byte==string.byte("w") then
      headsm_running=0;headangle[2]=math.max(0,headangle[2]-5*math.pi/180)
    elseif byte==string.byte("a") then
      headsm_running=0;headangle[1]=headangle[1]+5*math.pi/180;
    elseif byte==string.byte("d") then
      headsm_running=0;headangle[1]=headangle[1]-5*math.pi/180;
    elseif byte==string.byte("x") then
      headsm_running=0;headangle[2]=headangle[2]+5*math.pi/180;
    elseif byte==string.byte("s") then
      headsm_running=0;headangle[1],headangle[2]=0,0;

    -- Head pitch fine tuning (for camera angle calibration)
    elseif byte==string.byte("e") then	
      headsm_running=0;headangle[2]=headangle[2]-1*math.pi/180;
    elseif byte==string.byte("c") then
      headsm_running=0;headangle[2]=headangle[2]+1*math.pi/180;

    -- Head FSM testing
    elseif byte==string.byte("1") then	
      headsm_running = 1-headsm_running;
      if (headsm_running == 1) then
        Body.set_head_hardness(0.5);
        HeadFSM.sm:set_state('headScan');
      end

    elseif byte==string.byte("2") then	
    -- Camera transform testing
      headsm_running = 0;
      local ball = wcm.get_ball();
      local trackZ = Config.vision.ball.diameter/2; 
      -- TODO: Nao needs to add the camera select
      headangle = vector.zeros(2);
      headangle[1],headangle[2] = 
     	HeadTransform.ikineCam(ball.x,	ball.y, trackZ);
      headangle[2]=headangle[2]+headPitchBias; 
	--this is substracted below
      print("Head Angles for looking directly at the ball:", 
    	unpack(headangle*180/math.pi));

    elseif byte==string.byte("f") then
      behavior.cycle_behavior();

    --For localization debugging
    elseif byte==string.byte("z") then
      wcm.set_robot_resetWorld(1);
      print("World Reset")

    --Logging mode

    elseif byte==string.byte("3") then
      Body.set_head_hardness(0.4);
      HeadFSM.sm:set_state('headLog');
      headsm_running=1;

    elseif byte==string.byte("4") then
      Body.set_head_hardness(0.4);
      HeadFSM.sm:set_state('headScan');
      headsm_running=1;

    elseif byte==string.byte("5") then
    --Turn on body SM
      headsm_running=1;
      bodysm_running=1;
      Body.set_head_hardness(0.5);
      BodyFSM.sm:set_state('bodySearch');   
      HeadFSM.sm:set_state('headScan');

      walk.start();

    elseif byte==string.byte("6") then
      headsm_running=0;
      headangle[1]=0;
      headangle[2]= Config.fsm.headKick.pitch0;

      local ball = wcm.get_ball();
      footX = Config.walk.footX or 0;
      print("foot center to ball pos: ",ball.x,ball.y);      

    elseif byte==string.byte("g") then	
      --Broadcast selection
      local broadcast_enable=(3-wcm.get_process_broadcast())
      wcm.set_process_broadcast(broadcast_enable)
      print("\nBroadcast:", broadcast_enable);

    --Left kicks (for camera angle calibration)
--    elseif byte==string.byte("3") then	
--      kick.set_kick("kickForwardLeft");
--      Motion.event("kick");
    elseif byte==string.byte("t") then
      walk.doWalkKickLeft();
    elseif byte==string.byte("y") then
      walk.doSideKickLeft();
    elseif byte==string.byte("7") then	
      headsm_running,bodysm_running=0,0;
      Motion.event("sit");
    elseif byte==string.byte("8") then	
      if walk.active then walk.stop();end
      bodysm_running=0;
      Motion.event("standup");
    elseif byte==string.byte("9") then	
      Motion.event("walk");
      walk.start();
    elseif byte==string.byte("0") then	
      Motion.event("diveready");
    elseif byte==string.byte('p') then
      require('ColorLUT')
      ColorLUT.learn_lut_from_mask();
    end


    walk.set_velocity(unpack(targetvel));
    if headsm_running == 0 then
      Body.set_head_command({headangle[1],headangle[2]-headPitchBias});
      print("\nHead Yaw Pitch:", unpack(headangle*180/math.pi))
      print('Head angle is'..headangle[2]-headPitchBias)
    end
  end
end


function update()
  count = count + 1;
  --Update battery info
  wcm.set_robot_battery_level(Body.get_battery_level());
  --Set game state to SET to prevent particle resetting
  gcm.set_game_state(1);

--  headAngle = Body.get_head_position();
--  print(headAngle[1], headAngle[2]);

  if (not init)  then
    if (calibrating) then
      if (Body.calibrate(count)) then
        Speak.talk('Calibration done');
        calibrating = false;
        ready = true;
      end
    elseif (ready) then
      -- initialize state machines
      package.path = cwd..'/BodyFSM/'..Config.fsm.body[smindex+1]..'/?.lua;'..package.path;
      package.path = cwd..'/HeadFSM/'..Config.fsm.head[smindex+1]..'/?.lua;'..package.path;
      require('BodyFSM')
      require('HeadFSM')

      BodyFSM.entry();
      HeadFSM.entry();

      init = true;
    else
      if (count % 20 == 0) then
--start calibrating without waiting 
--        if (Body.get_change_state() == 1) then
          Speak.talk('Calibrating');
          calibrating = true;
--        end
      end
      -- toggle state indicator
      if (count % 100 == 0) then
        initToggle = not initToggle;
        if (initToggle) then
          Body.set_indicator_state({1,1,1}); 
        else
          Body.set_indicator_state({0,0,0});
        end
      end
    end
  else
    -- update state machines 
    process_keyinput();
    
    Motion.update();
    Body.update();
    UltraSound.update()
    -- Keep setting monitor flag
    --[[
    vcm.set_camera_broadcast(broadcast_enable);
    
    -- always send non-image data
    Broadcast.update(broadcast_enable)
    -- send img data when necessary
    Broadcast.update_img(broadcast_enable)
    --]]
    if headsm_running>0 then
      HeadFSM.update();
    end
    if bodysm_running>0 then
      BodyFSM.update();
    end
  end
  local dcount = 50;
  if (count % 50 == 0) then
--    print('fps: '..(50 / (unix.time() - tUpdate)));
    tUpdate = unix.time();
    -- update battery indicator
    Body.set_indicator_batteryLevel(Body.get_battery_level());
  end
  
  -- check if the last update completed without errors
  lcount = lcount + 1;
  if (count ~= lcount) then
    print('count: '..count)
    print('lcount: '..lcount)
    Speak.talk('missed cycle');
    lcount = count;
  end
end

-- if using Webots simulator just run update
if (webots) then
  while (true) do
    -- update motion process
    update();
    io.stdout:flush();
  end
end

--Now nao are running main process separately too

t_last = Body.get_time()
if( darwin or newnao) then
  local tDelay = 0.005 * 1E6; -- Loop every 5ms
  while 1 do
    t=Body.get_time()
    tPassed = t-t_last
    t_last = t
    if tPassed>0.005 then
      update();
    end
    unix.usleep(tDelay);
  end
end
wcm.set_process_broadcast(0) --disable broadcasting on exit
