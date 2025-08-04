function Equalized_intensity_image_pdf = Weighing_Module(intensity_image)
    
    global original_intensity_mean;
    global original_intensity_median;  
    global original_rows; 
    global original_columns;
    global original_max_pdf;
    global original_min_pdf;
    global original_intensity_max;
    global original_intensity_min;
    global beta;
    [rows,columns] = size(intensity_image);
    finalResult = uint8(zeros(rows,columns));
    pixelNumber = rows*columns;
    frequency = zeros(256,1);%Frequency of pixels having a certain intensity
    frequencynew = zeros(256,1);%Frequency of pixels having a certain intensity after being HE.
    probdf = zeros(256,1);
    probnewdf = zeros(256,1);
    pwdf = uint16(zeros(256,1));
    cdf = zeros(256,1);
    cdfnew = zeros(256,1);
    intensity = 0;
    outpic = zeros(256,1,3);
%     for i = 1:1:rows
%         for j = 1:1:columns
%             val = intensity_image(i,j);%Ranges from 0-255
%             intensity = val + 1;%MATLAB ranges from 1-256
%             frequency(intensity,:) = frequency(intensity,:)+1;%Increase the pixel count by 1
%             probdf(intensity,:) = frequency(intensity,:)/(original_rows * original_columns);%Normalize it by the total pixels
%         end
%     end
    probdf = imhist(intensity_image, 256)/(original_rows * original_columns);
    alpha = sum(probdf);
%     beta = abs((original_intensity_mean - original_intensity_median));
%     beta = double(original_max_pdf*beta);
%     beta = beta/double(original_intensity_max - original_intensity_min);
    pwdf = original_max_pdf*(((probdf- original_min_pdf)/(original_max_pdf - original_min_pdf)).^alpha) + double(beta);    
    Equalized_intensity_image_pdf = pwdf;
    

end