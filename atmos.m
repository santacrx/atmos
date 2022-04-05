function varargout = atmos(h,varargin)
% [T,P,rho,a] = atmos(h)
% [T,P,rho,a] = atmos(h,Units)
% [output] = atmos(h,[],'Output')
%
% Atmospheric tables interpolation output for a given altitude. Results are
% valid from -2km to 85km height. Based on U.S. Standard Atmosphere 1976
% tables. Output can be in SI (default) or Imperial if desired
%
% Inputs:
%   h       = altitude [m -OR- ft]
%   Units   = 'm' [default if empty] or 'ft' 
%   Output  = 'all' [default if empty], 'T', 'P', 'rho', or 'a'
%
% Outputs:
%   T       Temperature, in [C] or [F]
%   P       Pressure, in [N/m^2 (Pa)] or [lbf/ft^2] 
%   rho     Density, in [kg/m^3] or [slug/ft^3]
%   a       Speed of Sound, in [m/s] or [ft/s]
%
% =====
% Xavier Santacruz
% github.com/santacrx/atmos
% 2022/4/4

%check if optional input is selected
Units='m';
out='all';
if ~isempty(varargin)
    if nargin>2
        out=varargin{2};
    end
    Units=varargin{1};
end

%load data from tables 1 and 2. Data units: [km; K; N/m^2; kg/m^3; m/s]
alt=[-2,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15,15.5,16,16.5,17,17.5,18,18.5,19,19.5,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86];
temp=[301.2,291.4,288.1,284.9,281.7,278.4,275.2,271.9,268.7,265.4,262.2,258.9,255.7,252.4,249.2,245.9,242.7,239.5,236.2,233,229.7,226.5,223.3,220,216.8,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,216.6,218.6,220.6,222.5,224.5,226.5,228.5,233.7,239.3,244.8,250.4,255.9,261.4,266.9,270.6,270.6,269,263.5,258,252.5,247,241.5,236,230.5,225.1,219.6,214.3,210.3,206.4,202.5,198.6,194.7,190.8,186.9];
press=[127800,107477,101325,95461,89876,84559,79501,74691,70121,65780,61660,57752,54048,50539,47217,44075,41105,38299,35651,33154,30800,28584,26499,24540,22699,20984,19399,17933,16579,15327,14170,13100,12111,11197,10352,9571,8849,8182,7565,6994,6467,5979,5529,4047,2972,2188,1616,1197,889,663.4,498.5,377.1,287.1,220,169.5,131.3,102.3,79.77,62.21,48.33,37.36,28.72,21.96,16.69,12.60,9.459,7.051,5.220,3.835,2.800,2.033,1.467,1.052,0.7498,0.5308,0.3732];
dens=[1.478,1.285,1.225,1.167,1.112,1.058,1.007,0.9570,0.9090,0.8630,0.8190,0.7770,0.7360,0.6970,0.6600,0.6240,0.5900,0.5570,0.5260,0.4960,0.4670,0.4400,0.4140,0.3890,0.3650,0.3370,0.3120,0.2880,0.2670,0.2460,0.2280,0.2110,0.1950,0.1800,0.1660,0.1540,0.1420,0.1320,0.1220,0.1120,0.1040,0.09600,0.08900,0.06451,0.04694,0.03426,0.02508,0.01841,0.01355,0.009887,0.007257,0.005366,0.003995,0.002995,0.002259,0.001714,0.001317,0.001027,0.0008055,0.0006389,0.0005044,0.0003962,0.0003096,0.0002407,0.0001860,0.0001429,0.0001091,8.281e-05,6.236e-05,4.637e-05,3.430e-05,2.523e-05,1.845e-05,1.341e-05,9.690e-06,6.955e-06];
aa=[347.9,342.2,340.3,338.4,336.4,334.5,332.5,330.6,328.6,326.6,324.6,322.6,320.5,318.5,316.5,314.4,312.3,310.2,308.1,306,303.8,301.7,299.5,297.4,295.2,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,295.1,296.4,297.7,299.1,300.4,301.7,303,306.5,310.1,313.7,317.2,320.7,324.1,327.5,329.8,329.8,328.8,325.4,322,318.6,315.1,311.5,308,304.4,300.7,297.1,293.4,290.7,288,285.3,282.5,279.7,276.9,274.1];

%convert to m, if input is in feet
if strcmp(Units,'ft')
        h = h.*0.3048; % [ft] to [m]
end
%convert input to kilometers
h=h./1000;% [km]

%check that value is within available data
if h>86 | h<-2
    warning('Input is out of range (-2<h<86km). Output value will be the last valid value of the table');
end

%if over, output the last known value
if h>86
    T=temp(end);
    P=press(end);
    rho=dens(end);
    a=aa(end);
%if under, output the first value
elseif h<-2
    T=temp(1);
    P=press(1);
    rho=dens(1);
    a=aa(1);
%if within range, interpolate and get value at desired
else
    T=interp1(alt,temp,h,'pchip'); %[K]
    P=interp1(alt,press,h,'pchip'); %[Pa (N/m^2)]
    rho=interp1(alt,dens,h,'pchip'); %[kg/m^3]
    a=interp1(alt,aa,h,'pchip'); %[m/s]
end

%convert temperature to Celsius
T=T-273.15; %[C]

%convert to english units if so selected by user
if strcmp(Units,'ft')
    %T=T.*1.8; %[R]
    T=T.*1.8 + 32; %[F]
    P=P.*47.88; %[lbf/ft^2]
    rho=rho.*16.01845; %[lb/ft^3]
    a=a./0.3048; %[ft/s]
end

switch out
    case 'all'
        varargout={T,P,rho,a};
    otherwise
        varargout={eval(out)};
end
end