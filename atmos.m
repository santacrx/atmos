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
%   Output  = 'all' [default if empty], 'T', 'P', 'rho', 'a', or a
%              combination for multiple outputs; i.e.: 'rho,a'
%             NOTE: Ensure the same number of variables are set to output
%             to as those selected for input, else function will error.
%
% Outputs:
%   T       Temperature, in [C] or [F]
%   P       Pressure, in [N/m^2 (Pa)] or [lbf/ft^2] 
%   rho     Density, in [kg/m^3] or [slug/ft^3]
%   a       Speed of Sound, in [m/s] or [ft/s]
%
% Examples:
%   * Get all values at 1000m above sea level
%       [T,P,rho,a] = atmos(1000)
%   * Only get density and speed of sound in imperial units at 5000 ft
%       [rho,a]=atmos(5000,'ft','rho,a');
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
T1=atmostables(1);
T2=atmostables(2);
T=[T1(:,[1,5:8]); T2(:,[1,5:8])];
T=sortrows(T);
[~,uT,~]=unique(T(:,1));
aT=T(uT,:);
clear T1 T2 uT T
alt=aT(:,1)';
temp=aT(:,2)';
press=aT(:,3)';
dens=aT(:,4)';
aa=aT(:,5)';
clear aT

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
    T=interp1(alt,temp,h); %[K]
    P=interp1(alt,press,h); %[Pa (N/m^2)]
    rho=interp1(alt,dens,h); %[kg/m^3]
    a=interp1(alt,aa,h); %[m/s]
end

%convert temperature to Celsius
T=T-273.15; %[C]

%convert to english units if so selected by user
if strcmp(Units,'ft')
    %T=T.*1.8; %[R]
    T=T.*1.8 + 32; %[F]
    P=P./47.88; %[lbf/ft^2]
    rho=rho.*0.001940320331980; %[slugs/ft^3]
    a=a./0.3048; %[ft/s]
end

switch out
    case 'all'
        varargout={T,P,rho,a};
    otherwise
        eval(['varargout={' out '};']);
end
end

function T=atmostables(opt)
switch opt
    case 2
        % ====
        % In this table from -0.5 to 20 km in 0.5 km intervals
        %
        % 	alt is altitude in kilometers.
        % 	sigma is density divided by sea-level density.
        % 	delta is pressure divided by sea-level pressure.
        % 	theta is temperature divided by sea-level temperature.
        % 	temp is temperature in kelvins.
        % 	press is pressure in newtons per square meter.
        % 	dens is density in kilograms per cubic meter.
        % 	a is the speed of sound in meters per second.
        % 	visc is viscosity in 10**(-6) kilograms per meter-second.
        % 	k.visc is kinematic viscosity in square meters per second.
        % 	ratio is 10**(-6) times speed of sound divided by kinematic viscosity (1/m)
        % ===
        T=[...
         ... alt  sigma  delta  theta  temp  press  dens   a    visc  k.visc ratio
            -0.5 1.0489 1.0607 1.0113 291.4 107477 1.285 342.2 18.05 1.40E-5 24.36;...
            0.0 1.0000 1.0000 1.0000 288.1 101325 1.225 340.3 17.89 1.46E-5 23.30;...
            0.5 0.9529 0.9421 0.9887 284.9  95461 1.167 338.4 17.74 1.52E-5 22.27;...
            1.0 0.9075 0.8870 0.9774 281.7  89876 1.112 336.4 17.58 1.58E-5 21.28;...
            1.5 0.8638 0.8345 0.9662 278.4  84559 1.058 334.5 17.42 1.65E-5 20.32;...
            2.0 0.8217 0.7846 0.9549 275.2  79501 1.007 332.5 17.26 1.71E-5 19.39;...
            2.5 0.7812 0.7372 0.9436 271.9  74691 0.957 330.6 17.10 1.79E-5 18.50;...
            3.0 0.7422 0.6920 0.9324 268.7  70121 0.909 328.6 16.94 1.86E-5 17.64;...
            3.5 0.7048 0.6492 0.9211 265.4  65780 0.863 326.6 16.78 1.94E-5 16.81;...
            4.0 0.6689 0.6085 0.9098 262.2  61660 0.819 324.6 16.61 2.03E-5 16.01;...
            4.5 0.6343 0.5700 0.8986 258.9  57752 0.777 322.6 16.45 2.12E-5 15.24;...
            5.0 0.6012 0.5334 0.8873 255.7  54048 0.736 320.5 16.28 2.21E-5 14.50;...
            5.5 0.5694 0.4988 0.8760 252.4  50539 0.697 318.5 16.12 2.31E-5 13.78;...
            6.0 0.5389 0.4660 0.8648 249.2  47217 0.660 316.5 15.95 2.42E-5 13.10;...
            6.5 0.5096 0.4350 0.8535 245.9  44075 0.624 314.4 15.78 2.53E-5 12.44;...
            7.0 0.4816 0.4057 0.8423 242.7  41105 0.590 312.3 15.61 2.65E-5 11.80;...
            7.5 0.4548 0.3780 0.8310 239.5  38299 0.557 310.2 15.44 2.77E-5 11.19;...
            8.0 0.4292 0.3519 0.8198 236.2  35651 0.526 308.1 15.27 2.90E-5 10.61;...
            8.5 0.4047 0.3272 0.8085 233.0  33154 0.496 306.0 15.10 3.05E-5 10.05;...
            9.0 0.3813 0.3040 0.7973 229.7  30800 0.467 303.8 14.93 3.20E-5  9.51;...
            9.5 0.3589 0.2821 0.7860 226.5  28584 0.440 301.7 14.75 3.36E-5  8.99;...
            10.0 0.3376 0.2615 0.7748 223.3  26499 0.414 299.5 14.58 3.53E-5  8.50;...
            10.5 0.3172 0.2422 0.7635 220.0  24540 0.389 297.4 14.40 3.71E-5  8.02;...
            11.0 0.2978 0.2240 0.7523 216.8  22699 0.365 295.2 14.22 3.90E-5  7.57;...
            11.5 0.2755 0.2071 0.7519 216.6  20984 0.337 295.1 14.22 4.21E-5  7.00;...
            12.0 0.2546 0.1915 0.7519 216.6  19399 0.312 295.1 14.22 4.56E-5  6.47;...
            12.5 0.2354 0.1770 0.7519 216.6  17933 0.288 295.1 14.22 4.93E-5  5.99;...
            13.0 0.2176 0.1636 0.7519 216.6  16579 0.267 295.1 14.22 5.33E-5  5.53;...
            13.5 0.2012 0.1513 0.7519 216.6  15327 0.246 295.1 14.22 5.77E-5  5.12;...
            14.0 0.1860 0.1398 0.7519 216.6  14170 0.228 295.1 14.22 6.24E-5  4.73;...
            14.5 0.1720 0.1293 0.7519 216.6  13100 0.211 295.1 14.22 6.75E-5  4.37;...
            15.0 0.1590 0.1195 0.7519 216.6  12111 0.195 295.1 14.22 7.30E-5  4.04;...
            15.5 0.1470 0.1105 0.7519 216.6  11197 0.180 295.1 14.22 7.90E-5  3.74;...
            16.0 0.1359 0.1022 0.7519 216.6  10352 0.166 295.1 14.22 8.54E-5  3.46;...
            16.5 0.1256 0.0945 0.7519 216.6   9571 0.154 295.1 14.22 9.24E-5  3.19;...
            17.0 0.1162 0.0873 0.7519 216.6   8849 0.142 295.1 14.22 9.99E-5  2.95;...
            17.5 0.1074 0.0808 0.7519 216.6   8182 0.132 295.1 14.22 1.08E-4  2.73;...
            18.0 0.0993 0.0747 0.7519 216.6   7565 0.122 295.1 14.22 1.17E-4  2.52;...
            18.5 0.0918 0.0690 0.7519 216.6   6994 0.112 295.1 14.22 1.26E-4  2.33;...
            19.0 0.0849 0.0638 0.7519 216.6   6467 0.104 295.1 14.22 1.37E-4  2.16;...
            19.5 0.0785 0.0590 0.7519 216.6   5979 0.096 295.1 14.22 1.48E-4  2.00;...
            20.0 0.0726 0.0546 0.7519 216.6   5529 0.089 295.1 14.22 1.60E-4  1.85];
    otherwise
        % ====
        % In this table from -2 to 86 km in 2 km intervals
        %
        % 	alt is altitude in kilometers.
        % 	sigma is density divided by sea-level density.
        % 	delta is pressure divided by sea-level pressure.
        % 	theta is temperature divided by sea-level temperature.
        % 	temp is temperature in kelvins.
        % 	press is pressure in newtons per square meter.
        % 	dens is density in kilograms per cubic meter.
        % 	a is the speed of sound in meters per second.
        % 	visc is viscosity in 10**(-6) kilograms per meter-second.
        % 	k.visc is kinematic viscosity in square meters per second.
        % ===
        T=[...
         ...alt    sigma     delta   theta  temp   press    dens     a    visc  k.visc
            -2 1.2067E+0 1.2611E+0 1.0451 301.2 1.278E+5 1.478E+0 347.9 18.51 1.25E-5;...
            0 1.0000E+0 1.0000E+0 1.0000 288.1 1.013E+5 1.225E+0 340.3 17.89 1.46E-5;...
            2 8.2168E-1 7.8462E-1 0.9549 275.2 7.950E+4 1.007E+0 332.5 17.26 1.71E-5;...
            4 6.6885E-1 6.0854E-1 0.9098 262.2 6.166E+4 8.193E-1 324.6 16.61 2.03E-5;...
            6 5.3887E-1 4.6600E-1 0.8648 249.2 4.722E+4 6.601E-1 316.5 15.95 2.42E-5;...
            8 4.2921E-1 3.5185E-1 0.8198 236.2 3.565E+4 5.258E-1 308.1 15.27 2.90E-5;...
            10 3.3756E-1 2.6153E-1 0.7748 223.3 2.650E+4 4.135E-1 299.5 14.58 3.53E-5;...
            12 2.5464E-1 1.9146E-1 0.7519 216.6 1.940E+4 3.119E-1 295.1 14.22 4.56E-5;...
            14 1.8600E-1 1.3985E-1 0.7519 216.6 1.417E+4 2.279E-1 295.1 14.22 6.24E-5;...
            16 1.3589E-1 1.0217E-1 0.7519 216.6 1.035E+4 1.665E-1 295.1 14.22 8.54E-5;...
            18 9.9302E-2 7.4662E-2 0.7519 216.6 7.565E+3 1.216E-1 295.1 14.22 1.17E-4;...;...
            20 7.2578E-2 5.4569E-2 0.7519 216.6 5.529E+3 8.891E-2 295.1 14.22 1.60E-4;...
            22 5.2660E-2 3.9945E-2 0.7585 218.6 4.047E+3 6.451E-2 296.4 14.32 2.22E-4;...
            24 3.8316E-2 2.9328E-2 0.7654 220.6 2.972E+3 4.694E-2 297.7 14.43 3.07E-4;...
            26 2.7964E-2 2.1597E-2 0.7723 222.5 2.188E+3 3.426E-2 299.1 14.54 4.24E-4;...
            28 2.0470E-2 1.5950E-2 0.7792 224.5 1.616E+3 2.508E-2 300.4 14.65 5.84E-4;...
            30 1.5028E-2 1.1813E-2 0.7861 226.5 1.197E+3 1.841E-2 301.7 14.75 8.01E-4;...
            32 1.1065E-2 8.7740E-3 0.7930 228.5 8.890E+2 1.355E-2 303.0 14.86 1.10E-3;...
            34 8.0709E-3 6.5470E-3 0.8112 233.7 6.634E+2 9.887E-3 306.5 15.14 1.53E-3;...
            36 5.9245E-3 4.9198E-3 0.8304 239.3 4.985E+2 7.257E-3 310.1 15.43 2.13E-3;...
            38 4.3806E-3 3.7218E-3 0.8496 244.8 3.771E+2 5.366E-3 313.7 15.72 2.93E-3;...
            40 3.2615E-3 2.8337E-3 0.8688 250.4 2.871E+2 3.995E-3 317.2 16.01 4.01E-3;...
            42 2.4445E-3 2.1708E-3 0.8880 255.9 2.200E+2 2.995E-3 320.7 16.29 5.44E-3;...
            44 1.8438E-3 1.6727E-3 0.9072 261.4 1.695E+2 2.259E-3 324.1 16.57 7.34E-3;...
            46 1.3992E-3 1.2961E-3 0.9263 266.9 1.313E+2 1.714E-3 327.5 16.85 9.83E-3;...
            48 1.0748E-3 1.0095E-3 0.9393 270.6 1.023E+2 1.317E-3 329.8 17.04 1.29E-2;...
            50 8.3819E-4 7.8728E-4 0.9393 270.6 7.977E+1 1.027E-3 329.8 17.04 1.66E-2;...
            52 6.5759E-4 6.1395E-4 0.9336 269.0 6.221E+1 8.055E-4 328.8 16.96 2.10E-2;...
            54 5.2158E-4 4.7700E-4 0.9145 263.5 4.833E+1 6.389E-4 325.4 16.68 2.61E-2;...
            56 4.1175E-4 3.6869E-4 0.8954 258.0 3.736E+1 5.044E-4 322.0 16.40 3.25E-2;...
            58 3.2344E-4 2.8344E-4 0.8763 252.5 2.872E+1 3.962E-4 318.6 16.12 4.07E-2;...
            60 2.5276E-4 2.1668E-4 0.8573 247.0 2.196E+1 3.096E-4 315.1 15.84 5.11E-2;...
            62 1.9647E-4 1.6468E-4 0.8382 241.5 1.669E+1 2.407E-4 311.5 15.55 6.46E-2;...
            64 1.5185E-4 1.2439E-4 0.8191 236.0 1.260E+1 1.860E-4 308.0 15.26 8.20E-2;...
            66 1.1668E-4 9.3354E-5 0.8001 230.5 9.459E+0 1.429E-4 304.4 14.97 1.05E-1;...
            68 8.9101E-5 6.9593E-5 0.7811 225.1 7.051E+0 1.091E-4 300.7 14.67 1.34E-1;...
            70 6.7601E-5 5.1515E-5 0.7620 219.6 5.220E+0 8.281E-5 297.1 14.38 1.74E-1;...
            72 5.0905E-5 3.7852E-5 0.7436 214.3 3.835E+0 6.236E-5 293.4 14.08 2.26E-1;...
            74 3.7856E-5 2.7635E-5 0.7300 210.3 2.800E+0 4.637E-5 290.7 13.87 2.99E-1;...
            76 2.8001E-5 2.0061E-5 0.7164 206.4 2.033E+0 3.430E-5 288.0 13.65 3.98E-1;...
            78 2.0597E-5 1.4477E-5 0.7029 202.5 1.467E+0 2.523E-5 285.3 13.43 5.32E-1;...
            80 1.5063E-5 1.0384E-5 0.6893 198.6 1.052E+0 1.845E-5 282.5 13.21 7.16E-1;...
            82 1.0950E-5 7.4002E-6 0.6758 194.7 7.498E-1 1.341E-5 279.7 12.98 9.68E-1;...
            84 7.9106E-6 5.2391E-6 0.6623 190.8 5.308E-1 9.690E-6 276.9 12.76 1.32E+0;...
            86 5.6777E-6 3.6835E-6 0.6488 186.9 3.732E-1 6.955E-6 274.1 12.53 1.80E+0];
end
end