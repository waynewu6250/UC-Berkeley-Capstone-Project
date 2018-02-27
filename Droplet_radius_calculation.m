%%Calculate the droplet by images through Circular Hough Transform

imgPath = './pic_evaluation/water rate change/with resistor_oil rate 150/';
list = dir([imgPath '*.jpg']);

%Define variables
mean_value = [];
std_value = [];
x = [];

for i = 1:length(list)

fig{i} = imread([imgPath list(i).name]);
str = extractBefore(list(i).name,'.jpg');
x(i) = str2num(str);

if i==1
    figure(1)
    fig2 = rgb2gray(fig{i});
    imshow(fig2)
    
    %measure distance for channel width
    h = imdistline;
    api = iptgetapi(h);
    api.setLabelVisible(false);
    pause();

    dist = api.getDistance();
else
    figure(2*i-1)
    fig2 = rgb2gray(fig{i});
    imshow(fig2)
end

%Find radius and location for a droplet
[centers, radii, metric] = imfindcircles(fig2,[40 100], 'sensitivity', 0.915);
viscircles(centers, radii, 'Color', 'r')

radius_norm = 125*radii/(dist);

if radius_norm ~= 0
    
    %Remove Outliers
    meanValue = mean(radius_norm);
    absoluteDeviation = abs(radius_norm-meanValue);
    mad = median(absoluteDeviation);
    sensitivityFactor = 0.6;
    thresholdValue = sensitivityFactor*mad;
    outlierIndexes = abs(absoluteDeviation) > thresholdValue;

    nonOutliers = radius_norm(~outlierIndexes);

    figure(2*i)

    %plot values of droplet radii
    hist(nonOutliers,5)
    title('Droplet Radius Distribution')
    xlabel('Droplet Radius (um)')
    ylabel('Times')
    set(gca,'XLim',[55 63]);
    
    mean_value(i)=mean(nonOutliers)
    std_value(i)=std(nonOutliers)
end

end

%Plot graph of relationship
figure(2*length(list)+1)
errorbar(x,mean_value,std_value,'^', 'linewidth', 2)
%ylim([20,50])
title('Water rate v.s. droplet radius in no resistor');
xlabel('Water rate (ul/hr)');
ylabel('Droplet radius (um)');

