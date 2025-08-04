function Equalized_intensity_image = Recursive(Image, intensity_max, intensity_min)
    global recursive_no;
    global no_of_times_higher;
    global no_of_times_lower;
    intensity_average = round(mean(Image,[1 2]));
    lower_intensity_image = Image(Image<intensity_average);
    higher_intensity_image = Image(Image>=intensity_average);
       
    if((no_of_times_higher == no_of_times_lower) && (no_of_times_higher == recursive_no) ) 
       Equalized_intensity_image = RSWHE_M(Image, lower_intensity_image, higher_intensity_image, intensity_average, intensity_max, intensity_min); %IF no Extra Recursive nature is required.            
    else
        no_of_times_higher = no_of_times_higher + 1;
        no_of_times_lower = no_of_times_lower +1;
        Equalized_intensity_lower_image = Recursive(lower_intensity_image,intensity_average, intensity_min);%Divide the image again and run Recursive(Lower)(I/P arguments: Image, intensity_max, intensity_min)
        Equalized_intensity_higher_image = Recursive(higher_intensity_image,intensity_max, intensity_average);%Divide the image again and run Recursive(Higher)(I/P arguments: Image, intensity_max, intensity_min)
        Equalized_intensity_image = Store_Images(Image, Equalized_intensity_lower_image, Equalized_intensity_higher_image, intensity_average); %Final Storage on the equalized images
    end
end
