function Image_Output = RSWHE_M_TOP(original_low_contrast , recursive_no_in, greyscale_needed)    
%     clc
%     clear
    clear global all        
    if(greyscale_needed)
        original_low_contrast = rgb2gray(original_low_contrast);
    end
    
    [rows,columns,colors] = size(original_low_contrast);
    Top_Level_Output = uint8(zeros(rows,columns,colors));


    global recursive_no ;
    global no_of_times_higher;
    global no_of_times_lower;    
    global original_rows; 
    global original_columns;
    global original_max_pdf;
    global original_min_pdf;
    global weighted_pdf_sum;
    global original_intensity_max;
    global original_intensity_min;
    global original_intensity_mean;
    global original_intensity_median;
    global beta;
    probdf = zeros(256,1,colors);
    probnewdf = zeros(256,1,colors);
    cdf = zeros(256,1,colors);
    cdfnew = zeros(256,1,colors);
    
    for k = 1:colors
        [probdf(:,:,k),~, ~, ~] = Plotting( original_low_contrast(:,:,k), original_low_contrast(:,:,k));%Finding the PDF of the Input Image
        intensity_max = 255; 
        intensity_min = 0;
        original_intensity_mean = mean(mean(original_low_contrast(:,:,k)));%Mean of I/P Image
        original_intensity_median = double(median(median(original_low_contrast(:,:,k))));%Median of I/P Image
        original_intensity_max = max(max(original_low_contrast(:,:,k)));%Max of I/P Image
        original_intensity_min = min(min(original_low_contrast(:,:,k)));%Min of I/P Image
        original_rows = rows;
        original_columns = columns;           
        original_max_pdf = max(max(probdf));%Highest pdf value of I/P Image
        original_min_pdf = min(min(probdf));%Lowest PDF value of I/P Image
        recursive_no = recursive_no_in;
        no_of_times_higher = 1;
        no_of_times_lower = 1;
    
        beta = abs((original_intensity_mean - original_intensity_median));
        beta = double(original_max_pdf*beta);
        beta = beta/double(original_intensity_max - original_intensity_min);
        weighted_pdf_sum = Processing_Fn(original_low_contrast(:,:,k));%Finding the weighted PDF of the I/P Image
        
        recursive_no = recursive_no_in;
        no_of_times_higher = 1;
        no_of_times_lower = 1;
        
        finalOutput= Recursive(original_low_contrast(:,:,k), intensity_max, intensity_min);
        Top_Level_Output(:,:,k) = reshape(finalOutput, [rows,columns]);%Getting the O/P Image
        [probdf(:,:,k), probnewdf(:,:,k), cdf(:,:,k), cdfnew(:,:,k)] = Plotting( Top_Level_Output(:,:,k), original_low_contrast(:,:,k));%Finding the PDF and CDF of the original and new image.     
    end   
   
    [histpdf, ~ , histcdf, ~] = Plotting(histeq(original_low_contrast),original_low_contrast);%Finding the PDF and CDF of the MATLAB histeq function on the I/P image.
    
    if(~greyscale_needed)%Checking if the greyscale variable is one or 0.
            pdf = mean(probdf,colors);%Averaging across DIM colors
            cumuldf = mean(cdf,colors);
            pdfnew = mean(probnewdf,colors);
            cumuldfnew = mean(cdfnew,colors);
       else
            pdf = probdf;%Averaging across DIM colors
            cumuldf = cdf;
            pdfnew = probnewdf;
            cumuldfnew = cdfnew; 
    end

%---------------------------------------------------------------Function To find PDF and CDF --------------------------------------------------------------------

     function [probdf, probnewdf, cdf, cdfnew] = Plotting( Top_Level_Output, original_low_contrast)
            
            pdf = zeros(256,1);%Average values of the pdfs of the R-G-B images
            cumuldf = zeros(256,1);%Average values of the cdfs of the R-G-B images
            pdfnew = zeros(256,1);%Average values of the new pdfs of the R-G-B images
            cumuldfnew = zeros(256,1);%Average values of the new cdfs of the R-G-B images
            pixelNumber = rows*columns;
            frequency = zeros(256,1);%Frequency of pixels having a certain intensity
            frequencynew = zeros(256,1);%Frequency of pixels having a certain intensity after being HE.
            probdf = zeros(256,1);
            probnewdf = zeros(256,1);
            cdf = zeros(256,1);
            cdfnew = zeros(256,1);
%             
%             probdf = uint8(imhist(original_low_contrast, 256)/pixelNumber
            for i = 1:1:rows
                    for j = 1:1:columns
                        val = original_low_contrast(i,j);%Ranges from 0-255
                        intensity = val + 1;%MATLAB ranges from 1-256
                        frequency(intensity,:) = frequency(intensity,:)+1;%Increase the pixel count by 1
%                         probdf(intensity,:) = frequency(intensity,:)/pixelNumber;%Normalize it by the total pixels
                    end
            end
             probdf = frequency/pixelNumber;
                total =0;
                for i = 1:1:size(probdf(:,:))%Loop to find CDF
                    total = total + probdf(i,:);
                    cdf(i,:) = total;
                    % cdf(i) = cummlative(i)/ pixelNumber;    
                end
                total=0;
                for i = 1:1:rows
                    for j = 1:1:columns
                         val = Top_Level_Output(i,j);
                         intensity = val + 1;
                         frequencynew(intensity,:) = frequencynew(intensity,:)+1;
                         probnewdf(intensity,:) = frequencynew(intensity,:)/pixelNumber;
                    end
                end

                for i = 1:1:size(probdf)
                    total = total +probnewdf(i,:);
                    cdfnew(i,:) = total;
                end
     end 
    
 %-------------------------------------------------------------------------------PLOTS-----------------------------------------------------------
    figure('units','normalized','outerpos',[0 0 1 1])
    jFrame = get(handle(gcf),'JavaFrame');
    jFrame.setMaximized(true);
    subplot(3,3,1),imshow(original_low_contrast),title('Original Image');
    subplot(3,3,2),imshow(Top_Level_Output),title('RSWHE-M');
    subplot(3,3,3),imshow(histeq(original_low_contrast)),title('HistEq');
      
    subplot(3,3,4),stem(1:1:size(pdf),pdf); title('PDF(Original)');  
    subplot(3,3,5),stem(1:1:size(pdfnew),pdfnew); title('PDF(RSWHE-M)');  
    subplot(3,3,6),stem(1:1:size(histpdf),histpdf); title('PDF(HistEq)');  
    
    subplot(3,3,7),plot(cumuldf),title('CDF(Original)'); 
    subplot(3,3,8),plot(cumuldfnew),title('CDF(RSWHE-M)'); 
    subplot(3,3,9),plot(histcdf),title('CDF(HistEq)'); 
    
%     imshow(original_low_contrast),title('Original Image');
%     imshow(Top_Level_Output),title('RSWHE-M');
    
    Image_Output = Top_Level_Output;
    size(Image_Output);
    
%     figure('units','normalized','outerpos',[0 0 1 1])
%     jFrame = get(handle(gcf),'JavaFrame');
%     jFrame.setMaximized(true);
%     
%     subplot(2,1,1),imshow(Image_Output),title('RSWHE-M');
%     subplot(2,1,2),imshow(original_low_contrast),title('Original Image');
%     
%     Error = Errors(original_low_contrast, Image_Output)
end