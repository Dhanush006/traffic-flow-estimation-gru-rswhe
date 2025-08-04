    function Equalized_intensity_image = HE_without_initialization(intensity_image ,intensity_max, intensity_min)
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

    [rows,columns] = size(intensity_image);
    finalResult = uint8(zeros(rows,columns));
    pixelNumber = rows*columns;
    frequency = zeros(256,1);%Frequency of pixels having a certain intensity
    frequencynew = zeros(256,1);%Frequency of pixels having a certain intensity after being HE.
    probdf = zeros(256,1);
    probnewdf = zeros(256,1);
    cdf = zeros(256,1);
    cdfnew = zeros(256,1);
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
    pwdf = pwdf/sum(sum(weighted_pdf_sum));
    pwdf = pwdf * (original_rows * original_columns);
    pwdf = pwdf / (rows * columns);%The error might be here(pwdf might be greater than one)
    pwdf = pwdf/sum(sum(pwdf));
    probdf = pwdf;
    total=0;
    for i = 1:1:size(probdf(:,:))%Loop to find CDF
        total = total + probdf(i,:);
        cdf(i,:) = total;    
    end
    for i = 1:1:size(probdf(:,:))%Histogram Equalization(Seperated from the above loop to enhance readability)
        outpic(i,:) = round((cdf(i,:) * (intensity_max-intensity_min)) + intensity_min);  %Histogram Equalization to using CDF as the function.   
    end%Outpic is a transformation function, formulated by the above equation; It changes each intensity value to some other value using the cdf.
    
    for i = 1:1:rows
        for j = 1:1:columns
            finalResult(i,j) = outpic(intensity_image(i,j) + 1);%Assigning each pixel a different intensity.
        end
    end
%     total=0;
%     for i = 1:1:rows
%         for j = 1:1:columns
%              val = finalResult(i,j);
%              intensity = val + 1;
%              frequencynew(intensity,:) = frequencynew(intensity,:)+1;
%              probnewdf(intensity,:) = frequencynew(intensity,:)/pixelNumber;
%         end
%     end
    
%     for i = 1:1:size(probdf)
%         total = total +probnewdf(i,:);
%         cdfnew(i,:) = total;
%     end
    Equalized_intensity_image = finalResult;

end