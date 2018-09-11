% eegplugin_lrpcall() - EEGLAB plugin for the computation of the
% Readiness potential
% Usage:
%   >> eegplugin_lrpcall(fig, trystrs, catchstrs)
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks. 
%
% Create a plugin:
%   For more information on how to create an EEGLAB plugin see the
%   help message of eegplugin_besa() or visit http://www.sccn.ucsd.edu/eeglab/contrib.html
%
% Author:  Remo Arena(remo.arena@gmail.com, Politecnico di Torino, 
%          Torino, Italy, 2016) 
% Copyright (C) 2016 Remo Arena
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
function eegplugin_lrpcall( fig, try_strings, catch_strings); 
 
% create menu
plotmenu = findobj(fig, 'tag', 'EEGLAB');
ELmenu = uimenu( plotmenu,'Label','LRP','separator','on','tag','LRPLAB','userdata','startup:on;continuous:on;epoch:on;study:on;erpset:on');

submenu01 = uimenu( ELmenu, 'label', 'AutoImport');
uimenu( submenu01, 'label', 'Auto epoch and filter','callback', 'importtoEEGLAB; epochandfilter; ');
uimenu( submenu01, 'label', 'Complete Analysis','callback', "importtoEEGLAB; epochandfilter; laplRP; ERDmain(EEG,{'C3'},8,12);ERDmain(EEG,{'C3'},26,30);");
submenu11 = uimenu( ELmenu, 'label', 'Preprocessing');
uimenu( submenu11, 'label', 'Import raw data','callback','importtoEEGLAB; eeglab redraw');
uimenu( submenu11, 'label', 'Filter Continuous Data','callback', 'EEG = myfilterEEG(EEG); eeglab redraw');
uimenu( submenu11, 'label', 'Epoch and filter','callback', 'epochandfilter; eeglab redraw');
uimenu( submenu11, 'label', 'Compute laplacian LRP ','callback', 'laplRP');
uimenu( submenu11, 'label', 'Find ERD/S ','callback', 'ERDmain(EEG)'); 
submenu21 = uimenu( ELmenu, 'label', 'Detector');
uimenu( submenu21, 'label', 'Load Template','callback', 'loadtemplate');
uimenu( submenu21, 'label', 'Perform EMD on continuous data','callback', 'EMDcontinuousdata');
uimenu( submenu21, 'label', 'Detect with Matched Filter','callback', 'detect');
% submenu21 =uimenu( ELmenu, 'label', 'Compute ERD/S ');
% uimenu( submenu21, 'Label', 'Alpha',  'callBack', 'ERDS');
% uimenu( submenu21, 'Label', 'BETA',  'callBack', 'ERDSbeta');
% uimenu( submenu21, 'Label', 'Mu',  'callBack', 'ERDSmu');
