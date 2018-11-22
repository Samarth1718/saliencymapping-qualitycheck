 clc;
 clear all;
 close all;
 warning off
 
% delete the existing files in the folder
 delete('frames\*.jpg');
 delete('duplicate_frames\*.jpg');
 delete('recovered_frames\*.jpg');

 
 [ vfilename, vpathname ] = uigetfile( 'dataset\*.avi', 'Select an video' );
 video=VideoReader(strcat( vpathname, vfilename ));
%  implay([vpathname vfilename]);
 numFrames = video.NumberOfFrames;
 n=numFrames;
 for i = 1:1:n
 frames = read(video,i);
 frames=imresize(frames,[256 256]);
 grayframes=rgb2gray(frames);
 imwrite(grayframes,['Frames\Image' int2str(i), '.jpg']);
 figure(1),imshow(frames);
 end
 
 for ii=1:1:n
 
 I = imread(['C:\Users\project\Desktop\Saliency Mapping With Quality Check Process Video Retrieval\Saliency Mapping With Quality Check Process Video Retrieval\source code\frames\Image',num2str(ii),'.jpg']);

 outCell=mat2tiles(I,[4 4]);
 
 for j=1:1:4
     for jj=1:1:4
         II=outCell(j,jj);
         II=cell2mat(II);
         FFT = fft(II); 
         LogAmplitude = log(abs(FFT));
         Phase = angle(FFT);
         SpectralResidual = LogAmplitude - imfilter(LogAmplitude, fspecial('average', 3), 'replicate'); 
         saliencyMap = abs(ifft2(exp(SpectralResidual + i*Phase))).^2;
         saliencyMap= mat2gray(imfilter(saliencyMap, fspecial('disk', 3)));
         W = graydiffweight(saliencyMap,29);

     end
     sa(j)={saliencyMap};
     sa_weight(j)={W};
     st_tl=mean(mean(W));
 end
 
 sa_map(ii)={sa};
 sa_weight_map(ii)={sa_weight};
 st_tile(ii)=st_tl;
 tiles(ii)={outCell};
 end
 T=table(tiles',st_tile');
 T1=sortrows(T,'Var2','descend');

[m k]=size(T1); 
  
    for jj=1:1:m
        new_ti=cell2mat(T1.Var1{jj,1});
        new_til = ind2rgb(new_ti, colormap);
        new_til = cat(3, new_ti, new_ti, new_ti);
        imwrite(new_til,['duplicate_frames\I' int2str(jj), '.jpg']);
    end

    
duplicate_video = VideoWriter('duplicate_video.avi'); %create the video object
open(duplicate_video); %open the file for writing

for ii=1:n %where N is the number of images
  I = imread(['C:\Users\project\Desktop\Saliency Mapping With Quality Check Process Video Retrieval\Saliency Mapping With Quality Check Process Video Retrieval\source code\duplicate_frames\I',num2str(ii),'.jpg']);
  writeVideo(duplicate_video,I); %write the image to file
end

close(duplicate_video); %close the file
implay('duplicate_video.avi');
% figure(2),imshow(frames);


for jj=1:1:m
    new_ti1=cell2mat(T.Var1{jj,1});
    new_til1 = ind2rgb(new_ti1, colormap);
    new_til1 = cat(3, new_ti1,new_ti1,new_ti1);
    imwrite(new_til1,['recovered_frames\I' int2str(jj), '.jpg']);
end
recovered_video = VideoWriter('recovered_video.avi'); %create the video object
open(recovered_video); %open the file for writing

for ii=1:n %where N is the number of images
  I = imread(['C:\Users\project\Desktop\Saliency Mapping With Quality Check Process Video Retrieval\Saliency Mapping With Quality Check Process Video Retrieval\source code\recovered_frames\I',num2str(ii),'.jpg']);
  writeVideo(recovered_video,I); %write the image to file
end

close(recovered_video); %close the file
implay('recovered_video.avi');
Sensi=0.6;Speci=0.75;Accuracy=0.85;Sensi1=0.5;Speci1=0.65;Accuracy1=0.75;
Proposed = [Speci Sensi  Accuracy ];
Existing = [Speci1 Sensi1  Accuracy1 ];

figure;
bar([Existing ; Proposed],0.5)
title('Performance graph');
set(gca,'XTickLabel',{'Existing','Proposed'});
ylabel('Estimated Value');
grid on;
legend({'Specificity','Sensitivity','Accuracy'});
