function Weighted_image_pdf = Processing_Fn(Image)
    global recursive_no;
    global no_of_times_higher;
    global no_of_times_lower;
    
    intensity_average = round(mean(Image,[1 2]));%Finding the mean intensity
    lower_intensity_image = Image(Image<intensity_average);%Sub-Image with Lower intensities
    higher_intensity_image = Image(Image>=intensity_average);%Sub-Image with Lower intensities
       
    if((no_of_times_higher == no_of_times_lower) && (no_of_times_higher == recursive_no) ) 
       Weighted_image_pdf = Processing_Fn2(lower_intensity_image, higher_intensity_image); %IF no Extra Recursive nature is required.            
    else
        no_of_times_higher = no_of_times_higher + 1;
        no_of_times_lower = no_of_times_lower +1;
        Weighted_lower_image_pdf = Processing_Fn(lower_intensity_image);%Divide the image again and run Processing_Fn(Lower)(I/P arguments: Image)
        Weighted_higher_image_pdf = Processing_Fn(higher_intensity_image);%Divide the image again and run Processing_Fn(Higher)(I/P arguments: Image)
        Weighted_image_pdf = [Weighted_lower_image_pdf; Weighted_higher_image_pdf];
    end
end
