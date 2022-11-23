---Locomotion for Robocup 2017 (with adaptation to turf)
---Author of correspondence for locomotion 2017:
-- Xiang Deng, dxiang@seas.upenn.edu
---Acknoledgements to: previous ZMP framework from SJ YI et.al, walk_2015.lua
module(..., package.seeall);

-- require "zhelpers"
-- local zmq = require "lzmq"
--
-- -- Prepare our context and publisher
-- local context = zmq.context()
-- local publisher, err = context:socket{zmq.PUB, bind = "tcp://*:5564"}
-- zassert(publisher, err)
-- local subscriber, err = context:socket{zmq.SUB,
-- subscribe = "control_msg";
-- connect = "tcp://192.168.123.99:5563";
-- }
-- zassert(subscriber, err)
-- print('lmzq setup',zmq);

function rounddeci(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
function mysplit(inputstr, sep)
  -- http://stackoverflow.com/questions/1426954/split-string-in-lua
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end
tUpdate = unix.time();


usewebots=false;
logdata=false;
dlt0=0.02;
useremote1=true;
dontmove=false;
usetoesupport=false;
leftkick=false;
kickcommandpause=false;
unlock_kick=0;
uLeftoff = vector.new({0, 0, 0});
uRightoff = vector.new({0, 0, 0});
uTorsooff=vector.new({0, 0, 0});
-- =================================================

require('Body')
require('Kinematics')
require('Config');
require('vector')
require('mcm')
require('unix')
require('util')
require('Body')

-----------------------------
local matrix = require('matrix');
--------------------------------

for i=1,100 do
  print('Config.walk.footX',Config.walk.footX)
end

--- XIANG's motion lib --------------------
kick_strike=false;
kick_stage=0;

step_h_goal=0.03;
step_h_cur=0.00;

getup_active=false;
getup_activeB=false;
getup_started=false;
getup_startedB=false;
t0_stance= Body.get_time();
stance_started=false;
s_getup=0;
qcontrol=vector.zeros(22);

diff_m=vector.zeros(3);
diff_md=vector.zeros(3);

nJoints=22;

supportXauto=0.022;
supportLeg=0;

ft_left_f=vector.zeros(3);
ft_left_b=vector.zeros(3);
ft_right_f=vector.zeros(3);
ft_right_b=vector.zeros(3);
ft_m=vector.zeros(3);
diff_m=vector.zeros(3);
diff_md=vector.zeros(3);

naodynamics=require('libnaodynamicsDX')
if usewebots then
  naodynamics.initialize("Player/Motion/Xiang_Dynamicslib/urdf/naofullbody.urdf","Player/Motion/Xiang_Dynamicslib/keyframes/standupFromFrontslow.motion")
  naodynamics.initializeB("Player/Motion/Xiang_Dynamicslib/urdf/naofullbody.urdf","Player/Motion/Xiang_Dynamicslib/keyframes/standupFromBack.motion")

else
  naodynamics.initialize("/home/nao/UPennDev/Player/Motion/Xiang_Dynamicslib/urdf/naofullbody.urdf","/home/nao/UPennDev/Player/Motion/Xiang_Dynamicslib/keyframes/standupFromFrontslow.motion")
  naodynamics.initializeB("/home/nao/UPennDev/Player/Motion/Xiang_Dynamicslib/urdf/naofullbody.urdf","/home/nao/UPennDev/Player/Motion/Xiang_Dynamicslib/keyframes/standupFromBack.motion")
end

hip_range_table = {{-1.145303, 0.740810}, -- hip yaw pitch
             {-0.379472, 0.790477}, -- left hip roll 
             {-1.535889, 0.484090}, -- left hip pitch
             {-0.092346, 2.112528}, -- left knee pitch
             {-1.189516, 0.922747}, -- left ankle pitch 
             {-0.397880, 0.769001}, -- left ankle roll 
             {-1.145303, 0.740810}, -- hip yaw pitch
             {-0.790477, 0.379472}, -- right hip roll
             {-1.535889, 0.484090}, -- right hip pitch
             {-0.103083, 2.120198}, -- right knee pitch
             {-1.186448, 0.932056}, -- right ankle pitch
             {-0.768992, 0.397935}} -- right ankle roll

function saturate_leg_joints(qlegs) 
  local i = 0
  for i = 1, 12 do
    qlegs[i] = math.min(qlegs[i], hip_range_table[i][2]);
    qlegs[i] = math.max(qlegs[i], hip_range_table[i][1]);
  end
  return qlegs;
end
--------------------------------

-- Walk Parameters
-- Stance and velocity limit values
stanceLimitX=Config.walk.stanceLimitX or {-0.10 , 0.10};
stanceLimitY=Config.walk.stanceLimitY or {0.09 , 0.20};
stanceLimitY={2*Config.walk.footY - 2*Config.walk.supportY,0.20} --needed to prevent from tStep getting too small
stanceLimitA=Config.walk.stanceLimitA or {-0*math.pi/180, 40*math.pi/180};
velLimitX = Config.walk.velLimitX or {-.06, .1};
velLimitY = Config.walk.velLimitY or {-.06, .06};
velLimitA = Config.walk.velLimitA or {-.4, .4};
velDelta = Config.walk.velDelta or {.03,.015,.15};
vaFactor = Config.walk.velLimitA[2] or 0.6;
velXHigh = Config.walk.velXHigh or 0.06;
velDeltaXHigh = Config.walk.velDeltaXHigh or 0.01;

--Toe/heel overlap checking values
footSizeX = Config.walk.footSizeX or {-0.05,0.05};
stanceLimitMarginY = Config.walk.stanceLimitMarginY or 0.015;
stanceLimitY2= 2* Config.walk.footY-stanceLimitMarginY;

--Compensation parameters
ankleMod = Config.walk.ankleMod or {0,0};
spreadComp = Config.walk.spreadComp or 0;
turnCompThreshold = Config.walk.turnCompThreshold or 0;
turnComp = Config.walk.turnComp or 0;

--Gyro stabilization parameters
ankleImuParamX = Config.walk.ankleImuParamX;
ankleImuParamY = Config.walk.ankleImuParamY;
kneeImuParamX = Config.walk.kneeImuParamX;
hipImuParamY = Config.walk.hipImuParamY;

--Support bias parameters to reduce backlash-based instability
velFastForward = Config.walk.velFastForward or 0.06;
velFastTurn = Config.walk.velFastTurn or 0.2;
supportFront = Config.walk.supportFront or 0;
supportFront2 = Config.walk.supportFront2 or 0;
supportBack = Config.walk.supportBack or 0;
supportSideX = Config.walk.supportSideX or 0;
supportSideY = Config.walk.supportSideY or 0;
supportTurn = Config.walk.supportTurn or 0;
frontComp = Config.walk.frontComp or 0.003;
AccelComp = Config.walk.AccelComp or 0.003;

uFoot = vector.zeros(3)

--Initial body swing
supportModYInitial = Config.walk.supportModYInitial or 0

--WalkKick parameters
walkKickDef = Config.kick.walkKickDef;
walkKickPh = Config.kick.walkKickPh;

--------------------------------
-- walkKickPh=0.5;
----------------------------------
--Use obstacle stop?
obscheck = Config.walk.obscheck or false


function compute_diffm()
  local imuAngle = Body.get_sensor_imuAngle();
  local qall=Body.get_sensor_position();
  -- print('qall',unpack(qall))
  naodynamics.setRealStates({imuAngle[1],imuAngle[2],0},{0,0,0},qall);--TODO get effective imu
  local myCOM=naodynamics.getCOM();
  local ft_left=naodynamics.getLeftLeg3d();
  -- print('ft_left',unpack(ft_left))
  ft_left_f={unpack(ft_left, 1, 3)};
  ft_left_b={unpack(ft_left, 4, 6)};
  ft_right=naodynamics.getRightLeg3d();
  ft_right_f={unpack(ft_right, 1, 3)};
  ft_right_b={unpack(ft_right, 4, 6)};
  if supportLeg==0 then --LS
    for i=2,3 do
      ft_m[i]=(ft_left_f[i]+ft_left_b[i])/2
    end
    ft_m[1]=(ft_left_f[1]-ft_left_b[1])/3+ft_left_b[1]

  else
    for i=2,3 do
      ft_m[i]=(ft_right_f[i]+ft_right_b[i])/2
    end
    ft_m[1]=(ft_right_f[1]-ft_right_b[1])/3+ft_right_b[1]
  end
  for i=1,3 do
    diff_m[i]=myCOM[i]-ft_m[i]
  end

  -- print('diff_m',diff_m[1],diff_m[2])
  -- print('diff_md',diff_md[1],diff_md[2])
end



function heeltoecomp(supportLeg,kp)

  comp={0,0}; --ap ar
  if supportLeg==0 then
    local errfb=(ft_right_f[3]-ft_right_b[3]);
    local lrzdz=naodynamics.getLeg3d_lrzdz(1)
    local errlr=lrzdz[3];
    comp[1]=errfb*kp;
    comp[2]=-errlr*kp;
  else
    local errfb=(ft_left_f[3]-ft_left_f[3]);
    local lrzdz=naodynamics.getLeg3d_lrzdz(0)
    local errlr=lrzdz[3];
    comp[1]=errfb*kp;
    comp[2]=-errlr*kp;
  end
  return comp;

end

function update_stance()
  local t = Body.get_time();

  -- pTorsoTarget = vector.new({-footXSit, 0, bodyHeightSit, 0,bodyTiltSit,0});

  local footX = 0.01
  print('footX',footX)

  local uTorsoActual = util.pose_global(vector.new({-footX,0,0}), uTorso);
  local pTorsoTarget=vector.new({uTorsoActual[1], uTorsoActual[2], cp.bodyHeight, 0,cp.bodyTilt,uTorsoActual[3]});
  local pLLeg = vector.new({uLeft[1], uLeft[2], 0, 0,0,uLeft[3]});
  local pRLeg = vector.new({uRight[1], uRight[2], 0, 0,0,uRight[3]});

  if not stance_started then
    if t-t0_stance>0.02 then
      stance_started=true;
      local qLLeg = Body.get_lleg_position();
      local qRLeg = Body.get_rleg_position();

      local dpLLeg = Kinematics.torso_lleg(qLLeg);
      local dpRLeg = Kinematics.torso_rleg(qRLeg);
      pTorsoL=pLLeg+dpLLeg;
      pTorsoR=pRLeg+dpRLeg;
      pTorso=(pTorsoL+pTorsoR)*0.5;

      Body.set_lleg_command(qLLeg);
      Body.set_rleg_command(qRLeg);
      -- TODO
      Body.set_lleg_hardness(0.5);
      Body.set_rleg_hardness(0.5);
      t0_stance = Body.get_time();
      count=1;
    else
      return;
    end
  end

  local dt = t - t0_stance;
  t0_stance = t;
  local tol = true;
  local tolLimit = 1e-6;
  dpLimit = Config.stance.dpLimitStance
  dpDeltaMax = dt*dpLimit;

  dpTorso = pTorsoTarget - pTorso;
  for i = 1,6 do
    if (math.abs(dpTorso[i]) > tolLimit) then
      tol = false;
      if (dpTorso[i] > dpDeltaMax[i]) then
        dpTorso[i] = dpDeltaMax[i];
      elseif (dpTorso[i] < -dpDeltaMax[i]) then
        dpTorso[i] = -dpDeltaMax[i];
      end
    end
  end

  pTorso=pTorso+dpTorso;

  pTorsoActual = {
    pTorso[1],
    pTorso[2],
    pTorso[3],
    pTorso[4],
    pTorso[5],
    pTorso[6]}
  -- print('pLLeg',pLLeg)
  q = Kinematics.inverse_legs(pLLeg, pRLeg, pTorsoActual, 0);

  --print(q[9])
  Body.set_lleg_command(q);

  if tol then
    stance_started=false;
    stance_reset();
    return 1;
  end

  return 0;

end
function getupfromBack()
  local tcur= Body.get_time()
  local holdtime=1000;
  local cfrid=17;
  local dogetup=0;
  local qall=Body.get_sensor_position();
  print('tcur',tcur)

  --- FSM only
  if getup_activeB then
    compute_diffm();
    if s_getup==0 then
      if not getup_startedB then
        getup_startedB=true;
        naodynamics.triggerGetupB(1);
        s_getup=s_getup+1;
      end
    elseif s_getup==1 then -- 1: triggered, goto critical state
      local imuAngle = Body.get_sensor_imuAngle();
      local qall=Body.get_sensor_position();
      naodynamics.setRealStates({imuAngle[1],imuAngle[2],imuAngle[3]},{0,0,0},qall);
      local hold=1;
      qcontrol=naodynamics.standupFromBackUpdate(tcur*1000,hold,cfrid)
      dogetup=qcontrol[nJoints+1];
      -- print('dogetup',dogetup)
      if dogetup>=cfrid then
        s_getup=s_getup+1;
      end
    elseif s_getup==2 then -- 
      local isstable=false;
      isstable=math.abs(vest_pitch)<0.01;
      -- print('isstable',isstable)
      if isstable then
        s_getup=s_getup+1;
      end
    elseif s_getup==3 then --
      -- local stance_done=false;
      -- stance_done=math.abs((cp.bodyHeight- diff_m[3]))<0.045;
      -- print('(cp.bodyHeight- diff_m[3])',(cp.bodyHeight- diff_m[3]))
      local res=update_stance();
      if res>0 then
        s_getup=0;
        getup_activeB=false;
        getup_startedB=false;
        -- naodynamics.standupFromFrontUpdate((tcur+10)*1000,0,cfrid)
        naodynamics.stopGetupB(1)
        tStopDuration= 0.2
        print(tStopDuration)
        stopRequest = 2
        tStopStart = t
        velCurrent= {0,0,0}
        is_stopped = true
        mcm.set_walk_isFallDown(0); 
        mcm.set_walk_isGetupDone(1); 
      end
    end
  end

  --- add feedback for states
  if s_getup>=1 and s_getup<3 then
    Body.set_larm_hardness(0.95);
    Body.set_rarm_hardness(0.95);
    Body.set_lleg_hardness(0.95);
    Body.set_rleg_hardness(0.95);

    local q_head_p=qcontrol[2];
    local cx=diff_m[1];
    -- -- cx=imuAngle[2];
    -- if dogetup>10 and dogetup<=15 then 
    --   supportLeg=0;
    --
    --   local kp=8;
    --   comp=heeltoecomp(0,kp);
    --   qcontrol={unpack(qcontrol,1,nJoints)}
    --   qcontrol[12+5]=qall[12+5]+comp[1];
    --   qcontrol[12+6]=qall[12+6]+comp[2];
    --
    -- end
    -- --
    -- if dogetup>10 then 
    --   qcontrol[3]=qall[3]+0.5*cx;
    --   qcontrol[19]=qall[19]+0.5*cx;
    -- end
    --
    -- if dogetup>=13.9 then 
    --   qcontrol[9]=qall[9]+0.02*imuAngle[2];
    --   qcontrol[15]=qall[15]+0.02*imuAngle[2];
    -- end
    --
    q_head_p=qall[2]; -- head
    q_head_p=q_head_p-cx;

    Body.set_larm_command({unpack(qcontrol,3,6)})
    Body.set_rarm_command({unpack(qcontrol,19,22)})
    Body.set_lleg_command({unpack(qcontrol,7,12)})
    Body.set_rleg_command({unpack(qcontrol,13,18)})
     Body.set_head_command({0,q_head_p})
    -- Body.set_head_command({u0,q_head_p})

  elseif s_getup==3 then
    Body.set_larm_hardness(0.8);
    Body.set_rarm_hardness(0.8);
    Body.set_lleg_hardness(0.8);
    Body.set_rleg_hardness(0.8);

  end
end
function getupfromFront()

  -- print('sdsadasdasd')
  local tcur= Body.get_time()
  local holdtime=1000;
  local cfrid=14;
  local dogetup=0;
  local qall=Body.get_sensor_position();
  print('tcur',tcur)

  --- FSM only
  if getup_active then
    compute_diffm();
    if s_getup==0 then
      if not getup_started then
        getup_started=true;
        naodynamics.triggerGetup(1);
        s_getup=s_getup+1;
      end
    elseif s_getup==1 then -- 1: triggered, goto critical state
      local imuAngle = Body.get_sensor_imuAngle();
      local qall=Body.get_sensor_position();
      naodynamics.setRealStates({imuAngle[1],imuAngle[2],imuAngle[3]},{0,0,0},qall);
      local hold=1;
      qcontrol=naodynamics.standupFromFrontUpdate(tcur*1000,hold,cfrid)
      dogetup=qcontrol[nJoints+1];
      if dogetup>=cfrid then
        s_getup=s_getup+1;
      end
    elseif s_getup==2 then -- 2: at critical state
      local isstable=false;
      isstable=math.abs(vest_pitch)<0.01;
      print('isstable',isstable)
      if isstable then
        s_getup=s_getup+1;
      end
    elseif s_getup==3 then -- 3: after critical state, stance
      -- local stance_done=false;
      -- stance_done=math.abs((cp.bodyHeight- diff_m[3]))<0.045;
      print('(cp.bodyHeight- diff_m[3])',(cp.bodyHeight- diff_m[3]))
      local res=update_stance();
      if res>0 then
        s_getup=0;
        getup_active=false;
        getup_started=false;
        -- naodynamics.standupFromFrontUpdate((tcur+10)*1000,0,cfrid)
        naodynamics.stopGetup(1)
        tStopDuration= 0.2
        print(tStopDuration)
        stopRequest = 2
        tStopStart = t
        velCurrent= {0,0,0}
        is_stopped = true
        mcm.set_walk_isFallDown(0); 
        mcm.set_walk_isGetupDone(1); 
      end
    end
  end

  --- add feedback for states
  if s_getup>=1 and s_getup<3 then
    Body.set_larm_hardness(0.95);
    Body.set_rarm_hardness(0.95);
    Body.set_lleg_hardness(0.95);
    Body.set_rleg_hardness(0.95);

    -- local q_head_p=qcontrol[2];
    local cx=diff_m[1];
    -- cx=imuAngle[2];
    if dogetup>10 and dogetup<=12.5 then
      supportLeg=0;

      local kp=8;
      comp=heeltoecomp(0,kp);
      qcontrol={unpack(qcontrol,1,nJoints)}
      qcontrol[12+5]=qall[12+5]+comp[1];
      qcontrol[12+6]=qall[12+6]+comp[2];

    end

    if dogetup>10 then
      qcontrol[3]=qall[3]+0.5*cx;
      qcontrol[19]=qall[19]+0.5*cx;
    end

    -- if dogetup>=13.9 then
    --   qcontrol[9]=qall[9]+0.01*imuAngle[2];
    --   qcontrol[15]=qall[15]+0.01*imuAngle[2];
    -- end

    q_head_p=qall[2];
    q_head_p=q_head_p-cx;

    Body.set_larm_command({unpack(qcontrol,3,6)})
    Body.set_rarm_command({unpack(qcontrol,19,22)})
    Body.set_lleg_command({unpack(qcontrol,7,12)})
    Body.set_rleg_command({unpack(qcontrol,13,18)})
    Body.set_head_command({0,q_head_p})

  elseif s_getup==3 then
    Body.set_larm_hardness(0.8);
    Body.set_rarm_hardness(0.8);
    Body.set_lleg_hardness(0.8);
    Body.set_rleg_hardness(0.8);

  end
end



--Dirty part
function load_default_param_values()
  local p={}

  p.bodyTilt = Config.walk.bodyTilt or 0
  p.tStep = Config.walk.tStep
  p.tStep0 = Config.walk.tStep
  p.bodyHeight = Config.walk.bodyHeight
  --footX = mcm.get_footX();
  p.footY = Config.walk.footY
  p.supportX = Config.walk.supportX
  p.supportY = Config.walk.supportY
  p.tZmp = Config.walk.tZmp
  --
  -- p.tStep=p.tStep*4;
  -- p .tStep0=p .tStep0*4;
  -- p.tZmp=p.tZmp*4;

  -- p.stepHeight0 = Config.walk.stepHeight
  -- p.stepHeight = Config.walk.stepHeight

  steph=0.03;
  -- steph=0.015;
  p.stepHeight0=steph;
  p.stepHeight=steph;

  p.phSingleRatio = Config.walk.phSingleRatio or 0.04
  p.hardnessSupport = Config.walk.hardnessSupport or 0.75
  p.hardnessSwing = Config.walk.hardnessSwing or 0.5
  p.hipRollCompensation = Config.walk.hipRollCompensation;
  p.zmpparam={aXP=0,aXN=0, aYP=0, aYN=0}
  p.zmp_type = 1 --0 for square zmp
  return p
end

cp=load_default_param_values()
np=load_default_param_values()

----------------------------------------------------------
-- Walk state variables
----------------------------------------------------------

--u means for the world coordinate, origin is in the middle of two feet
uTorso = vector.new({Config.walk.supportX, 0, 0});
uLeft = vector.new({0, Config.walk.footY, 0});
uRight = vector.new({0, -Config.walk.footY, 0});
velCurrent, velCommand,velDiff = vector.new({0,0,0}),vector.new({0,0,0}),vector.new({0,0,0})

--Gyro stabilization variables
ankleShift,kneeShift,hipShift,toeTipCompensation = vector.new({0,0}),0,vector.new({0,0}),0

active = true;
started = false;
iStep0,iStep = -1,0
tLastStep = Body.get_time()

stopRequest = 2;
canWalkKick = true; --Can we do walkkick with this walk code?
walkKickRequest = 0;
walkKick = walkKickDef["FrontLeft"];
current_step_type = 0;
initial_step=2;
ph,phSingle = 0,0

--emergency stop handling
is_stopped = false
stop_threshold = {10*math.pi/180,35*math.pi/180}
tStopStart = 0
tStopDuration = 2.0
supportLeg=0;
----------------------------------------------------------
-- End initialization
----------------------------------------------------------
local max_unstable_factor=0
file = io.open("walklog.txt", "w+");

function writedatatofile_headers()

  local jointNames = { "HeadYaw", "HeadPitch",
    "LShoulderPitch", "LShoulderRoll",
    "LElbowYaw", "LElbowRoll",
    "LHipYawPitch", "LHipRoll", "LHipPitch",
    "LKneePitch", "LAnklePitch", "LAnkleRoll",
    "RHipYawPitch", "RHipRoll", "RHipPitch",
    "RKneePitch", "RAnklePitch", "RAnkleRoll",
    "RShoulderPitch", "RShoulderRoll",
    "RElbowYaw", "RElbowRoll","lastZMPL","ZMPL","ZMPFl","ZMPFr","pressureL","pressureR","supportLeg"} ;
  local jointstr="jointNames";
  for i=1,#jointNames do
    jointstr=jointstr..","..jointNames[i];
  end
  file:write( jointstr, "\n")

end
function writedatatofile_joints()
  -- local file = io.open("walklog.txt", "w")
  local qs_head=Body.get_head_position();
  local qs_lleg=Body.get_lleg_position();
  local qs_rleg=Body.get_rleg_position();
  local qs_larm=Body.get_larm_position();
  local qs_rarm=Body.get_rarm_position();
  local jointstr=""..qs_head[1];
  for i=2,#qs_head do
    jointstr=jointstr..","..qs_head[i];
  end
  for i=1,#qs_larm do
    jointstr=jointstr..","..qs_larm[i];
  end
  for i=1,#qs_lleg do
    jointstr=jointstr..","..qs_lleg[i];
  end

  for i=1,#qs_rleg do
    jointstr=jointstr..","..qs_rleg[i];
  end
  for i=1,#qs_rarm do
    jointstr=jointstr..","..qs_rarm[i];
  end
  jointstr=jointstr..","..lastZMPL
  jointstr=jointstr..","..ZMPL;
  jointstr=jointstr..","..ZMPFl;
  jointstr=jointstr..","..ZMPFr;
  jointstr=jointstr..","..pressureL;
  jointstr=jointstr..","..pressureR;
  jointstr=jointstr..","..supportLeg-0.5;
  file:write( jointstr, "\n")
  -- file:close()
end
if logdata then
  writedatatofile_headers();
end
function entry()

  print ("Motion: Walk entry")
  stance_reset();
  -- lfsr=Body.get_sensor_fsrLeft();
  -- print('lfsr',unpack(lfsr))
  --Place arms in appropriate position at sides
  --[[ Body.set_larm_command(Config.walk.qLArm)
  Body.set_rarm_command(Config.walk.qRArm)
  Body.set_larm_hardness(Config.walk.hardnessArm or 0.2)
  Body.set_rarm_hardness(Config.walk.hardnessArm or 0.2);--]]
  walkKickRequest = 0;
  max_unstable_factor=0;
end

-----------------------------------------------------
usearm=true;
walk_dir_compens=0.03;
vel_backwds=-0.005;
vel_zero_fwoff=0.01;
prev_pitch=0;
vel_pitch={};
vel_pitch.y_hat=0;
vel_pitch.kp=10;
vel_pitch.ki=0.01;
vel_pitch.error_acc=0;
prev_roll=0;
vel_roll={};
vel_roll.y_hat=0;
vel_roll.kp=10;
vel_roll.ki=0.01;
vel_roll.error_acc=0;
t_vel_prev=Body.get_time();
isrotating=false;
t_kickstart=0;
kickrequested=false;

vels_ql={};
for i=1,6 do
  vel_qi={};
  vel_qi.y_hat=0;
  vel_qi.kp=10;
  vel_qi.ki=0.01;
  vel_qi.error_acc=0;
  vels_ql[i]=vel_qi;
end
vels_qr={};
for i=1,6 do
  vel_qi={};
  vel_qi.y_hat=0;
  vel_qi.kp=10;
  vel_qi.ki=0.01;
  vel_qi.error_acc=0;
  vels_qr[i]=vel_qi;
end

vels_diffm={}
for i=1,3 do
  vel_qi={};
  vel_qi.y_hat=0;
  vel_qi.kp=10;
  vel_qi.ki=0.01;
  vel_qi.error_acc=0;
  vels_diffm[i]=vel_qi;
end
qds_l={n=6};
qds_r={n=6};
qLegs_prev={};
isnewstep=false;

function vel_est(y,Ts,vel_param)
  error=y-vel_param.y_hat;
  vel_param.error_acc=vel_param.error_acc+error*Ts;
  v_est=vel_param.kp*error+vel_param.ki*vel_param.error_acc;
  vel_param.y_hat=vel_param.y_hat+v_est*Ts;
  return v_est;
end
function vel_est_many(ys,Ts,vels_param)--also Xiang
  vs_est={};
  for i=1,table.getn(vels_param) do
    error=ys[i]-vels_param[i].y_hat;
    vels_param[i].error_acc=vels_param[i].error_acc+error*Ts;
    vs_est[i]=vels_param[i].kp*error+vels_param[i].ki*vels_param[i].error_acc;
    vels_param[i].y_hat=vels_param[i].y_hat+vs_est[i]*Ts;
  end
  return vs_est;
end

fsLfl=0;
fsLfr=0;
fsLrl=0;
fsLrr=0;

fsRfl=0;
fsRfr=0;
fsRrl=0;
fsRrr=0;
lastZMPL=0;
ZMPL=0;

ZMPFl=0;
ZMPFr=0;

cnter=0;
pressureL=0;
pressureR=0;
function computeZMPfromSensor()
  lfsr=Body.get_sensor_fsrLeft();
  rfsr=Body.get_sensor_fsrRight();

  local temp = lfsr[1]; if(fsLfl<temp and fsLfl<5.0) then fsLfl = temp;end
  temp = lfsr[3]; if(fsLfr<temp and fsLfr<5.0) then fsLfr = temp; end
  temp = lfsr[2]; if(fsLrl<temp and fsLrl<5.0) then fsLrl = temp;end
  temp = lfsr[4]; if(fsLrr<temp and fsLrr<5.0) then fsLrr = temp; end

  temp = rfsr[1]; if(fsRfl<temp and fsRfl<5.0) then fsRfl = temp; end
  temp = rfsr[3]; if(fsRfr<temp and fsRfr<5.0) then fsRfr = temp; end
  temp = rfsr[2]; if(fsRrl<temp and fsRrl<5.0) then fsRrl = temp; end
  temp = rfsr[4]; if(fsRrr<temp and fsRrr<5.0) then fsRrr = temp; end
  lastZMPL = ZMPL;
  ZMPL = 0;

  pressureL =
  lfsr[1]/fsLfl
  + lfsr[3]/fsLfr
  + lfsr[2]/fsLrl
  + lfsr[4]/fsLrr;
  pressureR =
  rfsr[1]/fsRfl
  + rfsr[3]/fsRfr
  + rfsr[2]/fsRrl
  + rfsr[4]/fsRrr;
  local totalPressure = pressureL + pressureR;
  if (math.abs(totalPressure) > 0.000001) then
    ZMPL =
    ( .080 * lfsr[1]/fsLfl
      + .030 * lfsr[3]/fsLfr
      + .080 * lfsr[2]/fsLrl
      + .030 * lfsr[4]/fsLrr
      - .030 * rfsr[1]/fsRfl
      - .080 * rfsr[3]/fsRfr
      - .030 * rfsr[2]/fsRrl
      - .080 * rfsr[4]/fsRrr) / totalPressure;
  end

  ZMPFl = 0; --in left foot frame
  ZMPFr = 0; --in right foot frame
  if (math.abs(pressureL) > 0.000001) then
    ZMPFl =
    ( .070 * lfsr[1]/fsLfl
      + .070 * lfsr[3]/fsLfr
      - .030 * lfsr[2]/fsLrl
      - .030 * lfsr[4]/fsLrr ) / pressureL;
  end
  if (math.abs(pressureR) > 0.000001) then
    ZMPFr =
    (
      .070 * rfsr[1]/fsRfl
      + .070 * rfsr[3]/fsRfr
      - .030 * rfsr[2]/fsRrl
      - .030 * rfsr[4]/fsRrr) / pressureR;
  end
end


function normalloop()
  cnter=cnter+1;
  t = Body.get_time()
  if cnter % 20==0 and logdata then
    writedatatofile_joints();
  end
  -- imuAngle = Body.get_sensor_imuAngle();
  -- print("imuAngle:",imuAngle[1]*180/math.pi,imuAngle[2]*180/math.pi)
  if not usewebots then
    computeZMPfromSensor();
  end
  if cnter % 50 ==0 then
    -- print ('ZMPL ', ZMPL,'ZMPFl ', ZMPFl, 'ZMPFr ', ZMPFr)
  end

  local unstable_factor = math.max (
    math.abs(imuAngle[1]) / stop_threshold[1],
    math.abs(imuAngle[2]) / stop_threshold[2]
  )
  max_unstable_factor = math.max(unstable_factor, max_unstable_factor)

  --start emergency stop
  if dontmove then
     tStopDuration= 2
     print(tStopDuration)
     stopRequest = 2
     tStopStart = t
     velCurrent= {0,0,0}
     is_stopped = true
 end
  --end emergency stop
  if is_stopped and t>tStopStart+tStopDuration then
    is_stopped = false
    start()
    return
  end

  footX = mcm.get_footX()

  --for obstacle detection
  if mcm.get_us_frontobs() == 1 and obscheck == true then
    vy, va = velCurrent[2],velCurrent[3]
    set_velocity(-0.02, 0, 0)
    print("obstacle!!!!!")
  end

  --Don't run update if the robot is sitting or standing
  if vcm.get_camera_bodyHeight()<cp.bodyHeight-0.01 then return end

  if (not active) then mcm.set_walk_isMoving(0);update_still() return end

  mcm.set_walk_isMoving(1)

  if (not started) then started=true;tLastStep = Body.get_time() end

  --step phase factor, should between 0 to 1
  ph = (t-tLastStep)/cp.tStep

  if (ph>0.75 and lastZMPL*ZMPL<0 ) then
    -- print("here --------")
  end

  if ph>1 or (ph>0.75 and lastZMPL*ZMPL<0 ) then
    iStep=iStep+1
    ph=ph-math.floor(ph)
    if (ph>0.75 and lastZMPL*ZMPL<0 ) then
      ph=0;
    end

    tLastStep=tLastStep+cp.tStep
  end

  --Stop when stopping sequence is done
  if (iStep > iStep0) and(stopRequest==2) then
    stopRequest = 0
    active = false
    step_h_cur=0.00;
    return "stop"
  end


  ----------------
  -- New step
  if (iStep > iStep0) then
    plan_nextstep();
  else
    isnewstep=false;
  end --End new step

  xFoot, zFoot = foot_phase(ph)

  if initial_step>0 then zFoot=0; end --Don't lift foot at initial step
  zLeft, zRight = 0,0
  if supportLeg == 0 then -- Left support
    -- if current_step_type>1 then --walkkick
    -- if xFoot<walkKickPh then uRight = util.se2_interpolate(xFoot*2, uRight1, uRight15)
    -- else uRight = util.se2_interpolate(xFoot*2-1, uRight15, uRight2) end

    local forwardL=0;
    if kick_strike then
      forwardL=processXKick();
      -- print('ph',ph,'walkKickPh',walkKickPh,'forwardL',forwardL)
      -- uLeft = util.se2_interpolate(xFoot*2-1, uLeft15, uLeft2)

      uRight = util.se2_interpolate(forwardL, uRight1, uRight2)

    else
      uRight = util.se2_interpolate(xFoot, uRight1, uRight2)
    end
    zRight = cp.stepHeight*zFoot
  else -- Right support
    -- if current_step_type>1 then --walkkick

    -- if xFoot<walkKickPh then uLeft = util.se2_interpolate(xFoot*2, uLeft1, uLeft15)
    -- else
    -- kickph=(xFoot-walkKickPh)/walkKickPh;
    local forwardL=0;
    if kick_strike then
      forwardL=processXKick();

      Body.set_lleg_hardness(0.8);
      Body.set_rleg_hardness(0.8);

      -- print('ph',ph,'walkKickPh',walkKickPh,'forwardL',forwardL)
      -- uLeft = util.se2_interpolate(xFoot*2-1, uLeft15, uLeft2)
      uLeft = util.se2_interpolate(forwardL, uLeft1, uLeft2)

      -- end
    else uLeft = util.se2_interpolate(xFoot, uLeft1, uLeft2) end
    zLeft = cp.stepHeight*zFoot
  end

  --Turning
  local turnCompX=0;
  if math.abs(velCurrent[3])>turnCompThreshold and velCurrent[1]>-0.01 then turnCompX = turnComp end

  --Walking front
  local frontCompX = 0
  if velCurrent[1]>0.04 then frontCompX = frontComp end
  if velDiff[1]>0.02 then frontCompX = frontCompX + AccelComp end

  uTorso = zmp_com(ph,cp)
  uTorso[3] = 0.5*(uLeft[3]+uRight[3]) --nao leg joint is interdependent
  local zeromovecomp=0;

  uTorsoActual = util.pose_global(vector.new({-footX+frontCompX+turnCompX+zeromovecomp,0,0}),uTorso)

  pLLeg = vector.new({uLeft[1], uLeft[2], zLeft, 0,0,uLeft[3]});
  pRLeg = vector.new({uRight[1], uRight[2], zRight, 0,0,uRight[3]})
  pTorso = vector.new({uTorsoActual[1], uTorsoActual[2], cp.bodyHeight, 0,cp.bodyTilt,uTorsoActual[3]});
  local ph1Single,ph2Single = cp.phSingleRatio/2,1-cp.phSingleRatio/2
  phSingle = math.min(math.max(ph-ph1Single, 0)/(ph2Single-ph1Single),1);

  qLegs = Kinematics.inverse_legs(pLLeg, pRLeg, pTorso, supportLeg);

  if walkKickRequest>0  then
    -- print('phSingle',phSingle,'t',t,'velCurrent',unpack(velCurrent))
  end
---------------------NOTE THIS IS A HUGE BUG !!!

  qLegs[13]=qLegs[7]

  ---------------------NOTE THIS IS A HUGE BUG !!!

    if ph > 0.75 then 
    Body.set_actuator_hardness(0.9,9);
    Body.set_actuator_hardness(0.9,10);
    Body.set_actuator_hardness(0.9,11);
    Body.set_actuator_hardness(0.9,12);
    Body.set_actuator_hardness(0.9,15);
    Body.set_actuator_hardness(0.9,16);
    Body.set_actuator_hardness(0.9,17);
    Body.set_actuator_hardness(0.9,18);
  end

  motion_legs(qLegs);

  if usearm then
    local qLArm_to={};
    local qRArm_to={};
    local multiplier=1;
    if hasbackward then
      multiplier=-1;
    end
    for i=1,1 do
      if supportLeg==0 then
        qLArm_to[i] = multiplier*-0.04*math.cos(phSingle*math.pi-math.pi/2);
        qRArm_to[i] = multiplier*0.01*math.cos(phSingle*math.pi-math.pi/2) ;
      else
        qLArm_to[i] = multiplier*0.01*math.cos(phSingle*math.pi-math.pi/2);
        qRArm_to[i] = multiplier*-0.04*math.cos(phSingle*math.pi-math.pi/2) ;
      end
    end

    for i=3,4 do
      qLArm_to[i]=0;
      qRArm_to[i]=0;
    end
    qLArm_to[1]= qLArm_to[1]+ math.pi/2;
    qRArm_to[1]= qRArm_to[1]+ math.pi/2 ;
    qLArm_to[2]=0.2;
    qRArm_to[2]=-0.2;
    qRArm_to[4]=0.2;
    qLArm_to[4]=-0.2;
    -- print(unpack(qLArm_to));
    -- print(unpack(qRArm_to));
    Body.set_larm_command(qLArm_to);
    Body.set_rarm_command(qRArm_to);
    Body.set_larm_hardness(0.1);
    Body.set_rarm_hardness(0.1);
  end

  uFoot = util.se2_interpolate(.5, uLeft+uLeftoff, uRight+uRightoff);
  -- print ("velCommand",unpack(velCommand))
  -- print ("velCurrent",unpack(velCurrent))

end
function update()
  t = unix.time();
  deltaT=t-tUpdate;
  imuAngle=Body.get_sensor_imuAngle();

  if deltaT>dlt0 then
    tUpdate=t;
    t_vel_prev=t;
    vest_pitch=vel_est(imuAngle[2],deltaT,vel_pitch);
    vest_roll=vel_est(imuAngle[1],deltaT,vel_roll);
    local qs_lleg=Body.get_lleg_position();
    local qs_rleg=Body.get_rleg_position();
    qds_l=vel_est_many(qs_lleg,deltaT,vels_ql);
    qds_r=vel_est_many(qs_rleg,deltaT,vels_qr)
    diff_md=vel_est_many(diff_m,deltaT,vels_diffm)
  end

 if false then
  if getup_active==true then
    -- testnewkick();
    -- print('sdasdsadasdasdas')
    getupfromFront();
  elseif getup_activeB==true then
    getupfromBack();
  else
    -- print('imuAngle',unpack(imuAngle))
    if math.abs(imuAngle[2])>1.1 then
      while math.abs(vest_pitch)>0.05 do
        Body.set_larm_command({math.pi/2,0,0,0});
        Body.set_rarm_command({math.pi/2,0,0,0});
        Body.set_lleg_command({0,0,0,0,0,0})
        Body.set_rleg_command({0,0,0,0,0,0})
        Body.set_larm_hardness(0.1);
        Body.set_rarm_hardness(0.1);
        Body.set_lleg_hardness(0.1);
        Body.set_rleg_hardness(0.1);
        t = unix.time();
        deltaT=t-tUpdate;
        -- imuAngle=Body.get_sensor_imuAngle();
        if deltaT>dlt0 then
          tUpdate=t;
          t_vel_prev=t;
          vest_pitch=vel_est(imuAngle[2],deltaT,vel_pitch);
        end
      end

      if usewebots then
        imuAngle[2]=-imuAngle[2];
      end

      mcm.set_walk_isFallDown(1); --Notify world to reset heading
      mcm.set_walk_isGetupDone(0); 
      if imuAngle[2]>0  then
        getup_active=true;
      else
        getup_activeB=true;
      end
      return
    end
    -- print('okokokoko')
    normalloop();
  end
else
  normalloop();
end

end
function xiang_walkkick_0step()
  kick_strike=false;
  if walkKickRequest>0 then
      velCurrent[1]=0;
      velCurrent[2]=0;
      velCurrent[3]=0;    
    if supportLeg==0 then
      Body.set_lleg_hardness(1);
    end
    if kick_stage==4 then
      cp.tStep = cp.tStep0
      cp.stepHeight = 0.03
      current_step_type=0
      velCurrent,velCommand=vector.new({0,0,0}),vector.new({0,0,0})
      walkKickRequest=0;
      kick_stage=0;
      return;
    end
    if kick_stage == 0 then

      uFootErr = util.pose_relative(uLeft1,util.pose_global(2*uLRFootOffset,uRight1))
      if supportLeg~=walkKick[1][3] or math.abs(uFootErr[1])>0.02
      or math.abs(uFootErr[2])>0.01 or math.abs(uFootErr[3])>10*math.pi/180 then
        if supportLeg == 0 then uRight2 = util.pose_global( -2*uLRFootOffset, uLeft1)
        else uLeft2 = util.pose_global( 2*uLRFootOffset, uRight1) end

      end
    elseif kick_stage ==1 then

      if (leftkick and supportLeg== 1) or (supportLeg== 0 and not leftkick) then
        kick_strike=true;
        cp.tStep = 0.6;
        current_step_type = 1;
        cp.stepHeight = 0.043;
        supportMod = {-0.01,-0.01}
        shiftFactor = 0.4;
        footPos1={0.09,0.0,0.0};
        footPos2={0.06,0.0,0.0};
        if supportLeg == 0 then --
          -- shiftFactor=0.5;
          -- cp.tStep=0.45;
          uRight2 = util.pose_global({footPos2[1],footPos2[2]-2*cp.footY,footPos2[3]},uLeft1)
        else
          uLeft2 = util.pose_global({footPos1[1],footPos1[2]+2*cp.footY,footPos1[3]},uRight1)
        end
      else
        return
      end

    elseif kick_stage ==2 then

      cp.tStep=0.4;
      current_step_type = 0;
      cp.stepHeight = 0.03;
      supportMod = {-0.02,-0.02}
      shiftFactor = 0.5;

      local footPos1={0.00,0.00,0.0};
      local footPos2={0.00,-0.0,0.0};

      local capX=0;
      local capY=0;
      if true then
        local imuAngle = Body.get_sensor_imuAngle();
        if true then
          local fact=0;
          local val =math.min ( 0.03,math.sqrt(math.abs(imuAngle[1])/0.3)*0.03);
          if supportLeg==0 and vest_roll < 0 then --left tilt w/ LS
            fact=-1;
            -- capshift=math.min(0.1,math.abs(imuAngle[1]));
          elseif supportLeg==0 and vest_roll >0 then --right tilt w/ LS
            fact=0;
          elseif supportLeg==1 and vest_roll < 0 then --left tilt w/ RS
            fact=0;
          elseif supportLeg==1 and vest_roll >0 then
            fact=1;
            -- capshift=math.min(0.1,math.abs(imuAngle[1]));
          end
          capY=val*fact;
          -- print('capY',capshift,capY,getsign(vest_roll))
        end

        if true then
          local fact=0;
          -- local val =math.min(0.02,math.sqrt(math.abs(vest_pitch)/0.3)*0.01);
          local val =math.min(0.03,math.sqrt(math.abs(imuAngle[2])/0.3)*0.05);
          if supportLeg==0 and vest_pitch < 0 then --backward tilt w/ LS
            fact=-1;
          elseif supportLeg==0 and vest_pitch >0 then --forward tilt w/ LS
            fact=1;
          elseif supportLeg==1 and vest_pitch < 0 then --backward tilt w/ RS
            fact=-1;
          elseif supportLeg==1 and vest_pitch >0 then
            fact=1;
          end
          capX=val*fact;
          -- print('capX',capX,getsign(vest_pitch))
        end
      end

      if supportLeg==0 then
        footPos2={capX,capY,0}
        print('footPos2',unpack(footPos2))
      else
        footPos1={capX,capY,0}
        print('footPos1',unpack(footPos1))
      end

      if supportLeg == 0 then
        -- uRight15 = util.pose_global({footPos1[1],footPos1[2]-2*cp.footY,footPos1[3]},uLeft1)
        uRight2 = util.pose_global({footPos2[1],footPos2[2]-2*cp.footY,footPos2[3]},uLeft1)
      else
        -- uLeft15 = util.pose_global({footPos1[1],footPos1[2]+2*cp.footY,footPos1[3]},uRight1)
        uLeft2 = util.pose_global({footPos1[1],footPos1[2]+2*cp.footY,footPos1[3]},uRight1)
      end
    end

    if kick_stage==3 then
      if true then
        tStopDuration= 0.5
        print(tStopDuration)
        stopRequest = 2
        tStopStart = t
        velCurrent= {0,0,0}
        is_stopped = true
      end
    end
    -- TODO experimental, need to settle down body velocity before kick
    if kick_stage==0 then

      if vest_pitch*vest_pitch + vest_roll*vest_roll < 0.08 then
        kick_stage=kick_stage+1;
      end
    else
      kick_stage=kick_stage+1;
    end
  end
end
function processXKick()
  local forwardL=0;
  kickph=xFoot;

  local forwardSide=2;
  local factorkick=3;

  if kickph < 0.03*factorkick then
    --body...
  elseif (kickph > (0.1+0.03)*factorkick and kickph <= (0.12+0.09)*factorkick) then -- move forward
    local numSteps = 0.06;

    local firstStep = 0.04*factorkick;
    forwardL = (forwardSide)*((kickph-firstStep+0.01)/numSteps) + forwardL;

    -- elseif (kickph > 0.09*factorkick and kickph <= 0.15*factorkick) then
    -- forwardL = forwardSide;
    -- rollL=rollSide;
    -- heightL = 0.02
    -- elseif (kickph > 0.15*factorkick and kickph <= 0.18*factorkick) then -- move back
    -- local numSteps = 0.03;
    -- local firstStep = 0.16*factorkick;
    -- forwardL = forwardL + (forwardSide*(1-((phSingle-firstStep+0.01)/numSteps)));
  elseif kickph>(0.12+0.09)*factorkick then
    forwardL=math.max(0.8,forwardL)
  end

  return forwardL;
end
function plan_nextstep()
  update_velocity();
  iStep0 = iStep;
  local tStep_next = calculate_swap()

  supportLeg = iStep % 2; -- 0 for left support, 1 for right support
  uLeft1,uRight1,uTorso1 = uLeft2,uRight2,uTorso2

  --Switch walk params
  cp = np
  np = load_default_param_values()

  if (step_h_cur~=step_h_goal) then
    step_h_cur=step_h_cur+(step_h_goal-step_h_cur)*0.3;
  end
  np.stepHeight=step_h_cur;
  np.stepHeight0=step_h_cur;
  -- np.stepHeight=0.016;---- *<<<<<<PARAM>>>>>/
  if walkKickRequest==0 then
    np.tStep0 = tStep_next
    np.tStep = tStep_next
  end

  uLRFootOffset = vector.new({0,cp.footY,0})
  supportMod = {0,0}; --Support Point modulation for walkkick
  shiftFactor = 0.5; --How much should we shift final Torso pose?
  -- check_walkkick();
  xiang_walkkick_0step();

  ----------------------------------
  if walkKickRequest==0 then
    if (stopRequest==1) then --Final step
      stopRequest=2
      velCurrent,velCommand=vector.new({0,0,0}),vector.new({0,0,0}) ;
      if supportLeg == 0 then uRight2 = util.pose_global(-2*uLRFootOffset, uLeft1) --LS
      else uLeft2 = util.pose_global(2*uLRFootOffset, uRight1) --RS
      end
    else --Normal walk, advance steps
      cp.tStep=cp.tStep0
      if supportLeg == 0 then
        uRight2 = step_right_destination(velCurrent, uLeft1, uRight1) --LS
      else
        uLeft2 = step_left_destination(velCurrent, uLeft1, uRight1) --RS
      end
      --Velocity-based support point modulation
      toeTipCompensation = 0;
      if velDiff[1]>0 then supportMod[1] = supportFront2 --Accelerating to front
      elseif velCurrent[1]>velFastForward then supportMod[1] = supportFront;toeTipCompensation = ankleMod[1]
      elseif velCurrent[1]<0 then supportMod[1] = supportBack
      elseif math.abs(velCurrent[3])>velFastTurn then supportMod[1] = supportTurn
      else
        if velCurrent[2]>0.015 then supportMod[1],supportMod[2] = supportSideX,supportSideY
        elseif velCurrent[2]<-0.015 then supportMod[1],supportMod[2] = supportSideX,-supportSideY
        end
      end
    end
  end

  -- if math.abs(velCurrent[1])<0.02 then
  --   step_h_goal=0.02;
  --   elseif math.abs(velCurrent[1])<0.04 then
  --     step_h_goal=0.02;
  --     elseif math.abs(velCurrent[1])<0.061 then
  --       step_h_goal=0.03;
  --     end
  -- step_h_goal=0.015+math.abs(velCurrent[1])/0.1*0.02+math.abs(velCurrent[2])/0.05*0.02

  -- step_h_goal=0.03
  uTorso2 = step_torso(uLeft2, uRight2,shiftFactor)
  uTorso2[2]=uTorso2[2]+Config.walk.bodyYshift;
  --Adjustable initial step body swing
  if initial_step>0 then
    if supportLeg == 0 then supportMod[2]=supportModYInitial --LS
    else supportMod[2]=-supportModYInitial end--RS
  end

  --Apply velocity-based support point modulation for uSupport
  if supportLeg == 0 then --LS
    local uLeftTorso = util.pose_relative(uLeft1,uTorso1);
    local uTorsoModded = util.pose_global(vector.new({supportMod[1],supportMod[2],0}),uTorso)
    local uLeftModded = util.pose_global (uLeftTorso,uTorsoModded);
    uSupport = util.pose_global({cp.supportX, cp.supportY, 0},uLeftModded)

    Body.set_lleg_hardness(cp.hardnessSupport);
    Body.set_rleg_hardness(cp.hardnessSwing);

  else --RS
    local uRightTorso = util.pose_relative(uRight1,uTorso1);
    local uTorsoModded = util.pose_global(vector.new({supportMod[1],supportMod[2],0}),uTorso)
    local uRightModded = util.pose_global (uRightTorso,uTorsoModded);
    uSupport = util.pose_global({cp.supportX, -cp.supportY, 0}, uRightModded)

    Body.set_rleg_hardness(cp.hardnessSupport);
    Body.set_lleg_hardness(cp.hardnessSwing);

  end
  calculate_zmp_param(uSupport,uTorso1,uTorso2,cp)
  max_unstable_factor=0
  isnewstep=true;
end

function update_still()
  uTorso = step_torso(uLeft, uRight,0.5);
  uTorsoActual = util.pose_global(vector.new({-footX,0,0}), uTorso);
  pLLeg = vector.new({uLeft[1], uLeft[2], 0, 0,0,uLeft[3]});
  pRLeg = vector.new({uRight[1], uRight[2], 0, 0,0,uRight[3]})
  pTorso = vector.new({uTorsoActual[1], uTorsoActual[2], cp.bodyHeight, 0,cp.bodyTilt,uTorsoActual[3]});
  qLegs = Kinematics.inverse_legs(pLLeg, pRLeg, pTorso, supportLeg);

  Body.set_lleg_hardness(cp.hardnessSupport);
  Body.set_rleg_hardness(cp.hardnessSwing);

  motion_legs(qLegs,true);
end

function motion_legs(qLegs,gyro_off)
  phComp = math.min(1, phSingle/.1, (1-phSingle)/.1);

  --Ankle stabilization using gyro feedback
  imuGyr = Body.get_sensor_imuGyrRPY();
  gyro_roll0,gyro_pitch0=imuGyr[1],imuGyr[2]
  if gyro_off then gyro_roll0,gyro_pitch0=0,0 end

  --get effective gyro angle considering body angle offset
  if not active then yawAngle = (uLeft[3]+uRight[3])/2-uTorsoActual[3] --double support
  elseif supportLeg == 0 then yawAngle = uLeft[3]-uTorsoActual[3] -- Left support
  elseif supportLeg==1 then yawAngle = uRight[3]-uTorsoActual[3]
  end
  gyro_roll = gyro_roll0*math.cos(yawAngle) -gyro_pitch0* math.sin(yawAngle)
  gyro_pitch = gyro_pitch0*math.cos(yawAngle) -gyro_roll0* math.sin(yawAngle)

  ankleShiftX=util.procFunc(gyro_pitch*ankleImuParamX[2],ankleImuParamX[3],ankleImuParamX[4])
  ankleShiftY=util.procFunc(gyro_roll*ankleImuParamY[2],ankleImuParamY[3],ankleImuParamY[4])
  kneeShiftX=util.procFunc(gyro_pitch*kneeImuParamX[2],kneeImuParamX[3],kneeImuParamX[4])
  hipShiftY=util.procFunc(gyro_roll*hipImuParamY[2],hipImuParamY[3],hipImuParamY[4])

  ankleShift[1]=ankleShift[1]+ankleImuParamX[1]*(ankleShiftX-ankleShift[1]);
  ankleShift[2]=ankleShift[2]+ankleImuParamY[1]*(ankleShiftY-ankleShift[2]);
  kneeShift=kneeShift+kneeImuParamX[1]*(kneeShiftX-kneeShift);
  hipShift[2]=hipShift[2]+hipImuParamY[1]*(hipShiftY-hipShift[2]);

  if not active then --Double support, standing still
    qLegs[4] = qLegs[4] + kneeShift; --Knee pitch stabilization
    qLegs[5] = qLegs[5] + ankleShift[1]; --Ankle pitch stabilization
    qLegs[10] = qLegs[10] + kneeShift; --Knee pitch stabilization
    qLegs[11] = qLegs[11] + ankleShift[1]; --Ankle pitch stabilization

  elseif supportLeg == 0 then -- Left support
    qLegs[2] = qLegs[2] + hipShift[2]; --Hip roll stabilization
    qLegs[4] = qLegs[4] + kneeShift; --Knee pitch stabilization
    qLegs[5] = qLegs[5] + ankleShift[1]; --Ankle pitch stabilization
    qLegs[6] = qLegs[6] + ankleShift[2]; --Ankle roll stabilization

    qLegs[11] = qLegs[11] + toeTipCompensation*phComp;--Lifting toetip
    qLegs[2] = qLegs[2] + cp.hipRollCompensation*phComp; --Hip roll compensation
  else
    qLegs[8] = qLegs[8] + hipShift[2]; --Hip roll stabilization
    qLegs[10] = qLegs[10] + kneeShift; --Knee pitch stabilization
    qLegs[11] = qLegs[11] + ankleShift[1]; --Ankle pitch stabilization
    qLegs[12] = qLegs[12] + ankleShift[2]; --Ankle roll stabilization

    qLegs[5] = qLegs[5] + toeTipCompensation*phComp;--Lifting toetip
    qLegs[8] = qLegs[8] - cp.hipRollCompensation*phComp;--Hip roll compensation
  end

  qLegs[3] = qLegs[3] + Config.walk.LHipOffset
  qLegs[9] = qLegs[9] + Config.walk.RHipOffset
  qLegs[5] = qLegs[5] + Config.walk.LAnkleOffset
  qLegs[11] = qLegs[11] + Config.walk.RAnkleOffset
  if not dontmove then
    qLegs=saturate_leg_joints(qLegs)
    Body.set_lleg_command(qLegs);
  end
  if deltaT>dlt0 then
    if useremote1 and false then
      send_message="robo_msg";
      for curr_id=1,12 do
        cur_pos= qLegs[curr_id];
        cur_pos=rounddeci(cur_pos,5);
        send_message=send_message.."|"..cur_pos;
      end
      send_message=send_message.."|"..supportLeg;
      send_message=send_message.."|"..phSingle;
      send_message=send_message.."|"..pTorso[5];

      for i=1,3 do
        send_message=send_message.."|"..pTorso[i];
      end
      for i=1,3 do
        send_message=send_message.."|"..pLLeg[i];
      end
      for i=1,3 do
        send_message=send_message.."|"..pRLeg[i];
      end
      publisher:sendx(send_message);
    end
  end
end

function exit() end

function step_left_destination(vel, uLeft, uRight)
  local u0 = util.se2_interpolate(.5, uLeft, uRight);
  -- Determine nominal midpoint position 1.5 steps in future
  local u1 = util.pose_global(vel, u0);
  local fact = 2-1.5*math.exp(-8*(0.06-math.abs(vel[1])));
  print('fact ',fact)
  local u2 = util.pose_global(fact*vel, u1); --- TODO XIANG TODO
  local uLeftPredict = util.pose_global(uLRFootOffset, u2);
  local uLeftRight = util.pose_relative(uLeftPredict, uRight);

  --Check toe and heel overlap
  local toeOverlap= -footSizeX[1]*uLeftRight[3];
  local heelOverlap= -footSizeX[2]*uLeftRight[3];
  local limitY = math.max(stanceLimitY[1],
    stanceLimitY2+math.max(toeOverlap,heelOverlap));

  uLeftRight[1] = math.min(math.max(uLeftRight[1], stanceLimitX[1]), stanceLimitX[2]);
  uLeftRight[2] = math.min(math.max(uLeftRight[2], limitY),stanceLimitY[2]);
  uLeftRight[3] = math.min(math.max(uLeftRight[3], stanceLimitA[1]), stanceLimitA[2]);
  return util.pose_global(uLeftRight, uRight);
end

function step_right_destination(vel, uLeft, uRight)
  local u0 = util.se2_interpolate(.5, uLeft, uRight);
  -- Determine nominal midpoint position 1.5 steps in future
  local u1 = util.pose_global(vel, u0);
  local fact = 2-1.5*math.exp(-8*(0.06-math.abs(vel[1])));
  local u2 = util.pose_global(fact*vel, u1); --- TODO XIANG TODO
  local uRightPredict = util.pose_global(-1*uLRFootOffset, u2);
  local uRightLeft = util.pose_relative(uRightPredict, uLeft);

  --Check toe and heel overlap
  local toeOverlap= footSizeX[1]*uRightLeft[3];
  local heelOverlap= footSizeX[2]*uRightLeft[3];
  local limitY = math.max(stanceLimitY[1],
    stanceLimitY2+math.max(toeOverlap,heelOverlap));

  uRightLeft[1] = math.min(math.max(uRightLeft[1], stanceLimitX[1]), stanceLimitX[2]);
  uRightLeft[2] = math.min(math.max(uRightLeft[2], -stanceLimitY[2]), -limitY);
  uRightLeft[3] = math.min(math.max(uRightLeft[3], -stanceLimitA[2]), -stanceLimitA[1]);
  return util.pose_global(uRightLeft, uLeft);
end

function step_torso(uLeft, uRight,shiftFactor)
  local u0 = util.se2_interpolate(.5, uLeft, uRight);
  local uLeftSupport = util.pose_global({cp.supportX, cp.supportY, 0}, uLeft);
  local uRightSupport = util.pose_global({cp.supportX, -cp.supportY, 0}, uRight);
  return util.se2_interpolate(shiftFactor, uLeftSupport, uRightSupport);
end

function set_velocity(vx, vy, va)
  --Filter the commanded speed
  vx= math.min(math.max(vx,velLimitX[1]),velLimitX[2]);
  vy= math.min(math.max(vy,velLimitY[1]),velLimitY[2]);
  va= math.min(math.max(va,velLimitA[1]),velLimitA[2]);

  --Slow down when turning
  vFactor = 1-math.abs(va)/vaFactor;

  local stepMag=math.sqrt(vx^2+vy^2);
  local magFactor=math.min(velLimitX[2]*vFactor,stepMag)/(stepMag+0.000001);




  -- velCommand[1],velCommand[2],velCommand[3]=
 velCommand[1],velCommand[2],velCommand[3]=vx*magFactor,vy*magFactor,va;


  velCommand[1] = math.min(math.max(velCommand[1],velLimitX[1]),velLimitX[2]);
  velCommand[2] = math.min(math.max(velCommand[2],velLimitY[1]),velLimitY[2]);
  velCommand[3] = math.min(math.max(velCommand[3],velLimitA[1]),velLimitA[2]);
end

function update_velocity()
  local sf = 1
  if max_unstable_factor> 0.7 then -- robot's unstable, slow down
    print("unstable, slowing down")
    sf = 0.85
  end

  if velCurrent[1]>velXHigh then --Slower accelleration at high speed
    velDiff[1]= math.min(math.max(velCommand[1]*sf-velCurrent[1],-velDelta[1]),velDeltaXHigh)
  else
    velDiff[1]= math.min(math.max(velCommand[1]*sf-velCurrent[1],-velDelta[1]),velDelta[1])
  end
  velDiff[2]= math.min(math.max(velCommand[2]*sf-velCurrent[2],-velDelta[2]),velDelta[2])
  velDiff[3]= math.min(math.max(velCommand[3]*sf-velCurrent[3],-velDelta[3]),velDelta[3])

  for i=1,3 do
    local ff=1;
    if math.abs(velCommand[i])<0.01 then
       ff=1;
    else
       ff=0.3;
    end
    velCurrent[i] = velCurrent[i]+ff*velDiff[i]
  end

  local velnorm=math.sqrt(velCurrent[1]*velCurrent[1]+velCurrent[2]*velCurrent[2])


  local fact1=1;
  if velCurrent[1]<0 then
    fact1=-1;
  end
  velCurrent[1]=math.min(math.abs(velCurrent[1]),0.045)*fact1;

  local fact2=1;
  if velCurrent[2]<0 then
    fact2=-1;
  end
  velCurrent[2]=math.min(math.abs(velCurrent[2]),0.01)*fact2;

  local robotName = unix.gethostname();

  if (robotName=="ruffio") then

  local fact1=1;
  if velCurrent[1]<0 then
    fact1=-1;
  end
  velCurrent[1]=math.min(math.abs(velCurrent[1]),0.02)*fact1;

    local fact2=1;
  if velCurrent[2]<0 then
    fact2=-1;
  end
  velCurrent[2]=math.min(math.abs(velCurrent[2]),0.005)*fact2;

      local fact3=1;
  if velCurrent[3]<0 then
    fact3=-1;
  end
  velCurrent[3]=math.min(math.abs(velCurrent[3]),0.02)*fact3;


end


 

  if initial_step>0 then
    velCurrent=vector.new({0,0,0})
    initial_step=initial_step-1
  end
end

function get_velocity() return velCurrent end

function start()
  stopRequest = 0;
  if (not active) then
    active = true
    started = false
    iStep0 = -1
    tLastStep = Body.get_time()
    initial_step=2
  end
end

function doWalkKickLeft()
  if walkKickRequest==0 then
    walkKickRequest = 1;
    walkKick = walkKickDef["FrontLeft"];
  end
  if not kickcommandpause then
    leftkick=true;
    print('leftkick true \n')
  end
end

function doWalkKickRight()
  if walkKickRequest==0 then
    walkKickRequest = 1;
    walkKick = walkKickDef["FrontRight"];
  end
  if not kickcommandpause then
    leftkick=false;
  end
end

function doWalkKickLeft2()
  if walkKickRequest==0 then
    walkKickRequest = 1;
    walkKick = walkKickDef["FrontLeft2"];
  end
end

function doWalkKickRight2()
  if walkKickRequest==0 then walkKickRequest = 1
    walkKick = walkKickDef["FrontRight2"] end
  end

  function doSideKickLeft()
    if walkKickRequest==0 then
      walkKickRequest = 1;
      walkKick = walkKickDef["SideLeft"];
    end
  end

  function doSideKickRight()
    if walkKickRequest==0 then
      walkKickRequest = 1;
      walkKick = walkKickDef["SideRight"];
    end
  end

  function zero_velocity() end
  function doPunch(punchtype) end
  function switch_stance(stance) end
  function stop() stopRequest = math.max(1,stopRequest) end
  function stopAlign() stop() end

  function stance_reset() --standup/sitdown/falldown handling
    print("Stance Resetted")
    uLeft = util.pose_global(vector.new({-cp.supportX, cp.footY, 0}),uTorso)
    uRight = util.pose_global(vector.new({-cp.supportX, -cp.footY, 0}),uTorso)
    uLeft1, uLeft2,uRight1, uRight2,uTorso1, uTorso2 = uLeft, uLeft, uRight, uRight, uTorso, uTorso
    uSupport = uTorso
    tLastStep=Body.get_time()
    walkKickRequest = 0
    iStep0,iStep = -1,0
    walkKickRequest=0
    uLRFootOffset = vector.new({0,footY,0});
  end

  function get_odometry(u0)
    if (not u0) then
      u0 = vector.new({0, 0, 0});
    end
    local uFoot = util.se2_interpolate(.5, uLeft+uLeftoff, uRight+uRightoff);
    return util.pose_relative(uFoot, u0), uFoot;
  end

  function get_body_offset()
    local uFoot = util.se2_interpolate(.5, uLeft+uLeftoff, uRight+uRightoff);
    return util.pose_relative(uTorso+uTorsooff, uFoot);
  end

  function calculate_zmp_param(uSupport,uTorso1,uTorso2,p)
    local zmpparam={}
    if p.zmp_type==1 then
      zmpparam.m1X = (uSupport[1]-uTorso1[1])/(p.tStep*p.phSingleRatio/2)
      zmpparam.m2X = (uTorso2[1]-uSupport[1])/(p.tStep*p.phSingleRatio/2)
      zmpparam.m1Y = (uSupport[2]-uTorso1[2])/(p.tStep*p.phSingleRatio/2)
      zmpparam.m2Y = (uTorso2[2]-uSupport[2])/(p.tStep*p.phSingleRatio/2)
    end
    zmpparam.aXP, zmpparam.aXN = zmp_solve(uSupport[1], uTorso1[1], uTorso2[1],uTorso1[1], uTorso2[1],p)
    zmpparam.aYP, zmpparam.aYN = zmp_solve(uSupport[2], uTorso1[2], uTorso2[2],uTorso1[2], uTorso2[2],p)
    p.zmpparam = zmpparam
    --Compute COM speed at the end of step
    --[[
    dx0=(aXP-aXN)/tZmp + m1X* (1-math.cosh(ph1Zmp*tStep/tZmp));
    dy0=(aYP-aYN)/tZmp + m1Y* (1-math.cosh(ph1Zmp*tStep/tZmp));
    print("max DY:",dy0);
    --]]
  end

  function zmp_solve(zs, z1, z2, x1, x2,p)
    --[[
    Solves ZMP equation:
    x(t) = z(t) + aP*exp(t/tZmp) + aN*exp(-t/tZmp) - tZmp*mi*sinh((t-Ti)/tZmp)
    where the ZMP point is piecewise linear:
    z(0) = z1, z(T1 < t < T2) = zs, z(tStep) = z2
    --]]
    local expTStep = math.exp(p.tStep/p.tZmp);
    if p.zmp_type==1 then --Trapzoidal zmp
      local T1,T2 = p.tStep*p.phSingleRatio/2, p.tStep*(1-p.phSingleRatio/2)
      local m1,m2 = (zs-z1)/T1, -(zs-z2)/(p.tStep-T2)
      local c1 = x1-z1+p.tZmp*m1*math.sinh(-T1/p.tZmp);
      local c2 = x2-z2+p.tZmp*m2*math.sinh((p.tStep-T2)/p.tZmp);
      local aP = (c2 - c1/expTStep)/(expTStep-1/expTStep);
      local aN = (c1*expTStep - c2)/(expTStep-1/expTStep);
      return aP, aN;
    else --Square ZMP
      local c1 = x1-z1
      local c2 = x2-z2
      local aP = (c2 - c1/expTStep)/(expTStep-1/expTStep)
      local aN = (c1*expTStep - c2)/(expTStep-1/expTStep)
    end
  end

  --Finds the necessary COM for stability and returns it
  function zmp_com(ph,p)
    local com = vector.new({0, 0, 0});
    local tStep,ph1Zmp,ph2Zmp,tZmp =p.tStep, p.phSingleRatio/2,1-p.phSingleRatio/2, p.tZmp
    local m1X,m1Y,m2X,m2Y = p.zmpparam.m1X,p.zmpparam.m1Y,p.zmpparam.m2X,p.zmpparam.m2Y
    local aXP,aXN,aYP,aYN = p.zmpparam.aXP,p.zmpparam.aXN,p.zmpparam.aYP,p.zmpparam.aYN
    expT = math.exp(tStep*ph/tZmp);
    com[1] = uSupport[1] + aXP*expT + aXN/expT;
    com[2] = uSupport[2] + aYP*expT + aYN/expT;
    if p.zmp_type==1 then
      if (ph < ph1Zmp) then
        com[1] = com[1] + m1X*tStep*(ph-ph1Zmp) - tZmp*m1X*math.sinh(tStep*(ph-ph1Zmp)/tZmp);
        com[2] = com[2] + m1Y*tStep*(ph-ph1Zmp) - tZmp*m1Y*math.sinh(tStep*(ph-ph1Zmp)/tZmp);
      elseif (ph > ph2Zmp) then
        com[1] = com[1] + m2X*tStep*(ph-ph2Zmp) - tZmp*m2X*math.sinh(tStep*(ph-ph2Zmp)/tZmp);
        com[2] = com[2] + m2Y*tStep*(ph-ph2Zmp) - tZmp*m2Y*math.sinh(tStep*(ph-ph2Zmp)/tZmp);
      end
    end
    com[3] = ph* (uLeft2[3]+uRight2[3])/2 + (1-ph)* (uLeft1[3]+uRight1[3])/2;
    return com;
  end

    function foot_phase(ph)
    -- Computes relative x,z motion of foot during single support phase
    -- phSingle = 0: x=0, z=0, phSingle = 1: x=1,z=0
    local ph1Single,ph2Single = cp.phSingleRatio/2,1-cp.phSingleRatio/2
    phSingle = math.min(math.max(ph-ph1Single, 0)/(ph2Single-ph1Single),1);
    local phSingleSkew = phSingle^0.8 - 0.17*phSingle*(1-phSingle);
    local xf = .5*(1-math.cos(math.pi*phSingleSkew));
    local zf = .5*(1-math.cos(2*math.pi*phSingleSkew));
    -- return xf, zf


    -- print('phSingle',phSingle,'xf',xf)
    ----------- try parabola as RS
    local xh=0;
    local zh=0;
    if phSingle < 0.25 then
      zh=8*phSingle*phSingle;
    elseif phSingle >=0.25 and phSingle < 0.5 then
      xh=0.5-phSingle;
      zh=1-8*xh*xh;
    elseif phSingle >=0.5 and phSingle < 0.75 then
      xh=phSingle-0.5;
      zh=1-8*xh*xh;
    else
      xh=1-phSingle;
      zh=8*xh*xh;
    end

    local xh=0;
    if phSingle<0.5 then
      xh=2*phSingle*phSingle;
    else
      xh=4*phSingle-2*phSingle*phSingle-1;
    end

    if not kick_strike then
    return xh,zh
  else
    return xf,zh
  end
    ------------------------------------
  end

  function calculate_swap()
    if (not Config.walk.variable_step) or Config.walk.variable_step==0 then
      return Config.walk.tStep
    end

    require('invhyp')
    --x = p + x0 cosh((t-t0)/t_zmp)
    --local tStep = cp.tStep
    local tStep = Config.walk.tStep
    local tZmp = cp.tZmp

    local stepY
    local t_start
    local p,x0
    if supportLeg==0 then --ls
      p = -(cp.footY + cp.supportY)
      x0 = -p/math.cosh(tStep/tZmp/2)
      local uSupport1 = util.pose_global({cp.supportX, cp.supportY, 0}, uLeft1);
      local uSupport2 = util.pose_global({cp.supportX, -cp.supportY, 0}, uRight2);
      local uSupportMove = util.pose_relative(uSupport2,uSupport1)
      stepY = uSupportMove[2]+2*(cp.footY+cp.supportY)
      -- print("ls",stepY)
    else --rs
      p = (cp.footY + cp.supportY)
      x0 = -p/math.cosh(tStep/tZmp/2)
      local uSupport1 = util.pose_global({cp.supportX, -cp.supportY, 0}, uRight1);
      local uSupport2 = util.pose_global({cp.supportX, cp.supportY, 0}, uLeft2);
      uSupportMove = util.pose_relative(uSupport2,uSupport1)
      stepY = uSupportMove[2]-2*(cp.footY+cp.supportY)
      -- print("rs",stepY)
    end
    if (stepY/2-p)/x0<1 then return Config.walk.tStep end
    local t_start = -invhyp.acosh( (stepY/2 - p)/x0 )*tZmp + tStep/2
    local tStep_next = math.max(Config.walk.tStep, tStep-t_start)
    -- print("tStep_next:",tStep_next)
    return tStep_next
  end

  entry()