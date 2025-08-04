function a = CLAHE(img)
    a= rgb2lab(img);
    J = adapthisteq(a(:,:,1)/100,'clipLimit',0.1,'Distribution','rayleigh');
    J = J*100;
    a(:,:,1) = J;
    a= lab2rgb(a);
%     figure();
%     imshow(a);
    % figure();
    % imshow(img);
    % Error = Errors(img, uint8(a))
end