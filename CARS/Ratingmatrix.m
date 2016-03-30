for i = 1:height(Rating)
    Ratingmat(Rating(i,:).Userid ,Rating(i,:).Itemid) = Rating(i,:).rating;
end