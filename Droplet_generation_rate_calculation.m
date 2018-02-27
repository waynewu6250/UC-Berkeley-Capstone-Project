%% Calculate the droplet generation rate by video processing

filename = './vid_evaluation/with resistor/1-10.mp4';
%Read the number of frames
v = VideoReader(filename);
numberOfFrames = v.NumberOfFrames;
vidHeight = v.Height;
vidWidth = v.Width;
time = v.Duration;

meanGrayLevels = zeros(numberOfFrames, 1);
normalized = zeros(numberOfFrames, 1);

for frame = 1 : numberOfFrames
	% Extract the frame from the movie structure.
	thisFrame = read(v, frame);
		
	% Display it
	hImage = subplot(2, 2, 1);
	image(thisFrame);
	caption = sprintf('Frame %4d of %d.', frame, numberOfFrames);
	title(caption, 'FontSize', 20);
	drawnow;
    
    x_pos = 800;
    y_pos1 = 400;
    y_pos2 = 600;
    % Calculate the mean gray level.
	grayImage = rgb2gray(thisFrame);
	meanGrayLevels(frame) = mean(grayImage(y_pos1:y_pos2,x_pos));
    normalized(frame) = -(meanGrayLevels(frame)-max(meanGrayLevels));
		
	% Plot the mean gray levels.
	hPlot = subplot(2, 2, 2);
	hold off;
	plot(normalized, 'k-', 'LineWidth', 1);
	grid on;
    
    title('Mean Gray Levels (Normalized)', 'FontSize', 20);
    xlabel('Frame Number');
    ylabel('Gray Level (Normalized)');
    
    %% Now let's do the differencing
	alpha = 0.5;
	if frame == 1
		Background = thisFrame;
    else
		Background = (1-alpha)* thisFrame + alpha * Background;
    end
    
	% Display the changing/adapting background.
	subplot(2, 2, 3);
	imshow(Background);
	title('Adaptive Background', 'FontSize', 20);
	% Calculate a difference between this frame and the background.
	differenceImage = thisFrame - uint8(Background);
	% Threshold with Otsu method.
	grayImage = rgb2gray(differenceImage); 
	thresholdLevel = graythresh(grayImage);
	binaryImage = im2bw( grayImage, thresholdLevel);
	% Plot the binary image.
	subplot(2, 2, 4);
	imshow(binaryImage);
	title('Binarized Difference Image', 'FontSize', 20);
    
end

L = numberOfFrames;
Fs = L/time;

Y = fft(normalized);
P2 = abs(Y/L);

if mod(L,2) == 0
    P1 = P2(1:L/2+1);
else
    P1 = P2(1:(L+1)/2);
end
    
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

figure(2)
plot(f,P1)
title('MeanGrayLevel in Frequency Domain')
ylim([-inf,inf])
xlim([2,inf])
xlabel('f (Hz)')
ylabel('|P1(f)|')

