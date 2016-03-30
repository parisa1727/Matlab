
k=1;


for j= 1: 1682
    for i = 1 : 943
        if Ratingmat(i,j)> 0
            mytable (k,1)=estrate(i,j);
            mytable(k,2)= Ratingmat(i,j);
             k=k+1;
        end
    end
end
    
        
    
