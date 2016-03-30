function [p,r,vad]=precesionrecall(pred,groundtruth,topn,relval)
% Compute precesion and recall for given topn recommendation
% pred is the prediction vector
% groundtruth is the truth vector
% relval is the value in groundtruth that indicates relevant
% vad returns whether there is at least one relevant item in groundtruth

p=0;
r=0;
if ~isempty(find(groundtruth>=relval))
    vad=1;
else
    vad=0;
end

if vad==1
    [val,nb]=sort(pred,'descend');
    T=val(topn);
    ind = find (groundtruth>=relval);
    ind1=find (pred(ind)>T);
    if ~isempty(ind1)
        c=length(ind1);
    else
        c=0;
    end
    ind2=find (pred(ind)==T);
    if ~isempty(ind2)
        posnum=length(find(pred==T));
        c=c+length(ind2)/posnum;
    end
    p=c/topn;
    r=c/length(ind);
end
