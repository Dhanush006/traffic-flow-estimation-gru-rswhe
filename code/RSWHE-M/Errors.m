function [Output_Error] = Errors(Original,Final)
[~,~,colors] = size(Original);
Output_Error = [];
 
      %-----------------AMBE CALCULATION-----------------------------------
      
      intensity_avg_final = mean(Final(:,:,:),[1 2]);
      intensity_avg_original = mean(Original(:,:,:),[1 2]);
      Output_Error(3)=mean(mean(abs(intensity_avg_original-intensity_avg_final),colors));
      
      %-------------------------------------------------------------------- 
      %----------------PSNR CALCULATION------------------------------------
      
      Output_Error(4) = psnr(Final,Original);
      
      %--------------------------------------------------------------------
      %----------------STRUCTURED SIMILARITY INDEX CALCULATION-------------
      
      Output_Error(5) = ssim(Final,Original);
      
      %--------------------------------------------------------------------
      %----------------ENTROPY CALCULATION---------------------------------
      
      Output_Error(1) = entropy(Original);
      Output_Error(2) = entropy(Final);
      
      %--------------------------------------------------------------------
      
      
end
      
    
