function h = shm_robot(teamNumber, playerID)
% function create the same struct as the team message from
% shared memory. for local debugging use

global MONITOR %for sending the webots check information

  h.teamNumber = teamNumber;
  h.playerID = playerID;
  h.user = getenv('USER');


% create shm wrappers (in alphabetic order)
  h.gcmFsm  = shm(sprintf('gcmFsm%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.gcmGame = shm(sprintf('gcmGame%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.gcmTeam  = shm(sprintf('gcmTeam%d%d%s',  h.teamNumber, h.playerID, h.user));

  h.vcmBall  = shm(sprintf('vcmBall%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmBalltop  = shm(sprintf('vcmBall1%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmBallbtm  = shm(sprintf('vcmBall2%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmBoundary = shm(sprintf('vcmBoundary%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmCamera = shm(sprintf('vcmCamera%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmDebugtop  = shm(sprintf('vcmDebug1%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmDebugbtm  = shm(sprintf('vcmDebug2%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmFreespace = shm(sprintf('vcmFreespace%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmGoal  = shm(sprintf('vcmGoal%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmImagetop = shm(sprintf('vcmImage1%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmImagebtm = shm(sprintf('vcmImage2%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmSpot  = shm(sprintf('vcmSpot%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmSpottop = shm(sprintf('vcmSpot1%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmSpotbtm = shm(sprintf('vcmSpot2%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmCircle = shm(sprintf('vcmCircle%d%d%s', h.teamNumber, h.playerID, h.user));
%   h.vcmCircletop = shm(sprintf('vcmCircle1%d%d%s', h.teamNumber, h.playerID, h.user));
%   h.vcmCirclebtm = shm(sprintf('vcmCircle2%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmLine  = shm(sprintf('vcmLine%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmLinetop  = shm(sprintf('vcmLine1%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmLinebtm  = shm(sprintf('vcmLine2%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmCorner  = shm(sprintf('vcmCorner%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmCornertop  = shm(sprintf('vcmCorner1%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmCornerbtm  = shm(sprintf('vcmCorner2%d%d%s',  h.teamNumber, h.playerID, h.user));

  h.wcmBall  = shm(sprintf('wcmBall%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmGoal  = shm(sprintf('wcmGoal%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmParticle  = shm(sprintf('wcmParticle%d%d%s',  h.teamNumber, h.playerID, h.user));

  h.mcmFeedback = shm(sprintf('mcmFeedback%d%d%s', h.teamNumber, h.playerID, h.user));


  %h.wcmKick
  %h.mcmWalk = shm(sprintf('mcmWalk%d%d%s', h.teamNumber, h.playerID, h.user));


  h.wcmTeamdata  = shm(sprintf('wcmTeamdata%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmRobotNames  = shm(sprintf('wcmRobotNames%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmBodyStates  = shm(sprintf('wcmBodyStates%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmLabelBtop  = shm(sprintf('wcmLabelBtop%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmLabelBbtm  = shm(sprintf('wcmLabelBbtm%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmRobot  = shm(sprintf('vcmRobot%d%d%s',  h.teamNumber, h.playerID, h.user)); 

  %Be careful this no longer crashes some machines...
	%h.ocmOcc = shm(sprintf('ocmOcc%d%d%s', h.teamNumber, h.playerID, h.user));
	%h.ocmObstacle = shm(sprintf('ocmObstacle%d%d%s', h.teamNumber, h.playerID, h.user));

	%h.matcmControl = shm(sprintf('matcmControl%d%d%s', h.teamNumber, h.playerID, h.user));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SJ - reading Occmap SHM from robot kills matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %h.wcmOccmap = shm(sprintf('wcmOccmap%d%d%s', h.teamNumber, h.playerID, h.user));
  h.wcmRobot = shm(sprintf('wcmRobot%d%d%s', h.teamNumber, h.playerID, h.user));

% set function pointers
  h.update = @update;
  h.get_team_struct = @get_team_struct;
  h.get_monitor_struct = @get_monitor_struct;
  h.get_yuyv = @get_yuyv;
  h.get_yuyv2 = @get_yuyv2;
  h.get_yuyv3 = @get_yuyv3;
  h.get_rgb = @get_rgb;
  h.get_cb = @get_cb;
  h.get_cbScaleB = @get_cbScaleB;
  h.get_labelA = @get_labelA;
  h.get_labelB = @get_labelB;
  h.get_particle = @get_particle;
  h.get_occ_likeihood = @get_occ_likelihood;

  h.get_motion_struct = @get_motion_struct;


  h.set_yuyv = @set_yuyv;
  h.set_labelA = @set_labelA;

  h.updated=0;
  h.tLastUpdate=0;

  h.get_team_struct_wireless = @get_team_struct_wireless;
  h.get_monitor_struct_wireless = @get_monitor_struct_wireless;

  h.get_labelB_wireless = @get_labelB_wireless;

  function update()
      % do nothing
  end

  function r = get_team_struct()
    % returns the robot struct (in the same form as the team messages)
    r = [];
%    disp('get team struct');
    try
        r.teamNumber = h.gcmTeam.get_number();
        r.teamColor = h.gcmTeam.get_color();
        r.id = h.gcmTeam.get_player_id();
        r.role = h.gcmTeam.get_role();
        r.robotName='';
        r.bodyState=h.gcmTeam.get_body_state();        
        r.gps_only = h.gcmTeam.get_gpsonly();


        pose = h.wcmRobot.get_pose();
        r.pose = struct('x', pose(1), 'y', pose(2), 'a', pose(3));
        
        %ADDED
        r.pose_target = h.gcmTeam.get_pose_target();

        ballx = h.wcmBall.get_x();
	      bally = h.wcmBall.get_y();
        ballt = h.wcmBall.get_t();
        ballvelx = h.wcmBall.get_velx();
        ballvely = h.wcmBall.get_vely();

        r.ball = struct('x', ballx, 'y', bally, 't', ballt, ...
            'vx', ballvelx, 'vy', ballvely );

        r.attackBearing = h.wcmGoal.get_attack_bearing();
        r.time=h.wcmRobot.get_time();
        r.battery_level = h.wcmRobot.get_battery_level();

        goal = h.vcmGoal.get_detect();
        if goal==1 
          r.goal = h.vcmGoal.get_type()+1;
          r.goalv1 = h.vcmGoal.get_v1();
          r.goalv2 = h.vcmGoal.get_v2();
        else
          r.goal=0;
        end


        gc1=[0 0];gc2=[0 0];ga1=[0 0];ga2=[0 0];go1=0;go2=0;%TODO

        r.goalpostStat1 = struct('x',gc1(1), 'y',gc1(2), 'a',ga1(1), 'b',ga1(2),'o',go1);
        r.goalpostStat2 = struct('x',gc2(1), 'y',gc2(2), 'a',ga2(1), 'b',ga2(2),'o',go2);


        r.spot=h.vcmSpot.get_detect();
        r.spotv=h.vcmSpot.get_v();

        r.circle=h.vcmCircle.get_detect();
        
        corner=h.vcmCorner.get_detect();
        if corner>0
         r.corner=h.vcmCorner.get_type();
         r.cornerv=h.vcmCorner.get_v();
        end

        r.fall = h.wcmRobot.get_is_fall_down();
        r.time = h.wcmRobot.get_time();
        r.penalty = h.wcmRobot.get_penalty();

 	      gpspose = h.wcmRobot.get_gpspose();
        r.gpspose = struct('x', gpspose(1), 'y', gpspose(2), 'a', gpspose(3));
 	      r.gps_attackbearing = h.wcmRobot.get_gps_attackbearing();

        free_detect = h.vcmFreespace.get_detect();
        if free_detect == 1
          r.obstacle = {};
          r.obstacle.num = h.ocmObstacle.get_num();
          r.obstacle.centroid_x = h.ocmObstacle.get_cx();
          r.obstacle.centroid_y = h.ocmObstacle.get_cy();
          r.obstacle.nearest_x = h.ocmObstacle.get_nx();
          r.obstacle.nearest_y = h.ocmObstacle.get_ny();
          r.obstacle.nearest_dist = h.ocmObstacle.get_ndist();
        end

        r.tReceive = 0;

        r.walkingto = h.gcmGame.get_walkingto();
        r.shootingto = h.gcmGame.get_shootingto();

%TODO: monitor 1timeout    
        if r.time>h.tLastUpdate 
    	    h.updated=1;
	        h.tLastUpdate=r.time;
	      end
 
    catch
    end
  end
  
  function r = get_motion_struct()
    r = [];
    try  
      r.t = h.mcmFeedback.get_t();
      r.support = h.mcmFeedback.get_support();
      r.imuAngle = h.mcmFeedback.get_imuAngle();
      r.imuGyro = h.mcmFeedback.get_imuGyro();

      r.errorLeft = h.mcmFeedback.get_errorLeftJE();
      r.errorRight = h.mcmFeedback.get_errorRightJE();
      r.error = h.mcmFeedback.get_errorJE();

      r.torsoTarget = h.mcmFeedback.get_torsoTarget();      
      r.torsoTargetFiltered = h.mcmFeedback.get_torsoTargetFiltered();      
    catch
    end
  end


  function r = get_team_struct_wireless(id)
    r = [];
    try
      r.teamNumber = h.gcmTeam.get_number();
      teamColor = h.wcmTeamdata.get_teamColor();
      robotId = h.wcmTeamdata.get_robotId();
      role = h.wcmTeamdata.get_role();
      time= h.wcmTeamdata.get_time();
      posex= h.wcmTeamdata.get_posex();
      posey= h.wcmTeamdata.get_posey();
      posea= h.wcmTeamdata.get_posea();

      ballx= h.wcmTeamdata.get_ballx();
      bally= h.wcmTeamdata.get_bally();
      ballt= h.wcmTeamdata.get_ballt();
      ballvx= h.wcmTeamdata.get_ballvx();
      ballvy= h.wcmTeamdata.get_ballvy();

      attackBearing= h.wcmTeamdata.get_attackBearing();
      fall=h.wcmTeamdata.get_fall();
      penalty=h.wcmTeamdata.get_penalty();
      battery_level=h.wcmTeamdata.get_battery_level();

      goal=h.wcmTeamdata.get_goal();
      goalv11=h.wcmTeamdata.get_goalv11();
      goalv12=h.wcmTeamdata.get_goalv12();
      goalv21=h.wcmTeamdata.get_goalv21();
      goalv22=h.wcmTeamdata.get_goalv22();

      goalB11=h.wcmTeamdata.get_goalB11();
      goalB12=h.wcmTeamdata.get_goalB12();
      goalB13=h.wcmTeamdata.get_goalB13();
      goalB14=h.wcmTeamdata.get_goalB14();
      goalB15=h.wcmTeamdata.get_goalB15();

      goalB21=h.wcmTeamdata.get_goalB21();
      goalB22=h.wcmTeamdata.get_goalB22();
      goalB23=h.wcmTeamdata.get_goalB23();
      goalB24=h.wcmTeamdata.get_goalB24();
      goalB25=h.wcmTeamdata.get_goalB25();

      cornera=h.wcmTeamdata.get_cornera();
      cornerv1=h.wcmTeamdata.get_cornerv1();
      cornerv2=h.wcmTeamdata.get_cornerv2();

      r.teamColor=teamColor(id);
      r.id = robotId(id);
      r.role = role(id);
      r.time = time(id);
        
      r.pose = {};
      r.pose.x= posex(id);
      r.pose.y= posey(id);
      r.pose.a= posea(id);

      r.gpspose = r.pose;      

      r.ball={};
      r.ball.x= ballx(id);
      r.ball.y= bally(id);
      r.ball.vx= ballvx(id);
      r.ball.vy= ballvy(id);
      r.ball.t= ballt(id);

      r.attackBearing= attackBearing(id);

      r.fall=fall(id);
      r.penalty=penalty(id);
      r.battery_level=battery_level(id);

      r.goal=goal(id);
      r.goalv1=[goalv11(id) goalv12(id)];
      r.goalv2=[goalv21(id) goalv22(id)];


      gc1 = [goalB11(id) goalB12(id)];
      gc2 = [goalB21(id) goalB22(id)];

      go1 = goalB13(id);
      go2 = goalB23(id);

      ga1 = [goalB14(id) goalB15(id)];
      ga2 = [goalB24(id) goalB25(id)];

      r.goalpostStat1 = struct('x',gc1(1), 'y',gc1(2), 'a',ga1(1), 'b',ga1(2),'o',go1);
      r.goalpostStat2 = struct('x',gc2(1), 'y',gc2(2), 'a',ga2(1), 'b',ga2(2),'o',go2);

      r.cornera=cornera(id);
      r.cornerv=[cornerv1(id) cornerv2(id)];

      r.robotName='';
      if id==1
        r.robotName = char(h.wcmRobotNames.get_n1());
        r.bodyState = char(h.wcmBodyStates.get_n1());
      elseif id==2
        r.robotName = char(h.wcmRobotNames.get_n2());
        r.bodyState = char(h.wcmBodyStates.get_n2());
      elseif id==3
        r.robotName = char(h.wcmRobotNames.get_n3());
        r.bodyState = char(h.wcmBodyStates.get_n3());
      elseif id==4
        r.robotName = char(h.wcmRobotNames.get_n4());
        r.bodyState = char(h.wcmBodyStates.get_n4());
      elseif id==5
        r.robotName = char(h.wcmRobotNames.get_n5());
        r.bodyState = char(h.wcmBodyStates.get_n5());
      elseif id==6
        r.robotName = char(h.wcmRobotNames.get_n6());
        r.bodyState = char(h.wcmBodyStates.get_n6());
      elseif id==7
        r.robotName = char(h.wcmRobotNames.get_n7());
        r.bodyState = char(h.wcmBodyStates.get_n7());
      elseif id==8
        r.robotName = char(h.wcmRobotNames.get_n8());
        r.bodyState = char(h.wcmBodyStates.get_n8());
      elseif id==9
        r.robotName = char(h.wcmRobotNames.get_n9());
        r.bodyState = char(h.wcmBodyStates.get_n9());
      elseif id==10
        r.robotName = char(h.wcmRobotNames.get_n10());
        r.bodyState = char(h.wcmBodyStates.get_n10());
      end

    catch
    end
  end

  function labelB = get_labelB_wireless(robotID, indx)
    if (indx == 1)
      %we don't have size info from shm this time, hack this number...
      width = 80;
      height = 60;
      if robotID==1 
        rawData = h.wcmLabelBtop.get_p1();
      elseif robotID==2 
        rawData = h.wcmLabelBtop.get_p2();
      elseif robotID==3 
        rawData = h.wcmLabelBtop.get_p3();
      elseif robotID==4 
        rawData = h.wcmLabelBtop.get_p4();
      elseif robotID==5 
        rawData = h.wcmLabelBtop.get_p5();
      elseif robotID==6 
        rawData = h.wcmLabelBtop.get_p6();
      elseif robotID==7 
        rawData = h.wcmLabelBtop.get_p7();
      elseif robotID==8 
        rawData = h.wcmLabelBtop.get_p8();
      elseif robotID==9 
        rawData = h.wcmLabelBtop.get_p9();
      else
        rawData = h.wcmLabelBtop.get_p10();
      end
    elseif (indx == 2)
      width = 80;
      height = 60;
      if robotID==1 
        rawData = h.wcmLabelBbtm.get_p1();
      elseif robotID==2 
        rawData = h.wcmLabelBbtm.get_p2();
      elseif robotID==3 
        rawData = h.wcmLabelBbtm.get_p3();
      elseif robotID==4 
        rawData = h.wcmLabelBbtm.get_p4();
      elseif robotID==5 
        rawData = h.wcmLabelBbtm.get_p5();
      elseif robotID==6 
        rawData = h.wcmLabelBbtm.get_p6();
      elseif robotID==7 
        rawData = h.wcmLabelBbtm.get_p7();
      elseif robotID==8 
        rawData = h.wcmLabelBbtm.get_p8();
      elseif robotID==9 
        rawData = h.wcmLabelBbtm.get_p9();
      else
        rawData = h.wcmLabelBbtm.get_p10();
      end
    end
    labelB = raw2label(rawData, width, height)';
  end

  function r = get_monitor_struct()
    % returns the monitor struct (in the same form as the monitor messages)
    r = [];
    try
      r.team = struct(...
      'number', h.gcmTeam.get_number(),...
      'color', h.gcmTeam.get_color(),...
      'player_id', h.gcmTeam.get_player_id(),...
      'role', h.gcmTeam.get_role()...
      );

      r.fsm = struct(...
    	 'body', h.gcmFsm.get_body_state(),...
    	 'head', h.gcmFsm.get_head_state(),...
    	 'motion', h.gcmFsm.get_motion_state(),...
    	 'game', h.gcmFsm.get_game_state()...
    	);

      %Added for the new FSM
      r.team.pose_target = h.gcmTeam.get_pose_target();

      pose = h.wcmRobot.get_pose();
      r.robot = {};
      r.robot.pose = struct('x', pose(1), 'y', pose(2), 'a', pose(3));
%      vel = h.mcmWalk.get_vel();
%      r.robot.vel = struct('vx', vel(1), 'vy', vel(2), 'va', vel(3));

    %Camera info

      select = h.vcmImagetop.get_select();
      width = h.vcmImagetop.get_width();
      height = h.vcmImagetop.get_height();

      %%%%% FIXED
      scaleAtop = h.vcmImagetop.get_scaleA();
      scaleAbtm = h.vcmImagebtm.get_scaleA();

			scaleBtop = h.vcmImagetop.get_scaleB();
      scaleBbtm = h.vcmImagebtm.get_scaleB();
      
      bodyHeight=h.vcmCamera.get_bodyHeight();
      bodyTilt=h.vcmCamera.get_bodyTilt();
      headAngles=h.vcmImagetop.get_headAngles();
      rollAngle=h.vcmCamera.get_rollAngle();
      lutFileName = char(h.vcmCamera.get_lut_filename());
      r.camera = struct('select',select,'width',width,'height',height,...
             'scaleAtop',scaleAtop,'scaleAbtm',scaleAbtm,...
             'scaleBtop',scaleBtop,'scaleBbtm',scaleBbtm,...
             'bodyHeight',bodyHeight,'bodyTilt',bodyTilt,...
             'headAngles',headAngles,'rollAngle',rollAngle,...
             'lutFileName',lutFileName);

    %yuyv type info
      r.yuyv_type = h.vcmCamera.get_yuyvType();
 
    %Image FOV boundary
      fovC=h.vcmImagetop.get_fovC();
      fovTL=h.vcmImagetop.get_fovTL();
      fovTR=h.vcmImagetop.get_fovTR();
      fovBL=h.vcmImagetop.get_fovBL();
      fovBR=h.vcmImagetop.get_fovBR();
      r.fov= struct('C',fovC, 'TL',fovTL, 'TR',fovTR, 'BL',fovBL, 'BR', fovBR);

   %ball info
      ballx = h.wcmBall.get_x();
      bally = h.wcmBall.get_y();
      ballt = h.wcmBall.get_t();
      ballvelx = h.wcmBall.get_velx();
      ballvely = h.wcmBall.get_vely();

      ball = {};
      ball.detect = h.vcmBall.get_detect();
      ball.detecttop = h.vcmBalltop.get_detect();
      ball.detectbtm = h.vcmBallbtm.get_detect();
      ball.centroid = {};
      centroid = h.vcmBall.get_centroid();
      ball.centroid.x = centroid(1);
      ball.centroid.y = centroid(2);
      ball.axisMajor = h.vcmBall.get_axisMajor();
      
      r.ball = struct('x', ballx, 'y', bally, 't', ballt, ...
          'centroid', ball.centroid, 'axisMajor', ball.axisMajor, ...
          'detect', ball.detect,'detecttop', ball.detecttop, ...
	  'detectbtm', ball.detectbtm, 'vx',ballvelx,'vy',ballvely);
    
      r.ball.fromRP = h.vcmBall.get_fromRP();
      r.balltop.fromRP = h.vcmBalltop.get_fromRP();
      r.balltop.bboxLeftTopX = h.vcmBalltop.get_bboxLeftTopX();
      r.balltop.bboxLeftTopY = h.vcmBalltop.get_bboxLeftTopY();
      r.balltop.bboxRightBottomX = h.vcmBalltop.get_bboxRightBottomX();
      r.balltop.bboxRightBottomY = h.vcmBalltop.get_bboxRightBottomY();
      r.balltop.newBbox = h.vcmBalltop.get_newBbox();
      
      r.ballbtm.fromRP = h.vcmBallbtm.get_fromRP();
      r.ballbtm.bboxLeftTopX = h.vcmBallbtm.get_bboxLeftTopX();
      r.ballbtm.bboxLeftTopY = h.vcmBallbtm.get_bboxLeftTopY();
      r.ballbtm.bboxRightBottomX = h.vcmBallbtm.get_bboxRightBottomX();
      r.ballbtm.bboxRightBottomY = h.vcmBallbtm.get_bboxRightBottomY();
      r.ballbtm.newBbox = h.vcmBallbtm.get_newBbox();
  
  %goal info
      r.goal = {};
      r.goal.detect = h.vcmGoal.get_detect();
      r.goal.type = h.vcmGoal.get_type();
      r.goal.color = h.vcmGoal.get_color();
          
      % Add the goal positions
      goalv1 = h.vcmGoal.get_v1();
      r.goal.v1 = struct('x',goalv1(1), 'y',goalv1(2), 'z',goalv1(3), 'scale',goalv1(4));
      goalv2 = h.vcmGoal.get_v2();
      r.goal.v2 = struct('x',goalv2(1), 'y',goalv2(2), 'z',goalv2(3), 'scale',goalv2(4));
          
      r.goal.postStat1 = struct('x',0,'y',0, 'a',0, 'b',0,'o',0,...
	'gbx1',0,'gbx2',0,'gby1',0,'gby2',0);
      r.goal.postStat2 = struct('x',0,'y',0, 'a',0, 'b',0,'o',0,...
	'gbx1',0,'gbx2',0,'gby1',0,'gby2',0);

      if r.goal.detect==1 
         %add goal post stats
        gc1 = h.vcmGoal.get_postCentroid1();
        gc2 = h.vcmGoal.get_postCentroid2();
        ga1 = h.vcmGoal.get_postAxis1();
        ga2 = h.vcmGoal.get_postAxis2();
        go1 = h.vcmGoal.get_postOrientation1();
        go2 = h.vcmGoal.get_postOrientation2();

        % Add the goal bounding boxes
        gbb1 = h.vcmGoal.get_postBoundingBox1();
        gbb2 = h.vcmGoal.get_postBoundingBox2();

        r.goal.postStat1 = struct('x',gc1(1), 'y',gc1(2), 'a',ga1(1), 'b',ga1(2),'o',go1(1), ...
	   'gbx1',gbb1(1), 'gbx2',gbb1(2), 'gby1',gbb1(3), 'gby2',gbb1(4) );
        r.goal.postStat2 = struct('x',gc2(1), 'y',gc2(2), 'a',ga2(1), 'b',ga2(2),'o',go2(1),...
	   'gbx1',gbb2(1), 'gbx2',gbb2(2), 'gby1',gbb2(3), 'gby2',gbb2(4) );
      end

  %landmark spot info
      r.spot = {};
      r.spot.detect = h.vcmSpot.get_detect();
      r.spot.detecttop = h.vcmSpottop.get_detect();
      r.spot.detectbtm = h.vcmSpotbtm.get_detect();
      r.spot.color = h.vcmSpot.get_color();
      r.spot.bboxB = h.vcmSpot.get_bboxB();
      r.spot.v = h.vcmSpot.get_v();
      r.spot.centroid1 = h.vcmSpot.get_centroid1();
      r.spot.centroid2 = h.vcmSpot.get_centroid2();
      r.spot.centroid3 = h.vcmSpot.get_centroid3();
 
  %Circle info
      r.circle = {};
      r.circle.detect = h.vcmCircle.get_detect();
%       r.circle.detecttop = h.vcmCircletop.get_detect();
%       r.circle.detectbtm = h.vcmCirclebtm.get_detect();
      r.circle.x = h.vcmCircle.get_x();
      r.circle.y = h.vcmCircle.get_y();
      r.circle.var =  h.vcmCircle.get_var();

  %Vision debug message
      r.debugtop={};
      r.debugtop.message = char(h.vcmDebugtop.get_message());
      r.debugbtm={};
      r.debugbtm.message = char(h.vcmDebugbtm.get_message());


  %Particle info
      r.particle={};
      r.particle.x=h.wcmParticle.get_x();
      r.particle.y=h.wcmParticle.get_y();
      r.particle.w=h.wcmParticle.get_w();
      r.particle.a=h.wcmParticle.get_a();

  %line info
      r.line = {};
      r.linetop = {};
      r.linebtm = {};
      r.line.detect = h.vcmLine.get_detect();
      r.linetop.detect = h.vcmLinetop.get_detect();
      r.linebtm.detect = h.vcmLinebtm.get_detect();
      
      r.line = {};
      r.line.detect = h.vcmLine.get_detect();
      r.line.detecttop = h.vcmLinetop.get_detect();
      r.line.detectbtm = h.vcmLinebtm.get_detect();
      r.line.nLines = h.vcmLine.get_nLines();
      r.line.v1 = {};
      r.line.v2 = {};
      r.line.endpoint={};
      r.line.xMean=h.vcmLine.get_xMean();
      r.line.yMean=h.vcmLine.get_yMean();
      v1x=h.vcmLine.get_v1x();
      v1y=h.vcmLine.get_v1y();
      v2x=h.vcmLine.get_v2x();
      v2y=h.vcmLine.get_v2y();
      endpoint11=h.vcmLine.get_endpoint11();
      endpoint12=h.vcmLine.get_endpoint12();
      endpoint21=h.vcmLine.get_endpoint21();
      endpoint22=h.vcmLine.get_endpoint22();
      for i=1:r.line.nLines
        r.line.v1{i}=[v1x(i) v1y(i)];
        r.line.v2{i}=[v2x(i) v2y(i)];
        r.line.endpoint{i}=[endpoint11(i) endpoint21(i) ...
                                endpoint12(i) endpoint22(i)];
        %r.line.xMean{i}=xMean{i};
        %r.line.yMean{i}=yMean{i};
      end
      
      r.linetop.nLines = h.vcmLinetop.get_nLines();
      r.linetop.v1 = {};
      r.linetop.v2 = {};
      r.linetop.endpoint={};
      r.linetop.xMean=h.vcmLinetop.get_xMean();
      r.linetop.yMean=h.vcmLinetop.get_yMean();
      v1x=h.vcmLinetop.get_v1x();
      v1y=h.vcmLinetop.get_v1y();
      v2x=h.vcmLinetop.get_v2x();
      v2y=h.vcmLinetop.get_v2y();
      endpoint11=h.vcmLinetop.get_endpoint11();
      endpoint12=h.vcmLinetop.get_endpoint12();
      endpoint21=h.vcmLinetop.get_endpoint21();
      endpoint22=h.vcmLinetop.get_endpoint22();
      for i=1:r.linetop.nLines
        r.linetop.v1{i}=[v1x(i) v1y(i)];
        r.linetop.v2{i}=[v2x(i) v2y(i)];
        r.linetop.endpoint{i}=[endpoint11(i) endpoint21(i) ...
                                endpoint12(i) endpoint22(i)];
        %r.line.xMean{i}=xMean{i};
        %r.line.yMean{i}=yMean{i};
      end
      
      r.linebtm.nLines = h.vcmLinebtm.get_nLines();
      r.linebtm.v1 = {};
      r.linebtm.v2 = {};
      r.linebtm.endpoint={};
      r.linebtm.xMean=h.vcmLinebtm.get_xMean();
      r.linebtm.yMean=h.vcmLinebtm.get_yMean();
      v1x=h.vcmLinebtm.get_v1x();
      v1y=h.vcmLinebtm.get_v1y();
      v2x=h.vcmLinebtm.get_v2x();
      v2y=h.vcmLinebtm.get_v2y();
      endpoint11=h.vcmLinebtm.get_endpoint11();
      endpoint12=h.vcmLinebtm.get_endpoint12();
      endpoint21=h.vcmLinebtm.get_endpoint21();
      endpoint22=h.vcmLinebtm.get_endpoint22();
      for i=1:r.linebtm.nLines
        r.linebtm.v1{i}=[v1x(i) v1y(i)];
        r.linebtm.v2{i}=[v2x(i) v2y(i)];
        r.linebtm.endpoint{i}=[endpoint11(i) endpoint21(i) ...
                                endpoint12(i) endpoint22(i)];
        %r.line.xMean{i}=xMean{i};
        %r.line.yMean{i}=yMean{i};
      end

  %corner info
      r.corner = {};
      r.corner.detect = h.vcmCorner.get_detect();
      r.corner.detecttop = h.vcmCornertop.get_detect();
      r.corner.detectbtm = h.vcmCornerbtm.get_detect();

      r.corner.type = h.vcmCorner.get_type();
      r.corner.vc0 = h.vcmCorner.get_vc0();
      r.corner.v10 = h.vcmCorner.get_v10();
      r.corner.v20 = h.vcmCorner.get_v20();

      r.corner.v = h.vcmCorner.get_v();
      r.corner.v1 = h.vcmCorner.get_v1();
      r.corner.v2 = h.vcmCorner.get_v2();

%{
  %robot map info
      r.robot={};
      r.robot.map=h.vcmRobot.get_map();
      r.robot.lowpoint=h.vcmRobot.get_lowpoint();
%}
  % Add freespace boundary
      r.free = {};
			r.free.detect = 0;
      freeCol = h.vcmFreespace.get_nCol();
      freeValueB = h.vcmFreespace.get_pboundB();
			freeDis = h.vcmFreespace.get_vboundB();
      labelBm = size(freeValueB,2)/2;
			r.free.y = freeDis(1:labelBm);
			r.free.x = freeDis(labelBm+1:2*labelBm);
      r.free.Bx = freeValueB(1:labelBm);
      r.free.By = freeValueB(labelBm+1:2*labelBm);
      r.free.nCol = freeCol;
      r.free.detect = h.vcmFreespace.get_detect();
      % Add visible boundary        

      % Add occupancy map
      if r.free.detect == 1
        r.occ = {};
  			map = h.ocmOcc.get_map();
        map = typecast(map, 'uint32');
  			mapsize = sqrt(size(map,2));
  			map = reshape(map, [mapsize, mapsize]);
  			r.occ.map = double(map)/10000;
  			r.occ.mapsize = mapsize;
  			r.occ.robot_pos = h.ocmOcc.get_robot_pos();
        r.occ.odom = h.ocmOcc.get_odom();
        r.occ.vel = h.mcmWalk.get_vel();
        r.occ.pvel = h.ocmOcc.get_vel();
        r.occ.attackBearing = h.wcmGoal.get_attack_bearing();
      end

      if r.free.detect == 1
        r.obstacle = {};
        r.obstacle.num = h.ocmObstacle.get_num();
        r.obstacle.centroid_x = h.ocmObstacle.get_cx();
        r.obstacle.centroid_y = h.ocmObstacle.get_cy();
        r.obstacle.nearest_x = h.ocmObstacle.get_nx();
        r.obstacle.nearest_y = h.ocmObstacle.get_ny();
        r.obstacle.nearest_dist = h.ocmObstacle.get_ndist();
      end
      
      r.bd = {};
      bdTop = h.vcmBoundary.get_top();
	    bdBtm = h.vcmBoundary.get_bottom();
      bdCol = size(bdTop,2)/2;
      r.bd = struct('detect',h.vcmBoundary.get_detect(),...
                    'nCol',bdCol,...
                    'topy',bdTop(1,1:bdCol),...
                    'topx',-bdTop(1,bdCol+1:2*bdCol),...
                    'btmy',bdBtm(1,1:bdCol),...
                    'btmx',-bdBtm(1,bdCol+1:2*bdCol));

      % add horizon line
      r.horizon = {};
      labelAm = h.vcmImagetop.get_width()/2;
      labelBm = labelAm/h.vcmImagetop.get_scaleB();
	    horizonDir = h.vcmImagetop.get_horizonDir();
      horizonA = h.vcmImagetop.get_horizonA();
      horizonB = h.vcmImagetop.get_horizonB();
      horizonAx = 1 : labelAm;
      horizonBx = 1 : labelBm;
      horizonAy = (horizonAx - horizonAx(end)/2) .* tan(horizonDir) + horizonA;
      horizonBy = (horizonBx - horizonBx(end)/2) .* tan(horizonDir) + horizonB;
      r.horizon = struct('hYA',horizonAy,...
                         'hYB',horizonBy,...
                         'hXA',horizonAx,...
                         'hXB',horizonBx);
    catch
    end 
  end

  function yuyv = get_yuyv(nc)  
% returns the raw YUYV image
    if nc == 1 %top camera 
      width = h.vcmImagetop.get_width()/2;
      height = h.vcmImagetop.get_height();
      rawData = h.vcmImagetop.get_yuyv();
      yuyv = raw2yuyv(rawData, width, height); %for Nao, double for OP
    else %bottom camera
      width = h.vcmImagebtm.get_width()/2;
      height = h.vcmImagebtm.get_height();
      rawData = h.vcmImagebtm.get_yuyv();
      yuyv = raw2yuyv(rawData, width, height); 
    end
  end

  function set_yuyv(yuyv, nc) 
    rawData=yuyv2raw(yuyv);
    if nc == 1 %top camera
      h.vcmImagetop.set_yuyv(rawData);
    else %bottom camera
      h.vcmImagebtm.set_yuyv(rawData);
    end
  end

  function yuyv2 = get_yuyv2(nc) 
% returns the half-size raw YUYV image
    if nc == 1
      width = h.vcmImagetop.get_width()/4;
      height = h.vcmImagetop.get_height()/2;
      rawData = h.vcmImagetop.get_yuyv2();
      yuyv2 = raw2yuyv(rawData, width, height); %for Nao, double for OP
    else
      width = h.vcmImagebtm.get_width()/4;
      height = h.vcmImagebtm.get_height()/2;
      rawData = h.vcmImagebtm.get_yuyv2();
      yuyv2 = raw2yuyv(rawData, width, height);
    end
  end

  function yuyv3 = get_yuyv3(nc) 
% returns the quater-size raw YUYV imagei
    if nc == 1
      width = h.vcmImagetop.get_width()/8;
      height = h.vcmImagetop.get_height()/4;
      rawData = h.vcmImagetop.get_yuyv3();
      yuyv3 = raw2yuyv(rawData, width, height); 
    else
      width = h.vcmImagebtm.get_width()/8;
      height = h.vcmImagebtm.get_height()/4;
      rawData = h.vcmImagebtm.get_yuyv3();
      yuyv3 = raw2yuyv(rawData, width, height); 

    end
  end

  function rgb = get_rgb() 
% returns the raw RGB image (not full size)
    yuyv = h.get_yuyv();
    rgb = yuyv2rgb(yuyv);
  end

  function Cb = get_cb(nc)  % returns the labeled image
    if nc == 1
      rawCb = h.vcmImagetop.get_cb();
      width = h.vcmImagetop.get_width()/h.vcmImagetop.get_scaleA();
      height = h.vcmImagetop.get_height()/h.vcmImagetop.get_scaleA();
    else
      rawCb = h.vcmImagebtm.get_cb();
      width = h.vcmImagebtm.get_width()/h.vcmImagebtm.get_scaleA();
      height = h.vcmImagebtm.get_height()/h.vcmImagebtm.get_scaleA();
    end
    %Now webots uses the same sampled label image (160 by 120 for example)    
    Cb = raw2label(rawCb, width, height)';
  end

  function cbScaleB = get_cbScaleB(nc)  % returns the labeled image
    if nc == 1
      rawCbScaleB = h.vcmImagetop.get_cbScaleB();
      width = h.vcmImagetop.get_width()/h.vcmImagetop.get_scaleA()/h.vcmImagetop.get_scaleB();
      height = h.vcmImagetop.get_height()/h.vcmImagetop.get_scaleA()/h.vcmImagetop.get_scaleB();
    else
      rawCbScaleB = h.vcmImagebtm.get_cbScaleB();
      width = h.vcmImagebtm.get_width()/h.vcmImagetop.get_scaleA()/h.vcmImagebtm.get_scaleB();
      height = h.vcmImagebtm.get_height()/h.vcmImagetop.get_scaleA()/h.vcmImagebtm.get_scaleB();
    end
    %Now webots uses the same sampled label image (160 by 120 for example)    
    cbScaleB = raw2label(rawCbScaleB, width, height)';
  end

  function labelA = get_labelA(nc)  % returns the labeled image
    % SCALE SHOULDNT BE HARDCODED HERE!!!!    
    
    if nc == 1
      rawData = h.vcmImagetop.get_labelA();
      width = h.vcmImagetop.get_width()/h.vcmImagetop.get_scaleA();
      height = h.vcmImagetop.get_height()/h.vcmImagetop.get_scaleA();
    else
      rawData = h.vcmImagebtm.get_labelA();
      width = h.vcmImagebtm.get_width()/h.vcmImagebtm.get_scaleA();
      height = h.vcmImagebtm.get_height()/h.vcmImagebtm.get_scaleA();
    end
    %Now webots uses the same sampled label image (160 by 120 for example)    
    labelA = raw2label(rawData, width, height)';
  end

  function set_labelA(label,nc)
    rawData=label2raw(label');
    if nc == 1
      h.vcmImagetop.set_labelA(rawData);
    else
      h.vcmImagebtm.set_labelA(rawData);
    end
  end



  function labelB = get_labelB(nc)      
    % returns the bit-ored labeled image
    
    if nc == 1
      width = h.vcmImagetop.get_width()/h.vcmImagetop.get_scaleA()/h.vcmImagetop.get_scaleB();
      height = h.vcmImagetop.get_height()/h.vcmImagetop.get_scaleA()/h.vcmImagetop.get_scaleB();
      rawData = h.vcmImagetop.get_labelB();
    else 
      width = h.vcmImagebtm.get_width()/h.vcmImagebtm.get_scaleA()/h.vcmImagebtm.get_scaleB();
      height = h.vcmImagebtm.get_height()/h.vcmImagebtm.get_scaleA()/h.vcmImagebtm.get_scaleB();
      rawData = h.vcmImagebtm.get_labelB();
    end
   
    labelB = raw2label(rawData, width, height)';
  end


  function occ_p = get_occ_likelihood()
			map = h.ocmOcc.get_map();
      map = typecast(map, 'uint32');
      robot_pos = h.ocmOcc.get_robot_pos();
			mapsize = sqrt(size(map,2));
      map_resolution = 1 / mapsize;
			map = reshape(map, [mapsize, mapsize]);
			occ_p = double(map) / 10000;
      occ = {};
      occ.map = occ_p;
      occ.robot_pos = robot_pos;
      occ.mapsize = mapsize;
%      save('mapdata.mat');
      plot_occ(occ);
  end
end
