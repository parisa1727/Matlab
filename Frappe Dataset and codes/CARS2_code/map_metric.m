function [ap,f] = map_metric(pred,Testdata,relval)

% ap : average precision for each query
% f: Mean Average Precision
% pred: prediction matrix
% Testdata: Groundtruth matrix
% relval: The threshold for relevance

Nq = length(Testdata(:,1));

ap = zeros(Nq,1);
if any(any(Testdata))
    for i=1:Nq
        ind = find (Testdata(i,:)>=relval);
        if ~isempty(ind)
            P=0;
            [val,nb]=sort(full(pred(i,:)),'descend');
            for j=1:length(ind)
                topn=find(nb==ind(j));
                [p,r,vad2]=precesionrecall(pred(i,:),Testdata(i,:),topn,relval);
                P=P+p;
            end
            ap(i)=P/length(ind);
        else
            ap(i)=0;
        end
    end
    f=mean(ap(ap>0));
else
    f=-1;
end
