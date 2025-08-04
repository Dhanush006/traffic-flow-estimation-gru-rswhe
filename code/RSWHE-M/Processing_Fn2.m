function Weighted_image_pdf = Processing_Fn2(lower_intensity_image, higher_intensity_image)%Change the Weight of the PDF
    Weighted_lower_image_pdf = Weighing_Module(lower_intensity_image);
    Weighted_higher_image_pdf = Weighing_Module(higher_intensity_image);
    Weighted_image_pdf = [Weighted_lower_image_pdf; Weighted_higher_image_pdf];           
end