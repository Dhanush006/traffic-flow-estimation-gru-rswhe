%ACCUMULATOR Summary of this function goes here

GRU_out = grp2idx(YPred);%LSTM/GRU Predicted Output
Detected_Vehicles = Sequences(:, 3, :);%Number of Frames used as Inputs in the form of Spatio-Temporal Counting Features
Detected_Vehicles =  reshape( Detected_Vehicles , size( Detected_Vehicles(:,:,1) , 1) , No_Sel_Cars);

no_cars = 3;%Considering only the 3 closest vehicles to the line
input_values = [Detected_Vehicles GRU_out];%Combining the two Inputs to one


Vehicle_Direction = zeros(size(Detected_Vehicles));
for i = 2:1:size(Detected_Vehicles(:,1))
    
    for j = 1:1:size(Detected_Vehicles(1,:),2)
        
        if( (Detected_Vehicles(i,j) > 0) && (Detected_Vehicles(i-1, j) < 0) )
            Vehicle_Direction(i,j) = 1;
            
        elseif( (Detected_Vehicles(i,j) < 0) && (Detected_Vehicles(i-1, j) > 0) )
            Vehicle_Direction(i,j) = -1;
            
        else
            Vehicle_Direction(i,j) = 0;
            
        end
        
    end
    
end

cy = 100;
alpha = 2;
FrameRate = 25;
A = zeros(size(Detected_Vehicles));
B = zeros(size(Detected_Vehicles));



for i = 2:1:size(Detected_Vehicles(:,1))
    
    for j = 1:1:size(Detected_Vehicles(1,:),2)
        
        if( Vehicle_Direction(i,j) == 1 )
            A(i,j) = Detected_Vehicles(i,j);
            
        elseif( Vehicle_Direction(i,j) == -1 )
            B(i,j) = Detected_Vehicles(i,j);
            
        end  
        
    end
    
end




%To find the vehicles closest to the line in BOTH directions
dp_a = min(A ,[], 2);%Least Positive STCF value per frame in Direction-A
dn_a = max(A ,[], 2);%Least Negative STCF value per frame in Direction-A

dp_b = min(B ,[], 2);%Least Positive STCF value per frame in Direction-A
dn_b = max(B ,[], 2);%Least Negative STCF value per frame in Direction-A

d_a = [dp_a dn_a];%Vector Containing the Two closest vehicles to the line per frame in Direction-A
d_b = [dp_b dn_b];%Vector Containing the Two closest vehicles to the line per frame in Direction-B

w = 5; %Number of useful frames.
Ea = zeros(size(A,1), size(d_a,2) ); %
Eb = zeros(size(B,1), size(d_b,2) );



%FOR NOW, WE ARE USING A TEMPORARY VERSION WHERE WE ARE USING THE STCF
%FEATURES INSTEAD OF THE BOUNDING BOXES OF THE ACTUAL DETECTED VEHICLES, WE
%ARE ALSO CONSIDERING THE THREE CLOSEST VEHICLES INSTEAD OF THE WHOLE SET
%OF DETECTED VEHICLES IN THE FRAME. THIS WILL HAVE TO BE CHANGED TO
%ACCOMODATE THE DYNAMIC THRESHOLD ACCUMULATOR
% E(j) = d(j) - d(j-1)
Ea(1 , :) = d_a(1 , :);
for i = 2:1:size(A(:,1))
    Ea(i , :) = d_a(i ,:) - d_a(i-1 , :);
end

Eb(1 , :) = d_b(1 , :);
for i = 2:1:size(A(:,1))
    Eb(i , :) = d_b(i , :) - d_b(i-1 , :);
end
%         theta value θj = α · ave(E (j−ω) ), (ω=1, 2,···, n), ∀ O(j−ω)=1

% IN DIRECTION -A
theta_a = zeros(size(A,1), size(d_a,2) );
for i = 1 : w
    temp = [[]];
    for j = 1 : w
        if( (i - j + 1) > 0 && (GRU_out(i) == 1) )
            temp = [temp  Ea(i - j + 1 , :)' ]; 
        else
            temp = [temp [1000 ; -1000] ];
        end
        theta_a(i , :) = alpha * mean( temp , 2 );
    end
end

for i = w+1 : size(A)
    if(GRU_out(i) == 1)
        temp = [[]];
        if( GRU_out(i) == 1 )
            for j = 1 : w
                temp = [temp  Ea(i - j + 1 , :)' ];
            end
        else
                temp = [temp [1000 ; -1000] ];
        end
        theta_a(i , :) = alpha * mean( temp , 2 );
    end
end

% IN DIRECTION-B
theta_b = zeros(size(B,1), size(d_b,2) );
for i = 1 : w
        temp = [[]];
        for j = 1 : w
            if( (i - j + 1) > 0 && (GRU_out(i) == 1) )
                temp = [temp  Ea(i - j + 1 , :)' ]; 
            else
                temp = [temp [1000 ; -1000] ];
            end
        end
        theta_b(i , :) = alpha * mean( temp , 2 );    
end

for i = w+1 : size(B)
    if(GRU_out(i) == 1)
        temp = [[]];
        if( GRU_out(i) == 1 )
            for j = 1 : w
                temp = [temp  Eb(i - j + 1 , :)' ];
            end
        else
                temp = [temp [1000 ; -1000] ];
        end
        theta_b(i , :) = alpha * mean( temp , 2 );
    end
end
        
    





Ca = zeros(size(Detected_Vehicles(:,1)));%Counting the Number of Crossed Vehicles in Direction - A
Cb = zeros(size(Detected_Vehicles(:,1)));%Counting the Number of Crossed Vehicles in Direction - B

Va = zeros(size(Ca));%Volume of Crossed Vehicles in Direction - A
Vb = zeros(size(Cb));%Volume of Crossed Vehicles in Direction - B

Des_a = zeros(size(Ca));%Density of Vehicles in Direction - A
Des_b = zeros(size(Cb));%Density of Vehicles in Direction - B

Sa = zeros(size(Ca));%Traffic Speed in Direction - A
Sb = zeros(size(Cb));%Traffic Speed in Direction - B

Da = sum(A>0,2);
Db = sum(B<0,2);

for i = 2 : size(Da,1) 
    if(Da(i) == 0)
        Da(i) = Da(i-1);
    end
    if(Db(i) == 0)
        Db(i) = Db(i-1);
    end
        
end

%For MVI_39851


Height = 50;%La in metres
Height_Pixel = 350;%Lp in Pixels

Width_a = 330;%Width of road segment in direction A in pixels
Width_b = 300;%Width of road segment in direction B in pixels

for i = 1:1:size(Ca)
    if(input_values(i,4) == 2)
%         if(Ea(i) > theta_a(i))
            if(i > 1)
                Ca(i) = Ca(i-1) + 1;
            elseif(i == 1)
                Ca(i) = 1;
            end
%         end
    else
        if(i > 1)
            Ca(i) = Ca(i-1);
        elseif(i == 1)
            Ca(i) = 0;
        end        
    end
    Va(i) = (Ca(i) * 3600 * FrameRate)/i;
    Des_a(i) = double( (Da(i) * Height_Pixel * 1000)/(Width_a * Height) );
    Sa(i) = Va(i)/Des_a(i);
end

for i = 1:1:size(Cb)
    if(input_values(i,4) == 3)
%         if(Eb(i) > theta_b(i))
            if(i > 1)
                Cb(i) = Cb(i-1) + 1;
            elseif(i == 1)
                Cb(i) = 1;
            end
%         end
    else
        if(i > 1)
            Cb(i) = Cb(i-1);
        elseif(i == 1)
            Cb(i) = 0;
        end        
    end
    Vb(i) = (Cb(i) * 3600 * FrameRate)/i;
    Des_b(i) = double( (Db(i) * Height_Pixel * 1000)/(Width_b * Height) );
    Sb(i) = Vb(i)/Des_b(i);
end
    


