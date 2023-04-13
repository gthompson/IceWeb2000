function p = pathdef
%PATHDEF Search path defaults.
%   PATHDEF returns a string that can be used as input to MATLABPATH
%   in order to set the path.

  
%   Copyright 1984-2000 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2000/06/01 16:19:21 $

% PATH DEFINED HERE -- Don't change this line.

p = [...
matlabroot,'/toolbox/local/seismo:',...
matlabroot,'/toolbox/antelope/antelope:',...
matlabroot,'/toolbox/antelope/examples:',...
matlabroot,'/toolbox/matlab/general:',...
matlabroot,'/toolbox/matlab/ops:',...
matlabroot,'/toolbox/matlab/lang:',...
matlabroot,'/toolbox/matlab/elmat:',...
matlabroot,'/toolbox/matlab/elfun:',...
matlabroot,'/toolbox/matlab/specfun:',...
matlabroot,'/toolbox/matlab/matfun:',...
matlabroot,'/toolbox/matlab/datafun:',...
matlabroot,'/toolbox/matlab/audio:',...
matlabroot,'/toolbox/matlab/polyfun:',...
matlabroot,'/toolbox/matlab/funfun:',...
matlabroot,'/toolbox/matlab/sparfun:',...
matlabroot,'/toolbox/matlab/graph2d:',...
matlabroot,'/toolbox/matlab/graph3d:',...
matlabroot,'/toolbox/matlab/specgraph:',...
matlabroot,'/toolbox/matlab/graphics:',...
matlabroot,'/toolbox/matlab/uitools:',...
matlabroot,'/toolbox/matlab/strfun:',...
matlabroot,'/toolbox/matlab/iofun:',...
matlabroot,'/toolbox/matlab/timefun:',...
matlabroot,'/toolbox/matlab/datatypes:',...
matlabroot,'/toolbox/matlab/verctrl:',...
matlabroot,'/toolbox/matlab/demos:',...
matlabroot,'/toolbox/local:',...
matlabroot,'/toolbox/simulink/simulink:',...
matlabroot,'/toolbox/simulink/blocks:',...
matlabroot,'/toolbox/simulink/components:',...
matlabroot,'/toolbox/simulink/fixedandfloat:',...
matlabroot,'/toolbox/simulink/fixedandfloat/fxpdemos:',...
matlabroot,'/toolbox/simulink/fixedandfloat/obsolete:',...
matlabroot,'/toolbox/simulink/simdemos:',...
matlabroot,'/toolbox/simulink/simdemos/aerospace:',...
matlabroot,'/toolbox/simulink/simdemos/automotive:',...
matlabroot,'/toolbox/simulink/simdemos/simfeatures:',...
matlabroot,'/toolbox/simulink/simdemos/simgeneral:',...
matlabroot,'/toolbox/simulink/simdemos/simnew:',...
matlabroot,'/toolbox/simulink/simdemos/simcpp:',...
matlabroot,'/toolbox/simulink/dee:',...
matlabroot,'/toolbox/simulink/dastudio:',...
matlabroot,'/toolbox/stateflow/stateflow:',...
matlabroot,'/toolbox/stateflow/sfdemos:',...
matlabroot,'/toolbox/stateflow/coder:',...
matlabroot,'/toolbox/images/images:',...
matlabroot,'/toolbox/images/imdemos:',...
matlabroot,'/toolbox/map/map:',...
matlabroot,'/toolbox/map/mapdisp:',...
matlabroot,'/toolbox/map/mapproj:',...
matlabroot,'/toolbox/sb2sl:',...
matlabroot,'/toolbox/signal/signal:',...
matlabroot,'/toolbox/signal/sigtools:',...
matlabroot,'/toolbox/signal/sptoolgui:',...
matlabroot,'/toolbox/signal/sigdemos:',...
matlabroot,'/toolbox/stats:',...
'/home/iceweb/REAL_TIME_CODE:',...
'/home/iceweb/ICEWEB_UTILITIES',...
     ...
];

p = [userpath,p];
