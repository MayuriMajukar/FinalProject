function varargout = MAINGUI(varargin)
% MAINGUI MATLAB code for MAINGUI.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAINGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAINGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAINGUI

% Last Modified by GUIDE v2.5 13-May-2019 11:21:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAINGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MAINGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MAINGUI is made visible.
function MAINGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MAINGUI (see VARARGIN)

% Choose default command line output for MAINGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAINGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MAINGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in btn_scan.
function btn_scan_Callback(hObject, eventdata, handles)
% hObject    handle to btn_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fullfilepath

set(handles.txt_output,'String','NONE');
if exist('PHOGTest.xls', 'file')==2
  delete('PHOGTest.xls');
end

if exist('GaborTest.xls', 'file')==2
  delete('GaborTest.xls');
end

system('C:\Program Files\Mantra\MFS100\DriverWin10\MFS100Test\Mantra.MFS100.Test.exe')

fullfilepath = 'C:\Program Files\Mantra\MFS100\DriverWin10\MFS100Test\FingerData\FingerImage.bmp';

fingerprint_image = imread('C:\Program Files\Mantra\MFS100\DriverWin10\MFS100Test\FingerData\FingerImage.bmp');
axes(handles.axes1);
imshow(fingerprint_image);

% --- Executes on button press in btn_browse.
function btn_browse_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fullfilepath
if exist('PHOGTest.xls', 'file')==2
  delete('PHOGTest.xls');
end

if exist('GaborTest.xls', 'file')==2
  delete('GaborTest.xls');
end

[filename,pathname] = uigetfile('*.jpg;*.tif;*.png;*.jpeg;*.bmp;*.pgm;*.gif','Select FingerPrint Image');
fullfilepath = fullfile(pathname,filename);
disp(fullfilepath);

axes(handles.axes1);
imshow(imread(fullfilepath));

% --- Executes on button press in btn_gender.
function btn_gender_Callback(hObject, eventdata, handles)
% hObject    handle to btn_gender (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fullfilepath

set(handles.txt_output,'String','NONE');

clear net

load neural_netwrk_gender

figure('name','Test Image Processing');

hold on

Test_image=imread(fullfilepath);
   
I  = Test_image;

subplot(231);imshow(I,[]);title('Input Image');

[p,q]=size(I);

if size(I,3) == 3
	I=rgb2gray(I);
end

A1=imcrop(I,[20 2 250 464]);

subplot(232);imshow(A1,[]);title('Cropped Image');

A3=medfilt2(A1,[3,3]);
	
subplot(233);imshow(A3,[]);title('Filtered Image');

A4=histeq(A3);
	
subplot(234);imshow(A4,[]);title('Enhanced Image');

% Feature Extraction using SURF

fingerPoints = detectSURFFeatures(A4);
	
subplot(235);
imshow(A4,[]);
title('F.Points from Test Image');
hold on;
plot(fingerPoints.selectStrongest(100));
    
% Extract feature descriptors at the interest points in both images.

[fingerFeatures, fingerPoints] = extractFeatures(A4, fingerPoints);

%APPLY PRINCIPAL COMPONENT ANALYSIS
B=pca(fingerFeatures);


% Feature Extraction using PHOG

bin = 8;
angle = 360;
L=3;
roi = [1;200;1;250];

G=A4; % Processed Image

if sum(sum(G))>100
		E = edge(G,'canny');
		[GradientX,GradientY] = gradient(double(G));
		disp(GradientX)
		disp(GradientY)
		GradientYY = gradient(GradientY);
		Gr = sqrt((GradientX.*GradientX)+(GradientY.*GradientY));
		
		subplot(236);
		
		imshow(uint8(Gr)); 
		title('PHOG Image');
		
		index = GradientX == 0;
		GradientX(index) = 1e-5;
				
		YX = GradientY./GradientX;
		if angle == 180, A = ((atan(YX)+(pi/2))*180)/pi; end
		if angle == 360, A = ((atan2(GradientY,GradientX)+pi)*180)/pi; end
									
		[bh bv] = anna_binMatrix(A,E,Gr,angle,bin);
else
		bh = zeros(size(I,1),size(I,2));
		bv = zeros(size(I,1),size(I,2));
end

bh_roi = bh(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
bv_roi = bv(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
p = anna_phogDescriptor(bh_roi,bv_roi,L,bin);

xlswrite('PHOGTest.xls',[p]);

a=xlsread('PHOGTest.xls');
a1=a(1:68,:);
a2=a(69:136,:);
a3=a(137:204,:);
a4=a(205:272,:);
a5=a(273:340,:);
a6=a(341:408,:);
a7=a(409:476,:);
a8=a(477:544,:);
a9=a(545:612,:);
a10=a(613:680,:);

E=[a1 a2 a3 a4 a5 a6 a7 a8 a9 a10];

B1=pca(E);

% Feature Extraction using Gabor

[gaborSquareEnergy, gaborMeanAmplitude ]= phasesym(A4);

A='Gabor Features Extracted';
%set(handles.edit1,'string',A);

G1=gaborSquareEnergy;
G2=gaborMeanAmplitude;
G=[G1;G2];
xlswrite('GaborTest.xls',[G]);

s=xlsread('GaborTest.xls');

B2 = pca(s);

% GET STANDARD DEVIATION AND VARIATION OF SURF PCA

Standard_Deviation = std2(B);

Variance = mean2(var(double(B)));

% GET STANDARD DEVIATION AND VARIATION OF PHOG PCA 

Standard_Deviation1 = std2(B1);

Variance1 = mean2(var(double(B1)));

% GABOR Features

gaborSquareEnergy = sum(sum( B2.^2 ) );

gaborMeanAmplitude = mean2( B2 );

inputs_testnn = [Standard_Deviation;Variance;Standard_Deviation1;Variance1;gaborMeanAmplitude;gaborSquareEnergy];

y=sim(net,inputs_testnn)

 A=10.*y
 round(A)
 disp(A)
 disp(fullfilepath);
 if(y<=0.4)
     set(handles.txt_output,'String','Male');
     myicon = imread('male.png');
     msgbox('Its a Male','Success','custom',myicon);
 else
     set(handles.txt_output,'String','Female');
     myicon = imread('female.jpg');
     msgbox('Its a Female','Success','custom',myicon)
 end

% --- Executes on button press in btn_age.
function btn_age_Callback(hObject, eventdata, handles)
% hObject    handle to btn_age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fullfilepath

clear net

load neural_netwrk_age

figure('name','Test Image Processing For Age Prediction');

hold on

Test_image=imread(fullfilepath);
   
I  = Test_image;

subplot(231);imshow(I,[]);title('Input Image');

[p,q]=size(I);

if size(I,3) == 3
	I=rgb2gray(I);
end

A1=imcrop(I,[20 2 250 464]);

subplot(232);imshow(A1,[]);title('Cropped Image');

A3=medfilt2(A1,[3,3]);
	
subplot(233);imshow(A3,[]);title('Filtered Image');

A4=histeq(A3);
	
subplot(234);imshow(A4,[]);title('Enhanced Image');

% Feature Extraction using SURF

fingerPoints = detectSURFFeatures(A4);
	
subplot(235);
imshow(A4,[]);
title('F.Points from Test Image');
hold on;
plot(fingerPoints.selectStrongest(100));
    
% Extract feature descriptors at the interest points in both images.

[fingerFeatures, fingerPoints] = extractFeatures(A4, fingerPoints);

%APPLY PRINCIPAL COMPONENT ANALYSIS
B=pca(fingerFeatures);

% Feature Extraction using PHOG

bin = 8;
angle = 360;
L=3;
roi = [1;200;1;250];

G=A4; % Processed Image

if sum(sum(G))>100
		E = edge(G,'canny');
		[GradientX,GradientY] = gradient(double(G));
		disp(GradientX)
		disp(GradientY)
		GradientYY = gradient(GradientY);
		Gr = sqrt((GradientX.*GradientX)+(GradientY.*GradientY));
		
		subplot(236);
		
		imshow(uint8(Gr)); 
		title('PHOG Image');
		
		index = GradientX == 0;
		GradientX(index) = 1e-5;
				
		YX = GradientY./GradientX;
		if angle == 180, A = ((atan(YX)+(pi/2))*180)/pi; end
		if angle == 360, A = ((atan2(GradientY,GradientX)+pi)*180)/pi; end
									
		[bh bv] = anna_binMatrix(A,E,Gr,angle,bin);
else
		bh = zeros(size(I,1),size(I,2));
		bv = zeros(size(I,1),size(I,2));
end

bh_roi = bh(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
bv_roi = bv(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
p = anna_phogDescriptor(bh_roi,bv_roi,L,bin);

xlswrite('PHOGTest.xls',[p]);

a=xlsread('PHOGTest.xls');
a1=a(1:68,:);
a2=a(69:136,:);
a3=a(137:204,:);
a4=a(205:272,:);
a5=a(273:340,:);
a6=a(341:408,:);
a7=a(409:476,:);
a8=a(477:544,:);
a9=a(545:612,:);
a10=a(613:680,:);

E=[a1 a2 a3 a4 a5 a6 a7 a8 a9 a10];

B1=pca(E);

% Feature Extraction using Gabor

[gaborSquareEnergy, gaborMeanAmplitude ]= phasesym(A4);

A='Gabor Features Extracted';
%set(handles.edit1,'string',A);

G1=gaborSquareEnergy;
G2=gaborMeanAmplitude;
G=[G1;G2];
xlswrite('GaborTest.xls',[G]);

s=xlsread('GaborTest.xls');

B2 = pca(s);

% GET STANDARD DEVIATION AND VARIATION OF SURF PCA

Standard_Deviation = std2(B);

Variance = mean2(var(double(B)));

% GET STANDARD DEVIATION AND VARIATION OF PHOG PCA 

Standard_Deviation1 = std2(B1);

Variance1 = mean2(var(double(B1)));


% GABOR Features

gaborSquareEnergy = sum(sum( B2.^2 ) );

gaborMeanAmplitude = mean2( B2 );

inputs_testnn = [Standard_Deviation;Variance;Standard_Deviation1;Variance1;gaborMeanAmplitude;gaborSquareEnergy];

out_r1=sim(net,inputs_testnn)

 round_r1=10.*out_r1
 round(round_r1)
 disp(round_r1)
 disp(fullfilepath);
 
disp('Final Output');

right_data=sprintf('The NeuNetwrk Value is %f and Round is %f',out_r1,round_r1);
disp(right_data);

if(out_r1<=1.59)
  msgbox('Age Lies Between 20 To 30 Years');
  set(handles.txt_output,'String','Age Lies Between 20 To 30 Years');
else if (out_r1>1.59 && out_r1<=2.48)
         msgbox('Age Lies Between 30 To 40 Years');
         set(handles.txt_output,'String','Age Lies Between 30 To 40 Years');
     else if (out_r1>2.48 && out_r1<=3.2)
            msgbox('Age Lies Between 40 To 50 Years');
            set(handles.txt_output,'String','Age Lies Between 40 To 50 Years');
          else if (out_r1>3.2)
                msgbox('Age is Greater Than 50 Years');
                set(handles.txt_output,'String','Age is Greater Than 50 Years');
              end
         end
    end
end

% --- Executes on button press in btn_exit.
function btn_exit_Callback(hObject, eventdata, handles)
% hObject    handle to btn_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);


% --- Executes on button press in btn_back.
function btn_back_Callback(hObject, eventdata, handles)
% hObject    handle to btn_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);
STARTPAGEINTERFACE
