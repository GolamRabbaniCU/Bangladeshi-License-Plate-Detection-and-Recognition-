clc;
close all;
load carNet;
directory='main car\';
imagefiles = dir(strcat(directory,'\*.jpg')); 
%     imagefiles = dir('temp image\*.jpg');
nfiles = length(imagefiles);
imageCount=1;
for ii = 1 : nfiles
    currentfilename = imagefiles(ii).name;
    fullpath=strcat(directory,currentfilename);
    currentImage = imread(fullpath);
    figure,imshow(currentImage),title('Original Image');
    grayImage=rgb2gray(currentImage);
    figure,imshow(grayImage);
    g=wiener2(grayImage,[5 5]);
    figure,imshow(g);
%     g1=adapthisteq(grayImage);
%     figure,imshow(g1);
%     g2=histeq(grayImage);
%     figure,imshow(g2),title('Image Enhancement');
    binaryImage=imbinarize(g,'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
    figure,imshow(binaryImage);
    binaryImage=bwareaopen(binaryImage,200);
    figure,imshow(binaryImage);
    labeledImage = bwlabel(binaryImage);
    measurements = regionprops(labeledImage,'all');
    for k = 1 : length(measurements)
        thisBB = measurements(k).BoundingBox;
        I2=imcrop(binaryImage,[thisBB(1)-10,thisBB(2)-10,thisBB(3)+10,thisBB(4)+10]);
        grayI2=imcrop(g,[thisBB(1),thisBB(2),thisBB(3),thisBB(4)]);
        
        [r, c, d]=size(I2);
        if r>200 && c>300 && c/r> 1.8 && c/r <2.2 && r<1300 && c<1300
            figure,imshow(I2);
              grayI2=imresize(grayI2,[200 400]);
              characterRecognition(grayI2,carNet,currentImage);
%               
%               filename = sprintf('%02d.jpg', imageCount);
%             fullFileName = fullfile('temp', filename);
%             imwrite(grayI2, fullFileName);
%             imageCount=imageCount+1;
        end
       
    end
    aaaa=1;
end

function []=characterRecognition(plate,carNet,currentImage)
%     figure,imshow(plate);
    grayPlate=wiener2(plate,[5 5]);
    g1=adapthisteq(grayPlate);
    binaryImage=imbinarize(g1,'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
    binaryImage=~binaryImage;
%     figure,imshow(binaryImage);
    binaryImage=bwareaopen(binaryImage,400);
    labeledImage = bwlabel(binaryImage);
    measurements = regionprops(labeledImage,'all');
    imageCount=1;
    count=1;
    digit="";
    area="";
    alphabet="";
    metro="";
    Ans="Car Licence Plate No:";
    for k = 1 : length(measurements)
        count=count+1;
        thisBB = measurements(k).BoundingBox;
        I2=imcrop(binaryImage,[thisBB(1),thisBB(2),thisBB(3),thisBB(4)]);
        figure,imshow(I2);
        [r c d]=size(I2);
        if r>30 && c >30 && r<150 && c<150
%             figure,imshow(I2);
            I2=imresize(I2, [30 50]);
            filename = sprintf('%02d.jpg', imageCount);
            fullFileName = fullfile('temp', filename);
            imwrite(I2, fullFileName);
            detect=imread(fullFileName);
            characterIs=char(classify(carNet,detect))
            if(strcmp(characterIs,"0")||strcmp(characterIs,"1")||strcmp(characterIs,"2")||strcmp(characterIs,"3")|| strcmp(characterIs,"4")||strcmp(characterIs,"5")||strcmp(characterIs,"6")||strcmp(characterIs,"7")||strcmp(characterIs,"8")||strcmp(characterIs,"9"))
                digit=strcat(digit,characterIs);
%                 aa=1
            end
            if(strcmp(characterIs,"dhaka")||strcmp(characterIs,"ctg"))
                area=characterIs;
%                 aa=1;
            end
            if(strcmp(characterIs,"cha")||strcmp(characterIs,"ga")||strcmp(characterIs,"gha"))
                alphabet=characterIs;
%                 aa=1;
            end
            if(strcmp(characterIs,"metro"))
                metro=characterIs;
%                 aa=1;
            end
            aa=1;
        end
        
        aaa=1
    end
    if(count>8)
    figure,imshow(currentImage),title(strcat(Ans,area,"-",metro,"-",alphabet,"-",digit));
    end
    count=1;
end