module(..., package.seeall);


require('Config');
--require('Body');
require('vector');
require('util')
require('cutil')
require('vcm')
require('wcm');
require('gcm');
require('ImageProc')

--Player ID: 1 to 5
--Role enum we used before
ROLE_GOALIE = 0
ROLE_ATTACKER = 1
ROLE_DEFENDER = 2
ROLE_SUPPORTER = 3
ROLE_DEFENDER2 = 4
ROLE_LOST = 5


--Role enum for std message
ROLE_STD_SUPPORTER = 0
ROLE_STD_GOALIE = 1
ROLE_STD_DEFENDER = 2
ROLE_STD_ATTACKER = 3
ROLE_STD_LOST = 4

local role_penn_to_std={
  ROLE_STD_GOALIE,
  ROLE_STD_ATTACKER,
  ROLE_STD_DEFENDER,
  ROLE_STD_SUPPORTER,
  ROLE_STD_DEFENDER,
  ROLE_STD_LOST,
}

local role_std_to_penn={
  ROLE_SUPPORTER,
  ROLE_GOALIE,
  ROLE_DEFENDER,
  ROLE_ATTACKER,
  ROLE_LOST,
}

function pack_float(f) --pack a floating number
  local packedf = util.mod_angle(f)
  return math.floor(packedf/2/math.pi*256)
end

function unpack_float(pack_f)
  return pack_f/256*2*math.pi
end


function pack_v(v) --pack pose xy into two bytes
  local v_byte={}
  v_byte[1] = math.max(-4.9,math.min(4.9,v[1]))
  v_byte[2] = math.max(-3.4,math.min(3.4,v[2]))
  v_byte[1] = math.floor((v_byte[1]+5)/10*256)
  v_byte[2] = math.floor((v_byte[2]+3.5)/7*256)
  return v_byte[1],v_byte[2]
end

function unpack_v(v_byte1, v_byte2)
  local v={}
  v[1] = v_byte1*10/256    - 5
  v[2] = v_byte2*7/256   - 3.5
  return v
end


function get_attack_bearing_pose(pose0)
  if gcm.get_team_color() == 1 then postAttack = Config.world.postCyan
  else postAttack = Config.world.postYellow end
  -- make sure not to shoot back towards defensive goal:
  local xPose = math.min(math.max(pose0.x, -0.99*Config.world.xLineBoundary),
                          0.99*Config.world.xLineBoundary)
  local yPose = pose0.y;
  local aPost = {}
  aPost[1] = math.atan2(postAttack[1][2]-yPose, postAttack[1][1]-xPose);
  aPost[2] = math.atan2(postAttack[2][2]-yPose, postAttack[2][1]-xPose);
  local daPost = math.abs(util.mod_angle(aPost[1]-aPost[2]));
  attackHeading = aPost[2] + .5*daPost;
  attackBearing = util.mod_angle(attackHeading - pose0.a);
  return attackBearing, daPost;
end


function convert_state_penn_to_std(sp)
  local goalAttack = wcm.get_goal_attack()
  local dir,abias = 1000,0
  if goalAttack[1]<0 then dir,abias = -1000,math.pi end
  local state = {
    version=7,
    playerNum = sp.id, --1 to 5
    teamNum = sp.teamNumber,
    fallen = sp.fall, -- 1 means the robot's fallend down
    pose = {sp.pose.x*dir,sp.pose.y*dir,util.mod_angle(sp.pose.a+abias)},
    --x(mm)/y(mm)/theta(rad)
    --Global coordinate, +x always towards the attacking goal
    --walkingTo = {sp.walkingTo[1]*dir, sp.walkingTo[2]*dir}, --x(mm)/y(mm)
    --shootingTo = {sp.shootingTo[1]*dir, sp.shootingTo[2]*dir},  --x(mm)/y(mm)
    ballAge = sp.ball.t_seen*1000, --ms till last saw the ball, -1 if we have never seen it
    ball = {sp.ball.x*1000,sp.ball.y*1000}, --x(mm)/y(mm), Local coordinate
    --ballVel = {sp.ball.vx*1000,sp.ball.vy*1000}, --x(mm)/y(mm), Local coordinate
    --suggestion = sp.suggestion,
    --intention = role_penn_to_std[sp.role+1], --0 nothing / 1 keeper / 2 defender / 3 attacker / 4 lost
    --averageWalkSpeed = sp.averageWalkSpeed,
    --maxKickDistance = sp.maxKickDistance,
    --currentPositionConfidence = sp.currentPositionConfidence*100,
    --currentSideConfidence = sp.currentSideConfidence,
    numOfDataBytes = 0,

    data={
      sp.teamNumber,	--Byte 1
      sp.penalty,	--Byte 2
      sp.battery_level,	--Byte 3

      -- Vision data
      sp.goal,		--Byte 4
      0,	--Byte 5

      0,0, --goalv1	--Byte 6 and 7
      0,0, --goalv2	--Byte 8 and 9
      0,0, --cornerv	--Byte 10 and 11

 --Centroid X Centroid Y Orientation Axis1 Axis2
      sp.goalB1[1],sp.goalB1[2],
      ((sp.goalB1[3]*180/math.pi+360)%360)/2,
      sp.goalB1[4],sp.goalB1[5],
      --goalB1 --Byte 12 to 16

      --goalB2 --Byte 17 to 21
      sp.goalB2[1],sp.goalB2[2],
      ((sp.goalB2[3]*180/math.pi+360)%360)/2,
      sp.goalB2[4],sp.goalB2[5],
      sp.ball.p*255, --Byte 22
      --Walking to Byte 23 and 24, times ten for decimal rep
      (sp.walkingTo[1]+5)*10, (sp.walkingTo[2]+3.5)*10,
      sp.role, --Byte 25 Role
      sp.currentPositionConfidence*100,--Byte 26 currentPositionConfidence
      --Bytes 27 to 31 are our local confidences in all teammates (including self)
      sp.teamConfidence[1]*255, sp.teamConfidence[2]*255, sp.teamConfidence[3]*255, sp.teamConfidence[4]*255, sp.teamConfidence[5]*255,
      sp.heatLevel, --Byte 32 heat rating
      }
  }

  --print("Player ", state.playerNum, " sent : ",  "Walking To : ", sp.walkingTo[1], sp.walkingTo[2], "role : ", sp.role, "posConf : ", sp.currentPositionConfidence);

  --put vision info in correct data bytes
  state.data[6],state.data[7]=pack_v(sp.goalv1)
  state.data[8],state.data[9]=pack_v(sp.goalv2)
  if (sp.corner ~= 0 and sp.cornerv[1]~=0 and sp.cornerv[2]~=0) then
    state.data[10],state.data[11]=pack_v(sp.cornerv)
    state.data[5]=pack_float(sp.corner)
  end

  --Figure out how much extra data we can send
  MaxDataBytes = 474; --specified by SPL
  cur_data_size = #state.data; -- should be 32
  extraBytes = math.min(#sp.data,MaxDataBytes-cur_data_size);

  --add as much extra data as we can
  for i=1,extraBytes do
    state.data[cur_data_size+i]=sp.data[i]
  end
  state.numOfDataBytes = #state.data;
  return state
end

function convert_state_std_to_penn(ss,teamnum)
--  util.printtable(ss)
  if not ss.playerNum then return end
  if not ss.data then return end
  if not teamnum then teamnum = Config.game.teamNumber end
  if ss.data[1] ~= teamnum then return end

  local goalAttack = wcm.get_goal_attack()
  local dir,abias = 0.001,0
  if goalAttack[1]<0 then dir,abias = -0.001,math.pi end

  local state = {
    id = ss.playerNum,
    teamNumber = ss.teamNum,
    fall=ss.fallen,
    pose = {x=ss.pose[1]*dir,y=ss.pose[2]*dir,a=util.mod_angle(ss.pose[3]+abias)},
    ball = {t_seen = ss.ballAge/1000, p = ss.data[22]/255,
            x=ss.ball[1]/1000, y=ss.ball[2]/1000--, vx=ss.ballVel[1]/1000, vy=ss.ballVel[1]/1000
            },
    role = ss.data[25],  --role_std_to_penn[ss.data[25]+1],

    walkingTo = {(ss.data[23]/10)-5, (ss.data[24]/10)-3.5},
    --shootingTo = {ss.shootingTo[1]*dir, ss.shootingTo[2]*dir},

    --Game state info
    attackBearing = get_attack_bearing_pose(
      {x=ss.pose[1]*dir,y=ss.pose[2]*dir,a=util.mod_angle(ss.pose[3]+abias)}),

    penalty = ss.data[2],
    battery_level = ss.data[3],
    --suggestion = ss.suggestion,
    --averageWalkSpeed = ss.averageWalkSpeed,
    --maxKickDistance = ss.maxKickDistance,
    currentPositionConfidence = ss.data[26]/100,
    --currentSideConfidence = ss.currentSideConfidence,
    teamConfidence = {ss.data[27]/255, ss.data[28]/255, ss.data[29]/255, ss.data[30]/255, ss.data[31]/255},

    heatLevel = ss.data[32], --replace with heatData

    --Added key vision infos
    goal = ss.data[4],

    corner = 0,

    goalv1=unpack_v(ss.data[6],ss.data[7]),
    goalv2=unpack_v(ss.data[8],ss.data[9]),
    cornerv={0,0},

    goalB1={
	ss.data[12],ss.data[13],
	ss.data[14]*math.pi/180*2,
	ss.data[15],ss.data[16]},

    goalB2={
	ss.data[17],ss.data[18],
	ss.data[19]*math.pi/180*2,
	ss.data[20],ss.data[21]},

    -- TODO
    tReceive = 0,
    gc_latency=0,
    tm_latency=0,
    body_state = 'dummy',
    robotName = 'whatever',
    labelBind = 0,
    labelB = {}
  }
  if ss.data[5]~=0 and ss.data[10]~=0 and ss.data[11]~=0 then
    state.corner = unpack_float(ss.data[5]);
    state.cornerv = unpack_v(ss.data[10],ss.data[11]);
  end
  for i,v in pairs(Config.robot_names_ids) do
    if ss.playerNum == v then
      state.robotName = i
    end
  end

  state.tReceived = unix.time()
  state.time = state.tReceived
  state.ball.t = state.tReceived - state.ball.t_seen
--  print("ball tSeen:",state.ball.t_seen)

  --print("Player ", state.id, " Received : ",  "Walking To : ", state.walkingTo[1], state.walkingTo[2], " role : ", state.role, " posConf : ", state.currentPositionConfidence);


  dindex = 26
  index = 1
  ended = false
  while not ended do
    if ss.data[dindex] == 7 or dindex>800 then ended = true
    else
      state.labelB[index] = ss.data[dindex]
      index = index+1
    end
    dindex = dindex+1
  end
  state.labelBind = ss.data[27]
  return state
end

function get_default_state()
  local state = {
    id = gcm.get_team_player_id(),
    teamNum = Config.game.teamNumber,
    fall=0,
    pose = {x=0, y=0, a=0},
    ball = {t=0, x=1, y=0, vx=0, vy=0, p = 0},
    role = -1,
    walkingTo = {0,0},
    shootingTo = {0,0},
    suggestion = {0,0,0,0,0},
    averageWalkSpeed = 50,
    maxKickDistance = 2000,
    currentPositionConfidence = 0,
    teamConfidence = {0, 0, 0, 0, 0},
    heatLevel = 0,
    currentSideConfidence = 0,

    --Game state info
    time = unix.time(),
    tReceive = unix.time(),

    attackBearing = 0.0,
    penalty = 0,
    gc_latency=0,
    tm_latency=0,
    bodyState = gcm.get_fsm_body_state(),
    robotName = Config.game.robotName,
    teamNumber = gcm.get_team_number(),
    battery_level = wcm.get_robot_battery_level(),

    --Added key vision infos
    goal=0,  --0 for non-detect, 1 for unknown, 2/3 for L/R, 4 for both
    goalv1={0,0},
    goalv2={0,0},
    goalB1={0,0,0,0,0},--Centroid X Centroid Y Orientation Axis1 Axis2
    goalB2={0,0,0,0,0},
    corner=0, --corner angle if not detect  both angle and positions are 0
    cornerv={0,0},
  }
  return state
end

function pack_vision_info(state)
  state.goal=0
  state.goalv1={0,0}
  state.goalv2={0,0}

  if vcm.get_goal_detect()>0 then
    state.goal=1 + vcm.get_goal_type()
    local v1=vcm.get_goal_v1();
    local v2=vcm.get_goal_v2();
    state.goalv1[1],state.goalv1[2]=v1[1],v1[2];
    state.goalv2[1],state.goalv2[2]=0,0;
    centroid1 = vcm.get_goal_postCentroid1();
    orientation1 = vcm.get_goal_postOrientation1();
    axis1 = vcm.get_goal_postAxis1();
    state.goalB1 = {centroid1[1],centroid1[2],
    orientation1,axis1[1],axis1[2]};
    if vcm.get_goal_type()==3 then --two goalposts
      state.goalv2[1],state.goalv2[2]=v2[1],v2[2];
      centroid2 = vcm.get_goal_postCentroid2();
      orientation2 = vcm.get_goal_postOrientation2();
      axis2 = vcm.get_goal_postAxis2();
      state.goalB2 = {centroid2[1],centroid2[2],
      orientation2,axis2[1],axis2[2]};
    end
  end
  state.corner=0
  state.cornerv={0,0}
  if vcm.get_corner_detect()>0 then
    local a = vcm.get_corner_angle();
    local v = vcm.get_corner_v();
    state.corner = a;
    state.cornerv[1],state.cornerv[2]=v[1],v[2];
  end
  return state
end


function pack_labelB(state)
  labelB1 = vcm.get_image1_labelB()
  labelB2 = vcm.get_image2_labelB()
  width1 = vcm.get_image1_width()/Config.vision.scaleA[1]/Config.vision.scaleB[1]
  height1 = vcm.get_image1_height()/Config.vision.scaleA[1]/Config.vision.scaleB[1]
  width2 = vcm.get_image2_width()/Config.vision.scaleA[2]/Config.vision.scaleB[2]
  height2 = vcm.get_image2_height()/Config.vision.scaleA[2]/Config.vision.scaleB[2]
  count1 = vcm.get_image1_count() or 0
  count2 = vcm.get_image2_count() or 0

  array1 = serialization.serialize_label_rle(
    labelB1, width1, height1, 'uint8', 'labelB1',count1);
  array2 = serialization.serialize_label_rle(
    labelB2, width2, height2, 'uint8', 'labelB2',count2);
  state.labelB1 = array1;
  state.labelB2 = array2;
end

function pack_labelB_TeamMsg(state, ind)
  state.data={}
  ind = 2 - ind%2 -- in case wrong parameter is parsed
  labelB = vcm["get_image"..ind.."_labelB"]()
  width = vcm["get_image"..ind.."_width"]()/Config.vision.scaleA[ind]/Config.vision.scaleB[ind]
  height = vcm["get_image"..ind.."_height"]()/Config.vision.scaleA[ind]/Config.vision.scaleB[ind]

  --the wireless broadcast label size is always less than 80 by 60
  --And nao top labelB is size of 160 by 120

  local arr
  if ind==1 then
    local labelC = ImageProc.block_bitor(labelB,width,height,2,2)
    arr = cutil.label2array_rle(labelC, width*height/4)
  else
    arr = cutil.label2array_rle(labelB, width*height)
  end

  state.data[1] = ind -- for recognizition
  for i=1, #arr do
    state.data[1+i] = arr[i]
  end
  state.data[#arr+2] = 7 --separation byte
end
