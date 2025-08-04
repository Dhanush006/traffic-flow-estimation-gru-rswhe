function Equalized_intensity_image = RSWHE_M(Image, lower_intensity_image, higher_intensity_image, intensity_average, intensity_max, intensity_min)
    Equalized_intensity_lower_image = HE_without_initialization(lower_intensity_image, intensity_average, intensity_min);%Histogram Equalization of Each Image(I/P arguments: Image, intensity_max, intensity_min).
    Equalized_intensity_higher_image = HE_without_initialization(higher_intensity_image, intensity_max, intensity_average);
        
    

    if(size(lower_intensity_image,1) == 0)
        Equalized_intensity_image = Equalized_intensity_higher_image;
    elseif(size(higher_intensity_image,1) == 0)
        Equalized_intensity_image = Equalized_intensity_lower_image;
        
    else
        Internal_rows = size(Equalized_intensity_lower_image(:,1)) + size(Equalized_intensity_higher_image(:,1));
        Internal_rows=Internal_rows(1,1);
        Internal_columns = (size(Equalized_intensity_lower_image(1,:)) + size(Equalized_intensity_higher_image(1,:)))/2;
        Internal_columns = Internal_columns(1,2);
        Equalized_intensity_image = uint8(zeros(Internal_rows,Internal_columns));
        Image = Image';
        [rows, columns] = size(Image);
        Equalized_intensity_image = uint8(zeros(Internal_rows,Internal_columns));
        a=1;b=1;
        d=1;

        for i = 1:1:rows
            for j = 1:1:columns
                if(Image(i,j)<intensity_average)
                     Equalized_intensity_image(b,1) = Equalized_intensity_lower_image(a,1);%Assigning each pixel a different intensity.
                     a= a+1;
                     b= b+1;


                elseif(Image(i,j)>=intensity_average)
                    Equalized_intensity_image(b,1) = Equalized_intensity_higher_image(d,1);%Assigning each pixel a different intensity.  
                    d = d+1;
                    b=b+1;

                end
            end

        end  
    end
end